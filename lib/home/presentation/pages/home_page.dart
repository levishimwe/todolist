import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savesmart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:savesmart/features/auth/presentation/pages/welcome_page.dart';
import 'package:savesmart/features/auth/presentation/pages/email_verification_page.dart';
import 'package:savesmart/core/utils/constants.dart';
import 'package:savesmart/features/goals/presentation/pages/goals_page.dart';
import 'package:savesmart/features/home/presentation/pages/dashboard_page.dart';
import 'package:savesmart/features/profile/presentation/pages/profile_page.dart';
import 'package:savesmart/features/savings/presentation/pages/savings_page.dart';
import 'package:savesmart/features/tips/presentation/pages/tips_page.dart';
import 'package:savesmart/features/transactions/presentation/pages/transactions_page.dart';

/// Home page with bottom navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const GoalsPage(),
    const SavingsPage(),
    const TransactionsPage(),
    const TipsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Extra safety redirect to welcome page clearing stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomePage()),
            (route) => false,
          );
        } else if (state is EmailVerificationPending) {
          // Navigate to verification page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EmailVerificationPage(),
            ),
          );
        }
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryGreen,
        unselectedItemColor: AppConstants.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            activeIcon: Icon(Icons.savings),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Savings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        ),
      ),
    );
  }
}
