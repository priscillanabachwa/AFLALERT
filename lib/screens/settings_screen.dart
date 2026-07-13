import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
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
      _isLoadingPrefs = false;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPrefs) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

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
                const Text(
                  'Settings',
                  style: TextStyle(color: darkGreen, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---------------- App preferences ----------------
            _SectionHeader(title: 'App preferences'),
            _SettingsCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: primaryGreen,
                  title: const Text('Notifications', style: TextStyle(color: darkGreen)),
                  subtitle: const Text(
                    'Alerts about scan results and batch status',
                    style: TextStyle(color: Colors.grey, fontSize: 11.5),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    _setPref('notificationsEnabled', value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---------------- Legal ----------------
            _SectionHeader(title: 'Legal'),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.gavel_outlined,
                  label: 'Legal',
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
            _SectionHeader(title: 'Help & support'),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.mail_outline,
                  label: 'Contact support',
                  onTap: () {
                    // TODO: open mailto: link via url_launcher
                  },
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  label: 'About AflAlert',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'AflAlert',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          'Recommendations sourced from UNBS and MAAIF guidance.',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
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
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
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
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      onTap: onTap,
    );
  }
}
