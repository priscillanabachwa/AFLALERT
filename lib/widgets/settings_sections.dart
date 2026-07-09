import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_widgets.dart';

class SettingsSections extends StatefulWidget {
  const SettingsSections({super.key});

  @override
  State<SettingsSections> createState() => _SettingsSectionsState();
}

class _SettingsSectionsState extends State<SettingsSections> {
  bool notifications = true;
  bool autoSaveResults = true;
  bool darkMode = false;
  bool appLock = false;

  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      notifications = prefs?.getBool('notificationsEnabled') ?? true;
      autoSaveResults = prefs?.getBool('autoSaveResults') ?? true;
      darkMode = prefs?.getBool('darkModeEnabled') ?? false;
      appLock = prefs?.getBool('appLockEnabled') ?? false;
    });
  }

  Future<void> save(String key, bool value) async {
    await prefs?.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------------- APP PREFERENCES ----------------

        const SectionHeader(
          title: 'App Preferences',
        ),

        SettingsCard(
          children: [
            SwitchListTile(
              value: notifications,
              activeColor: primaryGreen,
              contentPadding: EdgeInsets.zero,
              title: const Text('Notifications'),
              subtitle: const Text(
                'Receive alerts about scan results.',
              ),
              onChanged: (value) async {
                setState(() => notifications = value);
                await save('notificationsEnabled', value);
              },
            ),

            SwitchListTile(
              value: autoSaveResults,
              activeColor: primaryGreen,
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-save Results'),
              subtitle: const Text(
                'Automatically save completed scan reports.',
              ),
              onChanged: (value) async {
                setState(() => autoSaveResults = value);
                await save('autoSaveResults', value);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Auto-save enabled.'
                          : 'Auto-save disabled.',
                    ),
                  ),
                );
              },
            ),

            SwitchListTile(
              value: darkMode,
              activeColor: primaryGreen,
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark Mode'),
              subtitle: const Text(
                'Use a dark appearance.',
              ),
              onChanged: (value) async {
                setState(() => darkMode = value);
                await save('darkModeEnabled', value);
              },
            ),
          ],
        ),
                const SizedBox(height: 20),

        // ---------------- PRIVACY & SECURITY ----------------

        const SectionHeader(
          title: 'Privacy & Security',
        ),

        SettingsCard(
          children: [
            SwitchListTile(
              value: appLock,
              activeColor: primaryGreen,
              contentPadding: EdgeInsets.zero,
              title: const Text('App Lock'),
              subtitle: const Text(
                'Require authentication before opening the app.',
              ),
              onChanged: (value) async {
                setState(() => appLock = value);
                await save('appLockEnabled', value);
              },
            ),

            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy coming soon.'),
                  ),
                );
              },
            ),

            SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms of Service coming soon.'),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ---------------- STORAGE ----------------

        const SectionHeader(
          title: 'Storage',
        ),

        SettingsCard(
          children: [
            SettingsTile(
              icon: Icons.folder_outlined,
              title: 'Downloaded Reports',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/downloadedReports',
                );
              },
            ),

            SettingsTile(
              icon: Icons.delete_outline,
              title: 'Clear Cached Data',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully.'),
                  ),
                );
              },
            ),
          ],
        ),
                const SizedBox(height: 20),

        // ---------------- HELP & SUPPORT ----------------

        const SectionHeader(
          title: 'Help & Support',
        ),

        SettingsCard(
          children: [
            SettingsTile(
              icon: Icons.help_outline,
              title: 'FAQ',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('FAQ coming soon.'),
                  ),
                );
              },
            ),

            SettingsTile(
              icon: Icons.mail_outline,
              title: 'Contact Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support feature coming soon.'),
                  ),
                );
              },
            ),

            SettingsTile(
              icon: Icons.info_outline,
              title: 'About AflAlert',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'AflAlert',
                  applicationVersion: '1.0.0',
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}