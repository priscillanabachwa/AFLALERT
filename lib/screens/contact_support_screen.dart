import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/firestore_service.dart';
import '../utils/contact_support.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  static const List<String> _categoryKeys = [
    'bug',
    'scan',
    'account',
    'feedback',
    'other',
  ];

  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = 'bug';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'scan':
        return l10n.contactSupportCategoryScan;
      case 'account':
        return l10n.contactSupportCategoryAccount;
      case 'feedback':
        return l10n.contactSupportCategoryFeedback;
      case 'other':
        return l10n.contactSupportCategoryOther;
      case 'bug':
      default:
        return l10n.contactSupportCategoryBug;
    }
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final bool success = await _firestoreService.submitSupportRequest(
      category: _selectedCategory,
      message: _messageController.text.trim(),
      contactEmail: _emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactSupportSuccess)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactSupportError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.t95,
      appBar: AppBar(
        backgroundColor: AppColors.t95,
        title: Text(
          l10n.contactSupportScreenTitle,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.contactSupportIntro,
                style: const TextStyle(color: AppColors.grey, fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.contactSupportCategoryLabel,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in _categoryKeys)
                    ChoiceChip(
                      label: Text(_categoryLabel(l10n, key)),
                      selected: _selectedCategory == key,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _selectedCategory = key),
                      labelStyle: TextStyle(
                        color: _selectedCategory == key ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFE7E3DA),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _FieldLabel(l10n.contactSupportEmailLabel),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration(l10n.contactSupportEmailHint),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return l10n.contactSupportEmailRequired;
                  if (!trimmed.contains('@') || !trimmed.contains('.')) {
                    return l10n.contactSupportEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _FieldLabel(l10n.contactSupportMessageLabel),
              const SizedBox(height: 6),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: _fieldDecoration(l10n.contactSupportMessageHint),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return l10n.contactSupportMessageRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submit(l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(l10n.contactSupportSubmitting),
                          ],
                        )
                      : Text(l10n.contactSupportSubmit, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      l10n.contactSupportEmailDirectly,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grey, fontSize: 12.5),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => launchSupportEmail(context),
                      child: const Text(
                        supportEmail,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}
