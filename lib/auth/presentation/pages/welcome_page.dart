import 'package:flutter/material.dart';
import 'package:savesmart/core/utils/constants.dart';
import 'package:savesmart/core/widgets/custom_button.dart';
import 'package:savesmart/features/auth/presentation/pages/login_page.dart';
import 'package:savesmart/features/auth/presentation/pages/register_page.dart';

/// Welcome page
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Title
              const Text(
                'Welcome to\nSaveSmart!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryGreen,
                ),
              ),
              const SizedBox(height: AppConstants.mediumPadding),
              // Subtitle
              const Text(
                'Set goals, track expenses, and\nbuild better financial habits',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.largePadding * 2),
                  // Logo illustration
                  Image.asset(
                    'assets/images/welcomepagelologo.png',
                    height: 150,
                  ),
              const Spacer(),
              // Get Started button
              CustomButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppConstants.mediumPadding),
              // Already have account text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppConstants.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
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
              const SizedBox(height: AppConstants.mediumPadding),
            ],
          ),
        ),
      ),
    );
  }
}
