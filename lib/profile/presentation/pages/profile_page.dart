import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savesmart/core/utils/constants.dart';
import 'package:savesmart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:savesmart/features/auth/presentation/pages/welcome_page.dart';

/// Profile page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE9F9F2), // Light green background from Figma
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppConstants.primaryGreen,
          elevation: 0,
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              // Navigate to welcome page after logout
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomePage()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            final uid = FirebaseAuth.instance.currentUser?.uid;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Header
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: AppConstants.primaryGreen,
                          child: const Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                stream: uid == null
                                    ? null
                                    : FirebaseFirestore.instance
                                        .collection(AppConstants.usersCollection)
                                        .doc(uid)
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  final data = snapshot.data?.data();
                                  final fullName = data?['fullName'] as String? ?? (state is Authenticated ? state.user.fullName : 'User');
                                  final email = data?['email'] as String? ?? (state is Authenticated ? state.user.email : 'user@example.com');
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          color: Color(0xFF757575),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppConstants.primaryGreen,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Stats
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Total Saved from users doc
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: uid == null
                              ? null
                              : FirebaseFirestore.instance
                                  .collection(AppConstants.usersCollection)
                                  .doc(uid)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            final total = (snapshot.data?.data()?['totalSavings'] as num?)?.toDouble() ?? 0;
                            return _buildStatRow('Total Saved', '\$${total.toStringAsFixed(0)}');
                          },
                        ),
                        // Goals Achieved count
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: uid == null
                              ? null
                              : FirebaseFirestore.instance
                                  .collection(AppConstants.goalsCollection)
                                  .where('userId', isEqualTo: uid)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            final goals = snapshot.data?.docs ?? [];
                            int achieved = 0;
                            for (final g in goals) {
                              final d = g.data();
                              final current = (d['currentAmount'] as num?)?.toDouble() ?? 0;
                              final target = (d['targetAmount'] as num?)?.toDouble() ?? 0;
                              if (target > 0 && current >= target) achieved++;
                            }
                            return _buildStatRow('Goals Achieved', '$achieved');
                          },
                        ),
                        // Days Saving since account creation
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: uid == null
                              ? null
                              : FirebaseFirestore.instance
                                  .collection(AppConstants.usersCollection)
                                  .doc(uid)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            final ts = snapshot.data?.data()?['createdAt'];
                            DateTime? created;
                            if (ts is Timestamp) created = ts.toDate();
                            if (ts is DateTime) created = ts;
                            final days = created == null
                                ? 0
                                : DateTime.now().difference(created).inDays;
                            return _buildStatRow('Days Saving', '$days');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Settings
                _buildNotificationTile(),
                const SizedBox(height: 16),
                // Logout
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const Icon(
                      Icons.logout,
                      color: AppConstants.errorColor,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppConstants.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppConstants.errorColor,
                    ),
                    onTap: () async {
                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppConstants.errorColor,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      // If user confirmed, sign out
                      if (shouldLogout == true && context.mounted) {
                        context.read<AuthBloc>().add(SignOutEvent());
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
  }

  Widget _buildNotificationTile() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseAuth.instance.currentUser?.uid == null
          ? null
          : FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
      builder: (context, snapshot) {
        final notificationsEnabled = snapshot.data?.data()?['notificationsEnabled'] as bool? ?? true;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(Icons.notifications_outlined, color: AppConstants.primaryGreen),
            title: const Text(
              'Notification',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            trailing: Switch(
              value: notificationsEnabled,
              activeColor: AppConstants.primaryGreen,
              onChanged: (value) async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  await FirebaseFirestore.instance
                      .collection(AppConstants.usersCollection)
                      .doc(uid)
                      .update({'notificationsEnabled': value});
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value 
                              ? 'Notifications enabled' 
                              : 'Notifications disabled',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppConstants.primaryGreen,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
}
