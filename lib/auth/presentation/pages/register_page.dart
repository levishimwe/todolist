import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savesmart/core/utils/constants.dart';
import 'package:savesmart/core/utils/validators.dart';
import 'package:savesmart/core/widgets/custom_button.dart';
import 'package:savesmart/core/widgets/custom_text_field.dart';
import 'package:savesmart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:savesmart/features/auth/presentation/pages/login_page.dart';
import 'package:savesmart/features/auth/presentation/pages/email_verification_page.dart';
import 'package:savesmart/features/home/presentation/pages/home_page.dart';

/// Register page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignUpWithEmailEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            } else if (state is EmailVerificationPending) {
              // Navigate to email verification page
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
                (route) => false,
              );
            } else if (state is Authenticated) {
              // Navigate to home page after successful registration
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConstants.lightGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                                child: Image.asset(
                                  'assets/images/registerpagelogo.png',
                                  height: 32,
                                ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'SaveSmart',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Full Name field
                      CustomTextField(
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        controller: _fullNameController,
                        validator: Validators.validateName,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      const SizedBox(height: 16),
                      // Email field
                      CustomTextField(
                        label: 'Email',
                        hintText: 'Enter your email',
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      const SizedBox(height: 16),
                      // Phone Number field
                      CustomTextField(
                        label: 'Phone Number',
                        hintText: 'Enter your phone number (optional)',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      CustomTextField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        validator: Validators.validatePassword,
                        obscureText: _obscurePassword,
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
                      const SizedBox(height: 16),
                      // Confirm Password field
                      CustomTextField(
                        label: 'Confirm Password',
                        hintText: 'Confirm your password',
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        obscureText: _obscureConfirmPassword,
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
                      const SizedBox(height: 8),
                      // Terms checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (value) {},
                            activeColor: AppConstants.primaryGreen,
                          ),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                text: 'I agree to the ',
                                style: TextStyle(
                                  color: AppConstants.textSecondary,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms and conditions',
                                    style: TextStyle(
                                      color: AppConstants.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Sign up button
                      CustomButton(
                        text: 'Sign up',
                        onPressed: _register,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 16),
                      // Google sign in button
                      CustomButton(
                        text: 'Sign in with Google',
                        onPressed: () {
                          context.read<AuthBloc>().add(SignInWithGoogleEvent());
                        },
                        backgroundColor: Colors.white,
                        textColor: AppConstants.textPrimary,
                        icon: Icons.g_mobiledata,
                      ),
                      const SizedBox(height: 24),
                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: AppConstants.textSecondary),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: AppConstants.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
    );
  }
}
