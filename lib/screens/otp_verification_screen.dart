import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _resendCooldownSeconds = 60;

  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendSecondsLeft = _resendCooldownSeconds;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendSecondsLeft = _resendCooldownSeconds);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft -= 1);
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _resendCode() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _isResending = true);
    try {
      await FirebaseFunctions.instance
          .httpsCallable('requestPasswordResetOtp')
          .call({'email': widget.email});
      if (mounted) _startResendCooldown();
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        _showError(
          e.code == 'resource-exhausted'
              ? l10n.pleaseWaitBeforeResend
              : l10n.errorOccurredTryAgain,
        );
      }
    } catch (_) {
      if (mounted) _showError(l10n.errorOccurredTryAgain);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _verifyAndReset() async {
    if (!_formKey.currentState!.validate()) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    setState(() => _isVerifying = true);
    try {
      await FirebaseFunctions.instance
          .httpsCallable('verifyPasswordResetOtp')
          .call({
        'email': widget.email,
        'otp': _otpController.text.trim(),
        'newPassword': _newPasswordController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.passwordUpdatedSuccessfully,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF1F4A2C),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        final String message = switch (e.code) {
          'deadline-exceeded' => l10n.codeExpired,
          'not-found' => l10n.codeExpired,
          'resource-exhausted' => l10n.tooManyAttempts,
          'invalid-argument' => l10n.incorrectCode,
          _ => l10n.errorOccurredTryAgain,
        };
        _showError(message);
      }
    } catch (_) {
      if (mounted) _showError(l10n.errorOccurredTryAgain);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.logoCream,
      appBar: AppBar(
        backgroundColor: AppColors.logoCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: AppColors.primaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.otpScreenTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.otpInstructions(widget.email),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.primaryContainer,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: l10n.otpLabel,
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterOtp;
                    }
                    if (value.trim().length != 6) {
                      return l10n.otpInvalidLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryContainer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? l10n.passwordMin6Chars : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.confirmNewPassword,
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryContainer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v != _newPasswordController.text
                      ? l10n.passwordsDoNotMatch
                      : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyAndReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 2,
                    ),
                    child: _isVerifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10n.verifyAndReset,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: (_resendSecondsLeft > 0 || _isResending)
                      ? null
                      : _resendCode,
                  child: Text(
                    _resendSecondsLeft > 0
                        ? l10n.resendCodeIn(_resendSecondsLeft)
                        : l10n.resendCode,
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
