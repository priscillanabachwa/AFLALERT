import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/firestore_service.dart';
import '../utils/user_initials.dart';
import 'settings_screen.dart';

// ─────────────────────────────────────────────
//  THEME TOKENS — aliased to the shared AppColors palette
//  (same theme as the registration screen) plus a couple of
//  light tints derived from it that AppColors doesn't define.
// ─────────────────────────────────────────────
const kGreen = AppColors.primaryContainer;
const kGreenLight = Color(0xFFE8F5EE);
const kRed = AppColors.error;
const kRedLight = AppColors.errorLight;
const kGrey = AppColors.grey;
const kBg = AppColors.t95;
const kCard = AppColors.surface;

// ─────────────────────────────────────────────
//  PROFILE SCREEN
// ─────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<dynamic>? _profileSub;

  bool _isLoadingProfile = true;

  String _userName = '';
  String _userPhone = '';
  String _userLocation = '';
  String _userType = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _profileSub = _firestoreService.getUserProfile().listen((doc) {
      final profile = doc.data();
      setState(() {
        _userName = profile?['fullName'] as String? ?? user?.displayName ?? 'Your account';
        _userPhone = profile?['phone'] as String? ?? '';
        _userLocation = profile?['district'] as String? ?? '';
        _userType = (profile?['userType'] as String? ?? '').toUpperCase();
        _isLoadingProfile = false;
      });
    });
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(child: CircularProgressIndicator(color: kGreen)),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(),
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
        'Profile',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
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
                    getInitials(_userName),
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
