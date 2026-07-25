import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/voice_assistant_service.dart';
import '../widgets/ai_animation.dart';

class VoiceAssistantScreen extends StatelessWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoiceAssistantService()..init(),
      child: const _VoiceAssistantView(),
    );
  }
}

class _VoiceAssistantView extends StatelessWidget {
  const _VoiceAssistantView();

  Color _bubbleColor(bool fromUser) =>
      fromUser ? AppColors.primary : AppColors.primaryContainer;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final VoiceAssistantService assistant = context
        .watch<VoiceAssistantService>();
    final bool isListening = assistant.state == VoiceAssistantState.listening;
    final bool isBusy = assistant.state != VoiceAssistantState.idle;

    return Scaffold(
      backgroundColor: AppColors.t95,
      appBar: AppBar(
        backgroundColor: AppColors.t95,
        title: Text(
          l10n.voiceAssistantTitle,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(
            tooltip: assistant.voiceGender == VoiceGender.male
                ? l10n.voiceAssistantVoiceMale
                : l10n.voiceAssistantVoiceFemale,
            icon: Icon(
              assistant.voiceGender == VoiceGender.male
                  ? Icons.man
                  : Icons.woman,
              color: AppColors.primary,
            ),
            onPressed: () => assistant.setVoiceGender(
              assistant.voiceGender == VoiceGender.male
                  ? VoiceGender.female
                  : VoiceGender.male,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/ai_screen.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  l10n.voiceAssistantEnglishOnlyNotice,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Expanded(
                child: assistant.messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            l10n.voiceAssistantHint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: assistant.messages.length,
                        itemBuilder: (context, index) {
                          final VoiceAssistantMessage message =
                              assistant.messages[index];
                          return Align(
                            alignment: message.fromUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: _bubbleColor(message.fromUser),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message.text,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (isBusy)
                SizedBox(
                  height: 140,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: const AIAnimation(),
                  ),
                ),
              if (assistant.partialTranscript.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Text(
                    assistant.partialTranscript,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: () {
                    if (isListening) {
                      assistant.stopListening();
                    } else if (assistant.state == VoiceAssistantState.idle) {
                      assistant.startListening();
                    }
                  },
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: isListening
                        ? AppColors.error
                        : AppColors.primary,
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
