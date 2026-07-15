import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_screen.dart';
import '../constants/app_colors.dart';
import '../services/firebase_auth.dart';
import '../services/remembered_accounts_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Added these controllers and variables right inside the State class
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // email -> password, for accounts saved via "Remember me" on a previous login.
  Map<String, String> _rememberedAccounts = {};

  @override
  void initState() {
    super.initState();
    _loadRememberedAccounts();
  }

  Future<void> _loadRememberedAccounts() async {
    final accounts = await RememberedAccountsService.instance.getAccounts();
    if (!mounted) return;
    setState(() {
      _rememberedAccounts = accounts;
      if (accounts.isNotEmpty) {
        final lastEmail = accounts.keys.last;
        _emailController.text = lastEmail;
        _passwordController.text = accounts[lastEmail]!;
        _rememberMe = true;
      }
    });
  }

  // Fills the form with a previously saved account so the user can just hit Login.
  void _selectRememberedAccount(String email) {
    final password = _rememberedAccounts[email];
    if (password == null) return;
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _rememberMe = true;
    });
  }

  Future<void> _forgetAccount(String email) async {
    await RememberedAccountsService.instance.removeAccount(email);
    if (!mounted) return;
    setState(() {
      _rememberedAccounts.remove(email);
      if (_emailController.text.trim() == email) {
        _passwordController.clear();
      }
    });
  }

  // Added this function to process the sign-in
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final result = await _authService.loginWithEmailAndPassword(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_rememberMe) {
      await RememberedAccountsService.instance.saveAccount(email, password);
    } else {
      await RememberedAccountsService.instance.removeAccount(email);
    }
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.logoCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
            children: [




              const SizedBox(height: 60),

              // Logo — background matches the cream baked into the artwork, so no square backing shows.
              SizedBox(
                width: 160,
                height: 160,
                child: Image.asset(
                  "lib/assets/images/aflalert_logo.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported_outlined, color: Colors.amber,size:40);
                  },

                ),
              ),
              

              const SizedBox(height: 12),

              Text(
                'AflAlert',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryContainer,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Precision diagnostics for a safer harvest.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryContainer,
                ),
              ),

              const SizedBox(height: 48),

              // Login Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.t95,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_rememberedAccounts.isNotEmpty) ...[
                      const Text(
                        'Saved accounts',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _rememberedAccounts.keys.map((email) {
                          final isSelected = _emailController.text.trim() == email;
                          return InputChip(
                            avatar: Icon(
                              Icons.person_outline,
                              size: 18,
                              color: isSelected ? AppColors.primaryContainer : Colors.grey.shade600,
                            ),
                            label: Text(email, overflow: TextOverflow.ellipsis),
                            selected: isSelected,
                            onPressed: () => _selectRememberedAccount(email),
                            onDeleted: () => _forgetAccount(email),
                            deleteIconColor: Colors.grey.shade600,
                            backgroundColor: const Color(0xFFF3F4F6),
                            selectedColor: AppColors.successLight,
                            labelStyle: const TextStyle(color: AppColors.primaryContainer),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide.none,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'example@gmail.com',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.email_outlined),
                        filled: true,
                        fillColor:Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                          ),
                        ),
                      
                       validator: (value) {


                        if (value == null || value.trim().isEmpty) {

                          return 'Please enter your email';
                        }
                        return null;
                      },

                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration:  InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.lock_outline),
                        filled: true,
                        fillColor:Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(

                            _obscurePassword
                            ?Icons.visibility_outlined
                            :Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() => _rememberMe = value ?? false);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() => _rememberMe = !_rememberMe);
                              },
                              child: const Text(
                                'Remember me',
                                style: TextStyle(color: AppColors.primaryContainer),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:(context) => const ForgotPasswordScreen(),

                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,

                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child:  _isLoading
                       ? const CircularProgressIndicator()

                       : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Login'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('lib/assets/images/google_logo.png', height: 20, width: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Google',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New to AflAlert? ',
                    style: TextStyle(color: AppColors.primaryContainer),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Register here',
                      style: TextStyle(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}
}




