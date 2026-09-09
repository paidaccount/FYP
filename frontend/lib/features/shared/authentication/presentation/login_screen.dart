import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/shared/authentication/presentation/auth_provider.dart';

enum AuthViewMode { login, signup, forgotPassword }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  AuthViewMode _currentMode = AuthViewMode.login;
  String _selectedRole = "Admin"; // "Admin" or "User"

  final _nameController = TextEditingController(text: "Admin Operator");
  final _emailController = TextEditingController(text: "admin@vanet.com");
  final _passwordController = TextEditingController(text: "admin123");
  final _forgotEmailController = TextEditingController(text: "admin@vanet.com");

  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _successMessage = null);

    if (_currentMode == AuthViewMode.forgotPassword) {
      final email = _forgotEmailController.text.trim();
      if (email.isEmpty) return;
      setState(() {
        _successMessage = "Password reset instructions sent to $email";
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = _currentMode == AuthViewMode.signup
        ? await ref.read(authProvider.notifier).signUp(email, password, role: _selectedRole)
        : await ref.read(authProvider.notifier).login(email, password, role: _selectedRole);

    if (success && mounted) {
      final updatedAuth = ref.read(authProvider);
      if (updatedAuth.isAdmin) {
        context.go('/dashboard');
      } else {
        context.go('/driver/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentMode != AuthViewMode.login
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () {
                  setState(() {
                    _currentMode = AuthViewMode.login;
                    _successMessage = null;
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 Header Titles (Matching Mockup 2)
                  Text(
                    _getMainTitle(),
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSubtitle(),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Role Selector Pills
                  if (_currentMode != AuthViewMode.forgotPassword) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleSelector("Admin", Icons.shield_rounded, label: "Admin"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoleSelector("Driver", Icons.directions_car_rounded, label: "Driver / OBU"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 🔹 Sign Up: Name Field
                  if (_currentMode == AuthViewMode.signup) ...[
                    _buildFieldLabel('Name'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _nameController,
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 🔹 Email Field
                  if (_currentMode != AuthViewMode.forgotPassword) ...[
                    _buildFieldLabel('Email'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _emailController,
                      hint: 'admin@vanet.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Password Field
                    _buildFieldLabel('Password'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Remember Me Checkbox & Forgot Password Row (Matching Mockup 2)
                    if (_currentMode == AuthViewMode.login)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (val) {
                                    setState(() => _rememberMe = val ?? true);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() => _rememberMe = !_rememberMe),
                                child: Text(
                                  'Remember me',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _currentMode = AuthViewMode.forgotPassword;
                                _successMessage = null;
                              });
                            },
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.outfit(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],

                  // 🔹 Forgot Password Mode Input
                  if (_currentMode == AuthViewMode.forgotPassword) ...[
                    _buildFieldLabel('Account Email'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _forgotEmailController,
                      hint: 'Enter your registered email',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 🔹 Error Message Banner
                  if (authState.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: GoogleFonts.outfit(color: AppTheme.error, fontSize: 12),
                      ),
                    ),
                  ],

                  // 🔹 Success Message Banner
                  if (_successMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.safe.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.safe.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _successMessage!,
                        style: GoogleFonts.outfit(color: AppTheme.safe, fontSize: 12),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 🔹 Orange Primary Action Button (Matching Mockup 2)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: authState.isLoading ? null : _handleSubmit,
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _getButtonLabel(),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Sign Up / Login Footer Toggle (Matching Mockup 2)
                  Center(
                    child: _buildFooterLink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMainTitle() {
    switch (_currentMode) {
      case AuthViewMode.login:
        return 'Welcome Back!';
      case AuthViewMode.signup:
        return 'Create Account';
      case AuthViewMode.forgotPassword:
        return 'Reset Password';
    }
  }

  String _getSubtitle() {
    switch (_currentMode) {
      case AuthViewMode.login:
        return 'Sign in to continue';
      case AuthViewMode.signup:
        return 'Register new operator or supervisor node';
      case AuthViewMode.forgotPassword:
        return 'Enter email to receive recovery instructions';
    }
  }

  String _getButtonLabel() {
    switch (_currentMode) {
      case AuthViewMode.login:
        return 'Login';
      case AuthViewMode.signup:
        return 'Sign Up';
      case AuthViewMode.forgotPassword:
        return 'Send Instructions';
    }
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildRoleSelector(String role, IconData icon, {String? label}) {
    final isSelected = _selectedRole == role;
    final displayLabel = label ?? role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
          if (role == 'Admin') {
            _emailController.text = 'admin@vanet.com';
            _passwordController.text = 'admin123';
            _nameController.text = 'Admin Operator';
          } else {
            _emailController.text = 'driver@vanet.com';
            _passwordController.text = 'driver123';
            _nameController.text = 'Vehicle Driver';
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : AppTheme.secondarySurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              displayLabel,
              style: GoogleFonts.outfit(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: AppTheme.textSecondary.withValues(alpha: 0.7), fontSize: 13.5),
          prefixIcon: Icon(icon, size: 20, color: AppTheme.textSecondary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 19,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFooterLink() {
    if (_currentMode == AuthViewMode.login) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _currentMode = AuthViewMode.signup;
                _successMessage = null;
              });
            },
            child: Text(
              'Sign Up',
              style: GoogleFonts.outfit(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _currentMode = AuthViewMode.login;
                _successMessage = null;
              });
            },
            child: Text(
              'Login',
              style: GoogleFonts.outfit(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }
  }
}
