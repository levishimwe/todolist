import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savesmart/core/utils/constants.dart';
import 'package:savesmart/features/auth/presentation/bloc/auth_bloc.dart';

/// Page shown when user must verify their email address before proceeding.
class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: AppConstants.primaryGreen,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Email verified successfully! Navigate to home
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Email verified successfully!'),
                backgroundColor: AppConstants.successColor,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is AuthError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.errorColor,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final email = state is EmailVerificationPending ? state.email : '';
          final isLoading = state is AuthLoading;
          
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppConstants.lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 64,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Verify Your Email',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppConstants.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'ve sent a verification link to:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.lightGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email,
                        color: AppConstants.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Steps to verify:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('1. Check your email inbox (and spam folder)'),
                      const SizedBox(height: 6),
                      const Text('2. Click the verification link'),
                      const SizedBox(height: 6),
                      const Text('3. Return here and click "I\'ve Verified"'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Main verify button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(CheckEmailVerifiedEvent());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text(
                      isLoading ? 'Checking...' : 'I\'ve Verified My Email',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Resend button
                Center(
                  child: TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(ResendVerificationEmailEvent());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Verification email sent! Check your inbox.'),
                                backgroundColor: AppConstants.primaryGreen,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Resend Verification Email'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.primaryGreen,
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