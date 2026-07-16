import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/app_notification.dart';
import '../services/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/local_notification_service.dart';
import '../services/notification_center.dart';
import '../l10n/app_localizations.dart';
import 'legal_document_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedDistrict;
  String? _selectedUserType;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  final List<String> districts = [
    'Kampala',
    'Wakiso',
    'Mukono',
    'Jinja',
    'Masaka',
    'Mbarara',
    'Fort Portal',
    'Gulu',
    'Lira',
    'Soroti',
    'Mbale',
    'Kabale',
    'Kisoro',
    'Hoima',
    'Masindi',
    'Tororo',
    'Kumi',
    'Sironko',
    'Pallisa',
    'Bulambuli',
  ];

  final List<String> userTypes = [
    'Farmer',
    'Trader',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAgreeToTerms),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.registerWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (result is String) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: const Color(0xFFDC2626)),
      );
      return;
    }

    await _firestoreService.createUserProfile(
      uid: result.uid,
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      district: _selectedDistrict!,
      userType: _selectedUserType!,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    final String email = _emailController.text.trim();
    final String accountCreatedBody = l10n.accountCreatedBody(email);
    NotificationCenter.instance.add(
      AppNotification(
        title: l10n.accountCreatedTitle,
        description: accountCreatedBody,
        icon: Icons.person_add_alt_1,
        iconColor: AppColors.primaryContainer,
        iconBackground: const Color(0xFFE8F5EE),
        category: NotificationCategory.update,
        unread: true,
      ),
    );
    LocalNotificationService.instance.show(
      title: l10n.accountCreatedTitle,
      body: accountCreatedBody,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.registrationSuccessful),
        backgroundColor: const Color(0xFF059669),
      ),
    );

    Navigator.pushReplacementNamed(context, '/home');
  }

  String _userTypeLabel(AppLocalizations l10n, String value) =>
      value == 'Farmer' ? l10n.farmer : l10n.trader;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.logoCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo — background matches the cream baked into the artwork, so no square backing shows.
              SizedBox(
                width: 160,
                height: 160,
                child: Image.asset(
                  'lib/assets/images/aflalert_logo.png',
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                l10n.join,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: AppColors.primaryContainer,
                ),
              ),
              Text(
                'AflAlert',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryContainer,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.registerTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryContainer,
                ),
              ),

              const SizedBox(height: 40),

              // Registration Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.t95,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name Field
                      Text(
                        l10n.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: l10n.fullNameHint,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterFullName;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Email Field
                      Text(
                        l10n.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: l10n.emailHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterEmail;
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return l10n.pleaseEnterValidEmail;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Phone Number Field
                      Text(
                        l10n.phoneNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: l10n.phoneHint,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterPhone;
                          }
                          if (value.length < 9) {
                            return l10n.pleaseEnterValidPhone;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // User Type Dropdown
                      Text(
                        l10n.userType,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedUserType,
                        decoration: InputDecoration(
                          hintText: l10n.selectYourRole,
                          prefixIcon: Icon(Icons.work_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide:
                                BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide:
                                BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide:
                                BorderSide(color: AppColors.primaryContainer, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: userTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(_userTypeLabel(l10n, value)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedUserType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseSelectUserType;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // District Dropdown
                      Text(
                        l10n.district,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDistrict,
                        decoration: InputDecoration(
                          hintText: l10n.selectYourDistrict,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide:
                                BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide:
                                BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide:
                                BorderSide(color: AppColors.primaryContainer, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: districts.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDistrict = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseSelectDistrict;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      Text(
                        l10n.password,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: l10n.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterPassword;
                          }
                          if (value.length < 8) {
                            return l10n.passwordMinLength;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Confirm Password Field
                      Text(
                        l10n.confirmPassword,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: l10n.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseConfirmPassword;
                          }
                          if (value != _passwordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Terms & Conditions Checkbox
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: l10n.agreeToOurPrefix,
                                    style: const TextStyle(
                                      color: AppColors.primaryContainer,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text: l10n.termsOfService,
                                    style: GoogleFonts.inter(
                                      color: AppColors.primaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LegalDocumentScreen(
                                              title: 'Terms of Service',
                                              body: kTermsOfServiceText,
                                            ),
                                          ),
                                        );
                                      },
                                  ),
                                  TextSpan(
                                    text: l10n.andWord,
                                    style: const TextStyle(
                                      color: AppColors.primaryContainer,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text: l10n.privacyPolicy,
                                    style: GoogleFonts.inter(
                                      color: AppColors.primaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LegalDocumentScreen(
                                              title: 'Privacy Policy',
                                              body: kPrivacyPolicyText,
                                            ),
                                          ),
                                        );
                                      },
                                  ),
                                  const TextSpan(
                                    text: '.',
                                    style: TextStyle(
                                      color: AppColors.primaryContainer,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Register Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          backgroundColor: AppColors.primaryContainer,
                          disabledBackgroundColor:
                              AppColors.primaryContainer.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.register,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: const TextStyle(color: AppColors.primaryContainer),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      l10n.loginHere,
                      style: TextStyle(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
