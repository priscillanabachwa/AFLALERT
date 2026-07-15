import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists "remember me" login credentials for multiple accounts so a
/// returning user can pick a saved email on the login screen and have their
/// password filled in automatically, instead of retyping it every time.
class RememberedAccountsService {
  RememberedAccountsService._();
  static final RememberedAccountsService instance = RememberedAccountsService._();

  static const String _storageKey = 'remembered_accounts';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Returns saved email/password pairs, ordered oldest-first so the most
  /// recently saved account is always last.
  Future<Map<String, String>> getAccounts() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  Future<void> saveAccount(String email, String password) async {
    final accounts = await getAccounts();
    accounts.remove(email);
    accounts[email] = password;
    await _storage.write(key: _storageKey, value: jsonEncode(accounts));
  }

  Future<void> removeAccount(String email) async {
    final accounts = await getAccounts();
    if (accounts.remove(email) == null) return;
    await _storage.write(key: _storageKey, value: jsonEncode(accounts));
  }
}
