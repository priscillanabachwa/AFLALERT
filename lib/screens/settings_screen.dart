import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  static const Color gold = AppColors.secondary;
  static const Color background = AppColors.t95;
  static const Color danger = AppColors.error;

  // ---- Preference state ----
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoSaveResults = true;
  bool _biometricLockEnabled = false;
  bool _isLoadingPrefs = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
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
      _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
      _autoSaveResults = prefs.getBool('autoSaveResults') ?? true;
      _biometricLockEnabled = prefs.getBool('biometricLockEnabled') ?? false;
      _isLoadingPrefs = false;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> _confirmAndSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Future<void> _confirmClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Clear cached data?'),
        content: const Text(
          'This removes locally cached scan history and images. Saved PDF reports on your device will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: hook up actual cache-clearing logic (e.g. clear a local
      // scans directory or Hive/sqflite box) once that storage layer exists.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

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

            // ---------------- Account ----------------
            _SectionHeader(title: 'Account'),
            _SettingsCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: gold,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Your account',
                    style: const TextStyle(color: darkGreen, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    user?.email ?? 'Not signed in',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const Divider(height: 20, color: Color(0xFFEDEDED)),
                _SettingsTile(
                  icon: Icons.person_outline,
                  label: 'Edit profile',
                  onTap: () {
                    // TODO: navigate to an edit-profile screen
                  },
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  label: 'Change password',
                  onTap: () {
                    // TODO: navigate to change-password flow
                  },
                ),
                _SettingsTile(
                  icon: Icons.logout,
                  label: 'Log out',
                  labelColor: danger,
                  iconColor: danger,
                  onTap: _confirmAndSignOut,
                ),
              ],
            ),
            const SizedBox(height: 24),

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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: primaryGreen,
                  title: const Text('Auto-save results', style: TextStyle(color: darkGreen)),
                  subtitle: const Text(
                    'Automatically save every scan result to your device',
                    style: TextStyle(color: Colors.grey, fontSize: 11.5),
                  ),
                  value: _autoSaveResults,
                  onChanged: (value) {
                    setState(() => _autoSaveResults = value);
                    _setPref('autoSaveResults', value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---------------- Appearance ----------------
            _SectionHeader(title: 'Appearance'),
            _SettingsCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: primaryGreen,
                  title: const Text('Dark mode', style: TextStyle(color: darkGreen)),
                  subtitle: const Text(
                    'Use a dark theme throughout the app',
                    style: TextStyle(color: Colors.grey, fontSize: 11.5),
                  ),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() => _darkModeEnabled = value);
                    _setPref('darkModeEnabled', value);
                    // TODO: wire this into your app-level ThemeMode, e.g. via
                    // a ThemeNotifier/Provider read at the MaterialApp root.
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---------------- Privacy & security ----------------
            _SectionHeader(title: 'Privacy & security'),
            _SettingsCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: primaryGreen,
                  title: const Text('App lock', style: TextStyle(color: darkGreen)),
                  subtitle: const Text(
                    'Require fingerprint or PIN to open the app',
                    style: TextStyle(color: Colors.grey, fontSize: 11.5),
                  ),
                  value: _biometricLockEnabled,
                  onChanged: (value) {
                    setState(() => _biometricLockEnabled = value);
                    _setPref('biometricLockEnabled', value);
                    // TODO: hook up local_auth for real biometric enforcement.
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

            // ---------------- Storage & data ----------------
            _SectionHeader(title: 'Storage & data'),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.folder_outlined,
                  label: 'Manage saved reports',
                  onTap: () {
                    // TODO: navigate to a saved-reports list screen
                  },
                ),
                _SettingsTile(
                  icon: Icons.delete_sweep_outlined,
                  label: 'Clear cached data',
                  onTap: _confirmClearCache,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---------------- Help & support ----------------
            _SectionHeader(title: 'Help & support'),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  label: 'FAQ',
                  onTap: () {
                    // TODO: navigate to an FAQ screen
                  },
                ),
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
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? Colors.grey, size: 20),
      title: Text(
        label,
        style: TextStyle(color: labelColor ?? _SettingsScreenState.darkGreen, fontSize: 14),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      onTap: onTap,
    );
  }
}