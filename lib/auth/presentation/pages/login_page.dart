import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savesmart/core/utils/constants.dart';
import 'package:savesmart/core/utils/validators.dart';
import 'package:savesmart/core/widgets/custom_button.dart';
import 'package:savesmart/core/widgets/custom_text_field.dart';
import 'package:savesmart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:savesmart/features/auth/presentation/pages/register_page.dart';
import 'package:savesmart/features/auth/presentation/pages/email_verification_page.dart';
import 'package:savesmart/features/home/presentation/pages/home_page.dart';

/// Login page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignInWithEmailEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryGreen,
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
              // Navigate to home page after successful login
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Column(
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.all(
                      AppConstants.largePadding * 2,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                              child: Image.asset(
                                'assets/images/loginpagelogo.png',
                                height: 64,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'SaveSmart',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Welcome back',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // Form section
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.largeRadius),
                          topRight: Radius.circular(AppConstants.largeRadius),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(
                          AppConstants.largePadding,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 24),
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
                              const SizedBox(height: 8),
                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implement forgot password
                                  },
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: AppConstants.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Login button
                              CustomButton(
                                text: 'Login',
                                onPressed: _login,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 16),
                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Colors.grey[300]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Colors.grey[300]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Google sign in
                              CustomButton(
                                text: 'Sign in with Google',
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    SignInWithGoogleEvent(),
                                  );
                                },
                                backgroundColor: Colors.white,
                                textColor: AppConstants.textPrimary,
                                icon: Icons.g_mobiledata,
                              ),
                              const SizedBox(height: 24),
                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: AppConstants.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Sign up',
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
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    );
  }
}
