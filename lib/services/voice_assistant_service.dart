import 'dart:async';

import 'package:camera/camera.dart' show XFile;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../screens/analysis_screen.dart';
import '../screens/history_screen.dart';
import '../screens/legal_document_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/strip_analysis_screen.dart';
import '../screens/strip_camera_screen.dart' show StripCaptureResult;
import 'firestore_service.dart';
import 'location_service.dart';
import 'navigation_service.dart';
import 'weather_service.dart';

enum VoiceAssistantState { idle, listening, thinking, speaking }

enum VoiceGender { female, male }

class VoiceAssistantMessage {
  final String text;
  final bool fromUser;

  const VoiceAssistantMessage(this.text, {required this.fromUser});
}

// Voice input/output is English-only for now: on-device speech recognizers
// don't realistically support Luganda, and mixing recognized/spoken
// languages mid-conversation would be confusing.
const String _localeId = 'en_US';

const String _systemPrompt = '''
You are the voice assistant inside AflAlert, a mobile app that helps Ugandan
maize farmers detect aflatoxin contamination and manage their crop scans.

You can take actions in the app by calling the functions made available to
you, or just answer conversationally when the user asks a general question
(e.g. about aflatoxin, maize storage, or crop safety).

Keep spoken replies short — one or two sentences — since they are read aloud
by text-to-speech. When you call start_maize_scan or start_strip_test, the
camera screen opens but the user still has to physically take and confirm the
photo themselves; make that clear in your reply instead of implying the scan
is already complete.
''';

class VoiceAssistantService extends ChangeNotifier {
  VoiceAssistantService() {
    _speech = SpeechToText();
    _tts = FlutterTts();
    _tts.setLanguage(_localeId.replaceAll('_', '-'));
    _tts.setCompletionHandler(() {
      if (_state == VoiceAssistantState.speaking) {
        _setState(VoiceAssistantState.idle);
      }
    });

    final GenerativeModel model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(_systemPrompt),
      tools: [Tool.functionDeclarations(_functionDeclarations)],
    );
    _chat = model.startChat();
  }

  late final SpeechToText _speech;
  late final FlutterTts _tts;
  late final ChatSession _chat;

  VoiceAssistantState _state = VoiceAssistantState.idle;
  VoiceAssistantState get state => _state;

  String _partialTranscript = '';
  String get partialTranscript => _partialTranscript;

  final List<VoiceAssistantMessage> messages = [];

  bool _speechAvailable = false;
  bool get speechAvailable => _speechAvailable;

  VoiceGender _voiceGender = VoiceGender.female;
  VoiceGender get voiceGender => _voiceGender;

  static final List<FunctionDeclaration> _functionDeclarations = [
    FunctionDeclaration(
      'start_maize_scan',
      'Opens the camera so the user can take a photo of maize for the AI '
          'mold/aflatoxin scan.',
      parameters: {},
    ),
    FunctionDeclaration(
      'start_strip_test',
      'Opens the camera for a chemical test-strip scan (Tier 2 lab-style '
          'test).',
      parameters: {},
    ),
    FunctionDeclaration(
      'go_home',
      'Navigates to the home screen.',
      parameters: {},
    ),
    FunctionDeclaration(
      'open_history',
      'Opens the full scan history screen.',
      parameters: {},
    ),
    FunctionDeclaration(
      'open_notifications',
      'Opens the notifications screen.',
      parameters: {},
    ),
    FunctionDeclaration(
      'open_profile',
      'Opens the user profile screen.',
      parameters: {},
    ),
    FunctionDeclaration(
      'open_settings',
      'Opens the app settings screen.',
      parameters: {},
    ),
    FunctionDeclaration(
      'open_legal_document',
      'Shows a legal document to the user.',
      parameters: {
        'document': Schema.enumString(
          enumValues: ['terms', 'privacy'],
          description: 'Which document to open.',
        ),
      },
    ),
    FunctionDeclaration(
      'describe_weather',
      "Fetches and describes the user's current local weather.",
      parameters: {},
    ),
    FunctionDeclaration(
      'summarize_recent_scans',
      "Summarizes the user's scan history (how many healthy vs risky).",
      parameters: {},
    ),
  ];

  Future<void> init() async {
    unawaited(_applyVoiceGender());
    if (_speechAvailable) return;
    _speechAvailable = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (SpeechRecognitionError error) {
        debugPrint('VoiceAssistantService speech error: ${error.errorMsg}');
        _setState(VoiceAssistantState.idle);
      },
    );
    notifyListeners();
  }

  Future<void> setVoiceGender(VoiceGender gender) async {
    if (_voiceGender == gender) return;
    _voiceGender = gender;
    notifyListeners();
    await _applyVoiceGender();
  }

  // iOS/macOS tag each voice with an explicit `gender` field, but Android's
  // `getVoices` never does (confirmed against the plugin's native source —
  // it only ever sends name/locale/quality/latency/network_required/
  // features) so that lookup alone silently never matches there. Many
  // Android "local" Google TTS voices do encode gender directly in the
  // voice *name* instead (e.g. "en-us-x-iol#female_1-local"), so that's
  // tried next. Pitch is the last-resort fallback, and needs a wide swing
  // to read as a different voice rather than the same voice sounding off.
  Future<void> _applyVoiceGender() async {
    final String wantedGender = _voiceGender == VoiceGender.male ? 'male' : 'female';
    bool matchedExplicitVoice = false;
    try {
      final dynamic voices = await _tts.getVoices;
      if (voices is List) {
        final List<Map> englishVoices = voices
            .whereType<Map>()
            .where((v) => (v['locale']?.toString().toLowerCase() ?? '').startsWith('en'))
            .toList();
        debugPrint(
          'VoiceAssistantService: ${englishVoices.length} English voices found: '
          '${englishVoices.map((v) => v['name']).toList()}',
        );

        Map? match;
        for (final Map voice in englishVoices) {
          if ((voice['gender']?.toString().toLowerCase() ?? '') == wantedGender) {
            match = voice;
            break;
          }
        }
        match ??= () {
          for (final Map voice in englishVoices) {
            if ((voice['name']?.toString().toLowerCase() ?? '').contains(wantedGender)) {
              return voice;
            }
          }
          return null;
        }();

        if (match != null) {
          debugPrint('VoiceAssistantService: matched explicit voice ${match['name']} for $wantedGender');
          await _tts.setVoice({
            'name': match['name'].toString(),
            'locale': match['locale'].toString(),
          });
          matchedExplicitVoice = true;
        } else {
          debugPrint('VoiceAssistantService: no explicit $wantedGender voice found, falling back to pitch');
        }
      }
    } catch (error) {
      debugPrint('VoiceAssistantService: could not enumerate TTS voices: $error');
    }

    final double pitch = _voiceGender == VoiceGender.male
        ? (matchedExplicitVoice ? 0.9 : 0.7)
        : 1.0;
    debugPrint('VoiceAssistantService: setting pitch to $pitch for $wantedGender (matchedExplicitVoice=$matchedExplicitVoice)');
    await _tts.setPitch(pitch);
  }

  void _onSpeechStatus(String status) {
    if ((status == 'done' || status == 'notListening') &&
        _state == VoiceAssistantState.listening) {
      _setState(VoiceAssistantState.idle);
    }
  }

  void _setState(VoiceAssistantState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_speechAvailable) {
      await init();
      if (!_speechAvailable) return;
    }
    _partialTranscript = '';
    _setState(VoiceAssistantState.listening);
    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
        localeId: _localeId,
      ),
    );
  }

  Future<void> stopListening() => _speech.stop();

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    _partialTranscript = result.recognizedWords;
    notifyListeners();
    final String text = result.recognizedWords.trim();
    if (result.finalResult && text.isNotEmpty) {
      _partialTranscript = '';
      await _handleUserMessage(text);
    }
  }

  Future<void> _handleUserMessage(String text) async {
    messages.add(VoiceAssistantMessage(text, fromUser: true));
    _setState(VoiceAssistantState.thinking);

    try {
      final GenerateContentResponse response =
          await _chat.sendMessage(Content.text(text));
      final List<FunctionCall> calls = response.functionCalls.toList();

      if (calls.isEmpty) {
        final String reply = response.text?.trim().isNotEmpty == true
            ? response.text!.trim()
            : "Sorry, I didn't catch that. Could you say it again?";
        await _speak(reply);
        return;
      }

      final List<FunctionResponse> functionResponses = [];
      String? fallbackReply;
      for (final FunctionCall call in calls) {
        final String result = await _executeFunction(call.name, call.args);
        fallbackReply ??= result;
        functionResponses.add(FunctionResponse(call.name, {'result': result}));
      }

      final GenerateContentResponse followUp =
          await _chat.sendMessage(Content.functionResponses(functionResponses));
      final String reply = followUp.text?.trim().isNotEmpty == true
          ? followUp.text!.trim()
          : (fallbackReply ?? 'Done.');
      await _speak(reply);
    } on FirebaseAIException catch (error) {
      debugPrint('VoiceAssistantService Gemini error: $error');
      await _speak(
        'The AI assistant is not available right now. Make sure the Gemini '
        'API is enabled for this app in the Firebase console.',
      );
    } catch (error) {
      debugPrint('VoiceAssistantService error: $error');
      await _speak('Sorry, something went wrong. Please try again.');
    }
  }

  Future<String> _executeFunction(String name, Map<String, Object?> args) async {
    final NavigatorState? nav = navigatorKey.currentState;
    if (nav == null) return 'Could not perform that action right now.';

    switch (name) {
      case 'start_maize_scan':
        _runMaizeScanFlow(nav);
        return 'Opening the camera — go ahead and take a photo of the maize.';
      case 'start_strip_test':
        _runStripTestFlow(nav);
        return 'Opening the camera for the test-strip scan.';
      case 'go_home':
        nav.pushNamedAndRemoveUntil('/home', (route) => false);
        return 'Back on the home screen.';
      case 'open_history':
        nav.push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
        return 'Opened your scan history.';
      case 'open_notifications':
        nav.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        return 'Opened notifications.';
      case 'open_profile':
        nav.push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
        return 'Opened your profile.';
      case 'open_settings':
        nav.pushNamed('/settings');
        return 'Opened settings.';
      case 'open_legal_document':
        final bool isPrivacy = args['document'] == 'privacy';
        nav.push(MaterialPageRoute(
          builder: (_) => LegalDocumentScreen(
            title: isPrivacy ? 'Privacy Policy' : 'Terms of Service',
            body: isPrivacy ? kPrivacyPolicyText : kTermsOfServiceText,
          ),
        ));
        return 'Opened the ${isPrivacy ? 'privacy policy' : 'terms of service'}.';
      case 'describe_weather':
        return _describeWeather();
      case 'summarize_recent_scans':
        return _summarizeRecentScans();
      default:
        return "I don't know how to do that yet.";
    }
  }

  // Camera capture itself needs a physical shutter tap and a manual
  // retake/use-photo review (see CameraCaptureScreen) — there's no way to
  // automate that from here, so this only opens the screen and, once the
  // user hands back a photo, continues the same push-to-analysis flow
  // HomeScreen._onMaizeScanTap uses. Deliberately not awaited by the caller
  // so the spoken "opening the camera" reply isn't delayed by the wait for
  // the user to actually take the photo.
  void _runMaizeScanFlow(NavigatorState nav) {
    LocationService().getCurrentPlaceName().then((String? location) {
      nav.pushNamed('/camera').then((Object? photo) {
        if (photo is! XFile) return;
        nav.pushNamed(
          '/analysis',
          arguments: AnalysisScreenArgs(
            photo: photo,
            location: location,
            fromVoiceAssistant: true,
          ),
        );
      });
    });
  }

  void _runStripTestFlow(NavigatorState nav) {
    LocationService().getCurrentPlaceName().then((String? location) {
      nav.pushNamed('/stripCamera').then((Object? result) {
        if (result is! StripCaptureResult) return;
        nav.pushNamed(
          '/stripAnalysis',
          arguments: StripAnalysisScreenArgs(
            photo: result.photo,
            cropType: result.cropType,
            location: location,
          ),
        );
      });
    });
  }

  Future<String> _describeWeather() async {
    final LocationResult? location = await LocationService().getCurrentLocation();
    if (location == null) {
      return "I couldn't determine your location to check the weather.";
    }
    final WeatherInfo? weather = await WeatherService()
        .getCurrentWeather(location.latitude, location.longitude);
    if (weather == null) {
      return "The weather service isn't responding right now.";
    }
    final String place = location.placeName ?? 'your location';
    return 'In $place it is currently ${weather.temperatureC.round()} degrees '
        'Celsius and ${weather.condition.toLowerCase()}.';
  }

  // Mirrors the healthy/risky classification HomeScreen._isRiskyDoc uses for
  // the Recent Scans list, kept in sync manually since that method is
  // private to HomeScreen.
  static bool _isRiskyDoc(Map<String, dynamic> data) {
    if (data['testType'] == 'chemical') {
      final num ppb = (data['ppbValue'] ?? 0) as num;
      final num limit = (data['safeLimitPpb'] ?? 0) as num;
      return ppb > limit;
    }
    final String label = (data['label'] ?? '').toString();
    return RegExp(r'mold|aflatox|contamin|infect|positive', caseSensitive: false)
            .hasMatch(label) &&
        !RegExp(r'ld|healthy|clean|safe|negative', caseSensitive: false)
            .hasMatch(label);
  }

  Future<String> _summarizeRecentScans() async {
    final QuerySnapshot snapshot = await FirestoreService().getUserScanHistory().first;
    if (snapshot.docs.isEmpty) {
      return "There aren't any scans on record yet.";
    }
    int healthy = 0;
    int risky = 0;
    for (final doc in snapshot.docs) {
      if (_isRiskyDoc(doc.data() as Map<String, dynamic>)) {
        risky++;
      } else {
        healthy++;
      }
    }
    return 'There are ${snapshot.docs.length} scans on record: $healthy healthy '
        'and $risky flagged as risky.';
  }

  Future<void> _speak(String text) async {
    messages.add(VoiceAssistantMessage(text, fromUser: false));
    _setState(VoiceAssistantState.speaking);
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}
