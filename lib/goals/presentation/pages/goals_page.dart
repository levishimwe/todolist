import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:savesmart/core/utils/constants.dart';
import 'package:savesmart/core/services/email_service.dart';

/// Goals page
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('My Goals'),
        backgroundColor: AppConstants.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddGoalDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.goalsCollection)
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load goals',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          
          // Sort in-memory since orderBy requires composite index
          docs.sort((a, b) {
            final aTime = a.data()['createdAt'] as Timestamp?;
            final bTime = b.data()['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // descending
          });

          if (docs.isEmpty) {
            return const Center(
              child: Text('No goals yet. Tap + to add your first goal.'),
            );
          }

          // Get user's total savings to display as current amount for goals
          final uid = FirebaseAuth.instance.currentUser?.uid;
          
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: uid == null
                ? null
                : FirebaseFirestore.instance
                    .collection(AppConstants.usersCollection)
                    .doc(uid)
                    .snapshots(),
            builder: (context, userSnapshot) {
              // Get user's total savings
              final totalSavings = (userSnapshot.data?.data()?['totalSavings'] as num?)?.toDouble() ?? 0;

              return ListView.builder(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final goalId = doc.id;
                  final name = data['name'] as String? ?? 'Goal';
                  // Use totalSavings as current amount for goals (not static currentAmount)
                  final current = totalSavings;
                  final target = (data['targetAmount'] as num?)?.toDouble() ?? 0;
                  final withdrawn = data['withdrawn'] as bool? ?? false;
                  final progress = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
                  final isAchieved = current >= target && target > 0;

                  // Smart icon/color selection based on goal name
                  final iconData = _getIconForGoal(name);
                  final icon = iconData['icon'] as IconData;
                  final color = iconData['color'] as Color;

                  return _buildGoalCard(
                    context,
                    goalId,
                    name,
                    '\$${current.toStringAsFixed(0)}',
                    '\$${target.toStringAsFixed(0)}',
                    progress,
                    icon,
                    color,
                    isAchieved,
                    withdrawn,
                    current,
                    target,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Smart icon and color selection based on goal name
  Map<String, dynamic> _getIconForGoal(String goalName) {
    final name = goalName.toLowerCase();
    
    // Medical/Health
    if (name.contains('surgery') || name.contains('medical') || name.contains('health') || 
        name.contains('hospital') || name.contains('doctor')) {
      return {'icon': Icons.medical_services, 'color': Colors.red};
    }
    
    // Technology
    if (name.contains('laptop') || name.contains('computer') || name.contains('pc') || 
        name.contains('phone') || name.contains('iphone') || name.contains('ipad') ||
        name.contains('tablet') || name.contains('macbook')) {
      return {'icon': Icons.laptop_mac, 'color': Colors.blue};
    }
    
    // Education
    if (name.contains('school') || name.contains('university') || name.contains('college') ||
        name.contains('tuition') || name.contains('education') || name.contains('study') ||
        name.contains('master') || name.contains('degree') || name.contains('course')) {
      return {'icon': Icons.school, 'color': Colors.indigo};
    }
    
    // Travel/Vacation
    if (name.contains('vacation') || name.contains('travel') || name.contains('trip') ||
        name.contains('holiday') || name.contains('flight') || name.contains('tour')) {
      return {'icon': Icons.flight, 'color': Colors.orange};
    }
    
    // Car/Vehicle
    if (name.contains('car') || name.contains('vehicle') || name.contains('motorcycle') ||
        name.contains('bike') || name.contains('auto')) {
      return {'icon': Icons.directions_car, 'color': Colors.teal};
    }
    
    // House/Home
    if (name.contains('house') || name.contains('home') || name.contains('apartment') ||
        name.contains('rent') || name.contains('mortgage')) {
      return {'icon': Icons.home, 'color': Colors.green};
    }
    
    // Wedding
    if (name.contains('wedding') || name.contains('marriage') || name.contains('engagement')) {
      return {'icon': Icons.favorite, 'color': Colors.pink};
    }
    
    // Emergency/Safety
    if (name.contains('emergency') || name.contains('fund') || name.contains('safety') ||
        name.contains('insurance')) {
      return {'icon': Icons.shield, 'color': Colors.amber};
    }
    
    // Business
    if (name.contains('business') || name.contains('startup') || name.contains('investment')) {
      return {'icon': Icons.business_center, 'color': Colors.deepPurple};
    }
    
    // Clothing/Fashion
    if (name.contains('clothes') || name.contains('shoes') || name.contains('fashion') ||
        name.contains('dress') || name.contains('suit')) {
      return {'icon': Icons.shopping_bag, 'color': Colors.purple};
    }
    
    // Baby/Family
    if (name.contains('baby') || name.contains('child') || name.contains('family')) {
      return {'icon': Icons.child_care, 'color': Colors.cyan};
    }
    
    // Default
    return {'icon': Icons.savings, 'color': Colors.blue};
  }

  Widget _buildGoalCard(
    BuildContext context,
    String goalId,
    String title,
    String current,
    String target,
    double progress,
    IconData icon,
    Color color,
    bool isAchieved,
    bool withdrawn,
    double currentAmount,
    double targetAmount,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$current of $target',
                        style: const TextStyle(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        if (!withdrawn)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: Colors.blue,
                            onPressed: () => _showEditGoalDialog(
                              context,
                              goalId,
                              title,
                              targetAmount,
                              currentAmount,
                            ),
                            tooltip: 'Edit goal',
                          ),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red,
                          onPressed: () => _showDeleteGoalDialog(context, goalId, title),
                          tooltip: 'Delete goal',
                        ),
                      ],
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (isAchieved)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Achieved',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (withdrawn)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Withdrawn',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            if (isAchieved && !withdrawn)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showWithdrawDialog(context, goalId, title, target),
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Withdraw'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController();
    bool allocateFromSavings = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    hintText: 'e.g., New Laptop',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount',
                    hintText: 'e.g., 1000',
                    prefixText: '\$',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current Amount',
                    hintText: 'e.g., 200',
                    prefixText: '\$',
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Allocate from Total Savings'),
                  subtitle: const Text('Deduct current amount from your total savings'),
                  value: allocateFromSavings,
                  onChanged: (value) {
                    setState(() {
                      allocateFromSavings = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;

                final name = nameController.text.trim();
                final target = double.tryParse(targetController.text.trim()) ?? 0;
                final current = double.tryParse(currentController.text.trim()) ?? 0;

                // Create the goal document
                final goalRef = FirebaseFirestore.instance
                    .collection(AppConstants.goalsCollection)
                    .doc();

                await goalRef.set({
                  'id': goalRef.id,
                  'userId': uid,
                  'name': name,
                  'targetAmount': target,
                  'currentAmount': current,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                // If allocate from savings, create a transaction and update totals
                if (allocateFromSavings && current > 0) {
                  final txRef = FirebaseFirestore.instance
                      .collection(AppConstants.transactionsCollection)
                      .doc();

                  await txRef.set({
                    'id': txRef.id,
                    'userId': uid,
                    'description': 'Allocated to $name',
                    'amount': current,
                    'type': 'expense',
                    'date': FieldValue.serverTimestamp(),
                    'goalId': goalRef.id,
                  });

                  // Update user's totalSavings atomically
                  final userRef = FirebaseFirestore.instance
                      .collection(AppConstants.usersCollection)
                      .doc(uid);

                  await FirebaseFirestore.instance.runTransaction((t) async {
                    final snap = await t.get(userRef);
                    final totalSavings = (snap.data()?['totalSavings'] as num?)?.toDouble() ?? 0;
                    final updated = (totalSavings - current).clamp(0, double.infinity);
                    t.update(userRef, {'totalSavings': updated});
                  });
                }

                // Send email notification about goal creation
                await _sendGoalCreationEmail(uid, name, target, current);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        allocateFromSavings && current > 0
                            ? 'Goal added and \$${current.toStringAsFixed(0)} allocated from savings!'
                            : 'Goal added successfully!',
                      ),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
              ),
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  /// Send email notification when goal is created
  Future<void> _sendGoalCreationEmail(
    String userId,
    String goalName,
    double targetAmount,
    double currentAmount,
  ) async {
    try {
      // Get user data for email
      final userDoc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      final userData = userDoc.data();
      if (userData == null) return;

      final userEmail = userData['email'] as String?;
      final userName = userData['name'] as String? ?? 'User';
      if (userEmail == null) return;

      // Get all user's goals to check if they have enough savings
      final goalsSnapshot = await FirebaseFirestore.instance
          .collection(AppConstants.goalsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final totalSavings = (userData['totalSavings'] as num?)?.toDouble() ?? 0;
      double totalNeeded = 0;
      final goalNames = <String>[];

      for (final doc in goalsSnapshot.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? 'Goal';
        final target = (data['targetAmount'] as num?)?.toDouble() ?? 0;
        final current = (data['currentAmount'] as num?)?.toDouble() ?? 0;
        final needed = target - current;
        if (needed > 0) {
          totalNeeded += needed;
          goalNames.add(name);
        }
      }

      final hasEnoughSavings = totalSavings >= totalNeeded;

      // Send email notification
      final emailService = EmailService();
      await emailService.sendGoalNotification(
        userEmail: userEmail,
        userName: userName,
        goalNames: goalNames.isEmpty ? [goalName] : goalNames,
        hasEnoughSavings: hasEnoughSavings,
      );
    } catch (e) {
      debugPrint('Failed to send email notification: $e');
      // Don't throw - email failure shouldn't block goal creation
    }
  }

  /// Show dialog to withdraw money from achieved goal
  void _showWithdrawDialog(
    BuildContext context,
    String goalId,
    String goalName,
    String targetAmountStr,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Goal Savings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Congratulations on achieving your goal: $goalName!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Amount to withdraw: $targetAmountStr'),
            const SizedBox(height: 8),
            const Text(
              '(Target amount for this goal)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('• Create a withdrawal transaction'),
            const Text('• Decrease your total savings'),
            const Text('• Mark this goal as completed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _processWithdrawal(context, goalId, goalName, targetAmountStr);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirm Withdrawal'),
          ),
        ],
      ),
    );
  }

  /// Process goal withdrawal
  Future<void> _processWithdrawal(
    BuildContext context,
    String goalId,
    String goalName,
    String currentAmountStr,
  ) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Get goal data
      final goalDoc = await FirebaseFirestore.instance
          .collection(AppConstants.goalsCollection)
          .doc(goalId)
          .get();

      if (!goalDoc.exists) {
        throw Exception('Goal not found');
      }

      final goalData = goalDoc.data()!;
      final currentAmount = (goalData['currentAmount'] as num?)?.toDouble() ?? 0;
      final targetAmount = (goalData['targetAmount'] as num?)?.toDouble() ?? 0;

      // Validate goal is achieved
      if (currentAmount < targetAmount) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "You can't withdraw the money because you didn't achieve your goal",
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      // IMPORTANT: Withdraw only the TARGET AMOUNT, not the current amount
      // Example: Goal is "Laptop" with target $2000, user has $5000 in goal
      // User should only withdraw $2000 (the target), not $5000
      final withdrawalAmount = targetAmount;

      // Create withdrawal transaction
      final txRef = FirebaseFirestore.instance
          .collection(AppConstants.transactionsCollection)
          .doc();

      await txRef.set({
        'id': txRef.id,
        'userId': uid,
        'description': 'Withdrawal from $goalName',
        'amount': withdrawalAmount,
        'type': 'withdrawal',
        'date': FieldValue.serverTimestamp(),
        'goalId': goalId,
      });

      // IMPORTANT: Decrease totalSavings when user withdraws money
      // When user withdraws, they're taking money out of their savings
      final userRef = FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final currentTotalSavings = (userDoc.data()?['totalSavings'] as num?)?.toDouble() ?? 0;
        
        // Decrease totalSavings by withdrawal amount (targetAmount)
        final newTotalSavings = (currentTotalSavings - withdrawalAmount).clamp(0, double.infinity);
        
        transaction.update(userRef, {'totalSavings': newTotalSavings});
      });

      // Mark goal as withdrawn
      await FirebaseFirestore.instance
          .collection(AppConstants.goalsCollection)
          .doc(goalId)
          .update({
        'withdrawn': true,
        'withdrawnAt': FieldValue.serverTimestamp(),
        'currentAmount': 0, // Reset goal amount after withdrawal
      });

      // Send withdrawal confirmation email (with withdrawal amount)
      await _sendWithdrawalEmail(uid, goalName, withdrawalAmount);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully withdrew \$${withdrawalAmount.toStringAsFixed(2)} from $goalName!',
            ),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process withdrawal: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  /// Send withdrawal confirmation email
  Future<void> _sendWithdrawalEmail(
    String userId,
    String goalName,
    double amount,
  ) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      final userData = userDoc.data();
      if (userData == null) return;

      final userEmail = userData['email'] as String?;
      final userName = userData['name'] as String? ?? 'User';
      if (userEmail == null) return;

      final emailService = EmailService();
      await emailService.sendWithdrawalConfirmation(
        userEmail: userEmail,
        userName: userName,
        goalName: goalName,
        amount: amount,
      );
    } catch (e) {
      debugPrint('Failed to send withdrawal email: $e');
    }
  }

  /// Show dialog to edit goal
  void _showEditGoalDialog(
    BuildContext context,
    String goalId,
    String currentName,
    double currentTarget,
    double currentCurrent,
  ) {
    final nameController = TextEditingController(text: currentName);
    final targetController = TextEditingController(text: currentTarget.toStringAsFixed(0));
    final currentController = TextEditingController(text: currentCurrent.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  prefixText: '\$',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: currentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current Amount',
                  prefixText: '\$',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final name = nameController.text.trim();
                final target = double.tryParse(targetController.text.trim()) ?? 0;
                final current = double.tryParse(currentController.text.trim()) ?? 0;

                await FirebaseFirestore.instance
                    .collection(AppConstants.goalsCollection)
                    .doc(goalId)
                    .update({
                  'name': name,
                  'targetAmount': target,
                  'currentAmount': current,
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goal updated successfully!'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update goal: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog before deleting goal
  void _showDeleteGoalDialog(
    BuildContext context,
    String goalId,
    String goalName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this goal?'),
            const SizedBox(height: 16),
            Text(
              goalName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection(AppConstants.goalsCollection)
                    .doc(goalId)
                    .delete();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goal deleted successfully!'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete goal: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

