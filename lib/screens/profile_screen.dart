import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  THEME TOKENS
// ─────────────────────────────────────────────
const kGreen = Color(0xFF1A5C38);
const kGreenLight = Color(0xFFE8F5EE);
const kYellow = Color(0xFFF5C518);
const kRed = Color(0xFFD62B2B);
const kRedLight = Color(0xFFFFEEEE);
const kGrey = Color(0xFF8A8A8A);
const kBg = Color(0xFFF6F7F9);
const kCard = Colors.white;

// ─────────────────────────────────────────────
//  PROFILE SCREEN
// ─────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;
  String _selectedLanguage = 'English';

  // ── dummy user data (replace with Firebase later)
  final String _userName = 'John Doe';
  final String _userEmail = 'johndoe@gmail.com';
  final String _userPhone = '+256 700 123 456';
  final String _userLocation = 'Kampala, Uganda';
  final String _userType = 'FARMER';
  final int _totalScans = 128;
  final int _healthyScans = 112;
  final int _detectedScans = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(),
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildSectionLabel('ACCOUNT SETTINGS'),
                _buildSettingsCard(),
                const SizedBox(height: 20),
                _buildSectionLabel('ACCOUNT INFO'),
                _buildInfoCard(),
                const SizedBox(height: 20),
                _buildLogoutButton(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── sliver app bar ───────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: kCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Aflatoxin Detector',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _showEditProfile,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: kGreen,
              backgroundImage: null,
              child: const Text(
                'JD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── profile header ───────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      color: kCard,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          // avatar with edit button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGreen, width: 3),
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: kGreenLight,
                  child: Text(
                    _getInitials(_userName),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kGreen,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showEditProfile,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // name
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          // location + user type badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: kGrey),
              const SizedBox(width: 4),
              Text(
                _userLocation,
                style: const TextStyle(fontSize: 13, color: kGrey),
              ),
              const SizedBox(width: 10),
              const Text('•', style: TextStyle(color: kGrey)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kGreenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _userType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: kGreen,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── stats row ────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: _totalScans.toString(),
              label: 'Total Scans',
              icon: Icons.bar_chart_rounded,
              iconColor: kGreen,
              bgColor: kGreenLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: _healthyScans.toString(),
              label: 'Healthy Scans',
              icon: Icons.check_circle_outline,
              iconColor: kGreen,
              bgColor: kGreenLight,
              highlighted: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: _detectedScans.toString(),
              label: 'Detected Scans',
              icon: Icons.warning_amber_rounded,
              iconColor: kRed,
              bgColor: kRedLight,
            ),
          ),
        ],
      ),
    );
  }

  // ── section label ────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: kGrey,
          ),
        ),
      ),
    );
  }

  // ── settings card ────────────────────────────
  Widget _buildSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // dark mode toggle
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            label: 'Dark Mode',
            trailing: Switch(
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
              activeThumbColor: kGreen,
            ),
          ),
          _buildDivider(),

          // language
          _SettingsTile(
            icon: Icons.language_outlined,
            label: 'Language',
            trailing: GestureDetector(
              onTap: _showLanguageSheet,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedLanguage,
                    style: const TextStyle(color: kGrey, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: kGrey, size: 18),
                ],
              ),
            ),
            onTap: _showLanguageSheet,
          ),
          _buildDivider(),

          // privacy
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy',
            trailing: const Icon(Icons.chevron_right, color: kGrey, size: 18),
            onTap: () => _showComingSoon('Privacy'),
          ),
          _buildDivider(),

          // help & support
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            trailing: const Icon(Icons.chevron_right, color: kGrey, size: 18),
            onTap: () => _showComingSoon('Help & Support'),
          ),
        ],
      ),
    );
  }

  // ── account info card ────────────────────────
  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _userEmail,
          ),
          _buildDivider(),
          _InfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _userPhone,
          ),
          _buildDivider(),
          _InfoTile(
            icon: Icons.location_on_outlined,
            label: 'District',
            value: _userLocation,
          ),
        ],
      ),
    );
  }

  // ── logout button ────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _confirmLogout,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: kRedLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kRed.withAlpha((0.3 * 255).round())),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: kRed, size: 20),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  color: kRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── divider ──────────────────────────────────
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
      indent: 56,
    );
  }

  // ── bottom navigation ────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: kGreen,
      unselectedItemColor: kGrey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: kCard,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
      onTap: (i) {
        // Connect to router when linking screens
      },
    );
  }

  // ── helpers ──────────────────────────────────
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditProfileSheet(
        name: _userName,
        phone: _userPhone,
        location: _userLocation,
      ),
    );
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LanguageSheet(
        current: _selectedLanguage,
        onSelected: (lang) {
          setState(() => _selectedLanguage = lang);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout from AflaScan?',
          style: TextStyle(color: kGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login when screens are linked
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: kRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STAT CARD WIDGET
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final bool highlighted;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: highlighted ? kGreenLight : kCard,
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? Border.all(
                color: kGreen.withAlpha((0.3 * 255).round()),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: kGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SETTINGS TILE WIDGET
// ─────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: kGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INFO TILE WIDGET
// ─────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: kGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EDIT PROFILE BOTTOM SHEET
// ─────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final String name;
  final String phone;
  final String location;

  const _EditProfileSheet({
    required this.name,
    required this.phone,
    required this.location,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _locationCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _phoneCtrl = TextEditingController(text: widget.phone);
    _locationCtrl = TextEditingController(text: widget.location);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildField('Full Name', _nameCtrl, Icons.person_outline),
          const SizedBox(height: 12),
          _buildField('Phone Number', _phoneCtrl, Icons.phone_outlined),
          const SizedBox(height: 12),
          _buildField('Location', _locationCtrl, Icons.location_on_outlined),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: kGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kGrey,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: kGreen, size: 18),
            filled: true,
            fillColor: kBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  LANGUAGE BOTTOM SHEET
// ─────────────────────────────────────────────
class _LanguageSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelected;

  const _LanguageSheet({required this.current, required this.onSelected});

  static const _languages = [
    'English',
    'Luganda',
    'Swahili',
    'Runyankore',
    'Ateso',
    'Luo',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Select Language',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._languages.map(
            (lang) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: current == lang ? kGreenLight : kBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.language,
                  color: current == lang ? kGreen : kGrey,
                  size: 18,
                ),
              ),
              title: Text(
                lang,
                style: TextStyle(
                  fontWeight: current == lang
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: current == lang ? kGreen : Colors.black87,
                ),
              ),
              trailing: current == lang
                  ? const Icon(Icons.check_circle, color: kGreen, size: 20)
                  : null,
              onTap: () => onSelected(lang),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ENTRY POINT FOR TESTING
// ─────────────────────────────────────────────
void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: ProfileScreen()),
  );
}
