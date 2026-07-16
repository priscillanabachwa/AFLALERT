import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../services/firebase_storage.dart';
import '../services/firestore_service.dart';
import '../services/local_notification_service.dart';
import '../services/notification_center.dart';
import '../services/remembered_accounts_service.dart';
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
  String _userPhotoUrl = '';

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
        _userPhotoUrl = profile?['photoUrl'] as String? ?? user?.photoURL ?? '';
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
                _buildAccountSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
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
        icon: const Icon(Icons.arrow_back, color: kGreen),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.profile,
        style: const TextStyle(
          color: kGreen,
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
                  backgroundImage: _userPhotoUrl.isNotEmpty ? NetworkImage(_userPhotoUrl) : null,
                  child: _userPhotoUrl.isEmpty
                      ? Text(
                          getInitials(_userName),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: kGreen,
                          ),
                        )
                      : null,
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

  // ── account section (change password / logout) ──
  Widget _buildAccountSection() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline, color: kGreen, size: 20),
                title: Text(
                  l10n.changePassword,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_right, color: kGrey, size: 18),
                onTap: _showChangePassword,
              ),
              const Divider(height: 1, color: Color(0xFFEDEDED)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout_rounded, color: kRed, size: 20),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: kRed, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
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
        photoUrl: _userPhotoUrl,
      ),
    );
  }

  void _showChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _confirmLogout() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.logout,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.logoutConfirm,
          style: const TextStyle(color: kGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(color: kGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.logout, style: const TextStyle(color: Colors.white)),
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
  final String photoUrl;

  const _EditProfileSheet({
    required this.name,
    required this.phone,
    required this.location,
    required this.photoUrl,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _locationCtrl;
  File? _pickedImage;
  bool _removePhoto = false;
  bool _isSaving = false;

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

  bool get _hasPhotoToRemove =>
      _pickedImage != null || (widget.photoUrl.isNotEmpty && !_removePhoto);

  Future<void> _pickImage() async {
    final bool hasPhoto = _hasPhotoToRemove;
    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: kGreen),
              title: Text(AppLocalizations.of(context)!.takeAPhoto),
              onTap: () => _pickFrom(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: kGreen),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
              onTap: () => _pickFrom(sheetContext, ImageSource.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: kRed),
                title: const Text('Remove Photo', style: TextStyle(color: kRed)),
                onTap: () {
                  _clearPhoto();
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _removePhoto = false;
      });
    }
  }

  void _clearPhoto() {
    setState(() {
      _pickedImage = null;
      _removePhoto = true;
    });
  }

  // Picking can throw (e.g. camera/gallery permission denied) — without a
  // catch here, that exception previously left the sheet open with no
  // feedback since Navigator.pop(sheetContext, file) was never reached.
  Future<void> _pickFrom(BuildContext sheetContext, ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (sheetContext.mounted) Navigator.pop(sheetContext, file);
    } catch (_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? l10n.cameraAccessDenied
                : l10n.photoLibraryAccessDenied,
          ),
          backgroundColor: kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fullNameCannotBeEmpty),
          backgroundColor: kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    String? photoUrl;
    if (_pickedImage != null) {
      final user = FirebaseAuth.instance.currentUser;
      photoUrl = user != null
          ? await _storageService.uploadProfileImage(_pickedImage!, user.uid)
          : null;
      if (photoUrl == null) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotUploadProfilePicture),
            backgroundColor: kRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (_removePhoto) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) await _storageService.deleteProfileImage(user.uid);
    }

    final success = await _firestoreService.updateUserProfile(
      fullName: name,
      phone: _phoneCtrl.text.trim(),
      district: _locationCtrl.text.trim(),
      removePhoto: _removePhoto,
      photoUrl: photoUrl,
    );
    if (!mounted) return;

    if (success) {
      NotificationCenter.instance.add(
        AppNotification(
          title: 'Profile Updated',
          description: 'Your account details were updated successfully.',
          icon: Icons.person_add_alt_1,
          iconColor: kGreen,
          iconBackground: kGreenLight,
          category: NotificationCategory.update,
          unread: true,
        ),
      );
      LocalNotificationService.instance.show(
        title: 'Profile Updated',
        body: 'Your account details were updated successfully.',
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdatedSuccessfully),
          backgroundColor: kGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotUpdateProfile),
          backgroundColor: kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
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
          Text(
            l10n.editProfile,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: kGreenLight,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (!_removePhoto && widget.photoUrl.isNotEmpty)
                            ? NetworkImage(widget.photoUrl)
                            : null as ImageProvider?,
                    child: _pickedImage == null && (_removePhoto || widget.photoUrl.isEmpty)
                        ? Text(
                            getInitials(widget.name),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: kGreen,
                            ),
                          )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildField(l10n.fullName, _nameCtrl, Icons.person_outline),
          const SizedBox(height: 12),
          _buildField(l10n.phoneNumber, _phoneCtrl, Icons.phone_outlined),
          const SizedBox(height: 12),
          _buildField(l10n.locationField, _locationCtrl, Icons.location_on_outlined),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    l10n.saveChanges,
                    style: const TextStyle(
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
//  CHANGE PASSWORD BOTTOM SHEET
// ─────────────────────────────────────────────
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (user == null || email == null) {
        throw FirebaseAuthException(code: 'no-current-user');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: _currentCtrl.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newCtrl.text);

      // Keep "Remember me" in sync — otherwise the login screen would keep
      // auto-filling the now-stale old password and every future login
      // attempt would silently fail until the user noticed and retyped it.
      final Map<String, String> rememberedAccounts =
          await RememberedAccountsService.instance.getAccounts();
      if (rememberedAccounts.containsKey(email)) {
        await RememberedAccountsService.instance.saveAccount(email, _newCtrl.text);
      }

      NotificationCenter.instance.add(
        AppNotification(
          title: l10n.passwordChangedTitle,
          description: l10n.passwordChangedBody,
          icon: Icons.lock_reset,
          iconColor: kGreen,
          iconBackground: kGreenLight,
          category: NotificationCategory.update,
          unread: true,
          highPriority: true,
        ),
      );
      LocalNotificationService.instance.show(
        title: l10n.passwordChangedTitle,
        body: l10n.passwordChangedBody,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordUpdatedSuccessfully),
          backgroundColor: kGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = l10n.couldNotChangePassword;
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = l10n.currentPasswordIncorrect;
      } else if (e.code == 'weak-password') {
        message = l10n.newPasswordTooWeak;
      } else if (e.code == 'requires-recent-login') {
        message = l10n.pleaseLogOutAndBackIn;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: kRed, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Form(
        key: _formKey,
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
            Text(
              l10n.changePasswordTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              l10n.currentPassword,
              _currentCtrl,
              _obscureCurrent,
              () => setState(() => _obscureCurrent = !_obscureCurrent),
              validator: (v) => (v == null || v.isEmpty) ? l10n.enterCurrentPassword : null,
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              l10n.newPassword,
              _newCtrl,
              _obscureNew,
              () => setState(() => _obscureNew = !_obscureNew),
              validator: (v) =>
                  (v == null || v.length < 6) ? l10n.passwordMin6Chars : null,
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              l10n.confirmNewPassword,
              _confirmCtrl,
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) => v != _newCtrl.text ? l10n.passwordsDoNotMatch : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      l10n.updatePassword,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggleObscure, {
    required String? Function(String?) validator,
  }) {
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
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, color: kGreen, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: kGrey,
              ),
              onPressed: toggleObscure,
            ),
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
