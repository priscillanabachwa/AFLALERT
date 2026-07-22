import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/morning_alert_service.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ---- Palette matched to the shared AppColors theme (registration screen) ----
  static const Color darkGreen = AppColors.primary;
  static const Color primaryGreen = AppColors.primaryContainer;
  static const Color background = AppColors.t95;

  // ---- Preference state ----
  bool _notificationsEnabled = true;
  bool _isLoadingPrefs = true;
  Locale _locale = const Locale('en');

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Preferences are stored locally so toggles persist between app launches
  // without needing a network call every time the settings screen opens.
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _locale = Locale(prefs.getString('languageCode') ?? 'en');
      _isLoadingPrefs = false;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  void _pickLanguage() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'en',
              groupValue: _locale.languageCode,
              title: Text(l10n.englishLanguageName),
              activeColor: primaryGreen,
              onChanged: (code) => _setLanguage(dialogContext, code!),
            ),
            RadioListTile<String>(
              value: 'lg',
              groupValue: _locale.languageCode,
              title: Text(l10n.lugandaLanguageName),
              activeColor: primaryGreen,
              onChanged: (code) => _setLanguage(dialogContext, code!),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setLanguage(BuildContext dialogContext, String code) async {
    Navigator.pop(dialogContext);
    final Locale newLocale = Locale(code);
    setState(() => _locale = newLocale);
    if (mounted) AflAlert.setLocale(context, newLocale);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPrefs) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String languageName =
        _locale.languageCode == 'lg' ? l10n.lugandaLanguageName : l10n.englishLanguageName;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: darkGreen),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.settingsTitle,
                  style: const TextStyle(color: darkGreen, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---------------- App preferences ----------------
            _SectionHeader(title: l10n.appPreferences),
            _SettingsCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: primaryGreen,
                  title: Text(l10n.notifications, style: const TextStyle(color: darkGreen)),
                  subtitle: Text(
                    l10n.notificationsSubtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 11.5),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    _setPref('notificationsEnabled', value);
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.language,
                  label: l10n.language,
                  trailingText: languageName,
                  onTap: _pickLanguage,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---------------- Legal ----------------
            _SectionHeader(title: l10n.legal),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.gavel_outlined,
                  label: l10n.legal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LegalScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---------------- Help & support ----------------
            _SectionHeader(title: l10n.helpSupportSection),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.mail_outline,
                  label: l10n.contactSupport,
                  onTap: () {
                    // TODO: open mailto: link via url_launcher
                  },
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  label: l10n.aboutAflAlert,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'AflAlert',
                      applicationVersion: '1.0.0',
                      applicationLegalese: l10n.recommendationsSourced,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ---------------- Debug (debug builds only) ----------------
            if (kDebugMode) ...[
              _SectionHeader(title: 'Debug'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_active_outlined,
                    label: 'Test Morning Alert Now',
                    onTap: () async {
                      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
                      await MorningAlertService.testNow();
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Morning alert triggered — check your notifications.')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}

// ---- Small reusable pieces to keep the sections above consistent ----

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(color: Colors.transparent, child: Column(children: children)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(
        label,
        style: const TextStyle(color: _SettingsScreenState.darkGreen, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(trailingText!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }
}
