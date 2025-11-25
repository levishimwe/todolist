import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:savesmart/core/utils/constants.dart';

/// Savings page - where users deposit/save money
class SavingsPage extends StatelessWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Savings'),
        backgroundColor: AppConstants.primaryGreen,
      ),
      body: Column(
        children: [
          // Total Savings Display
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppConstants.mediumPadding),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.primaryGreen, AppConstants.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryGreen.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: uid == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection(AppConstants.usersCollection)
                      .doc(uid)
                      .snapshots(),
              builder: (context, snapshot) {
                final totalSavings =
                    (snapshot.data?.data()?['totalSavings'] as num?)?.toDouble() ?? 0;

                return Column(
                  children: [
                    const Text(
                      'Total Savings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalSavings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Savings History
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.mediumPadding,
              vertical: 8,
            ),
            child: Row(
              children: [
                const Text(
                  'Savings History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Could add filter functionality
                  },
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                ),
              ],
            ),
          ),

          // Savings List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: uid == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection(AppConstants.savingsCollection)
                      .where('userId', isEqualTo: uid)
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
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load savings',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // Sort by date (most recent first)
                docs.sort((a, b) {
                  final aTime = a.data()['date'] as Timestamp?;
                  final bTime = b.data()['date'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.savings_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No savings yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button below to start saving!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.mediumPadding),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final savingId = doc.id;
                    final description =
                        data['description'] as String? ?? 'Deposit';
                    final date = (data['date'] as Timestamp?)?.toDate();
                    final amount = (data['amount'] as num?)?.toDouble() ?? 0;

                    return _buildSavingItem(
                      context,
                      savingId,
                      description,
                      _formatDate(date),
                      amount,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showStartSavingDialog(context);
        },
        backgroundColor: AppConstants.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Start to Save'),
      ),
    );
  }

  Widget _buildSavingItem(
    BuildContext context,
    String savingId,
    String description,
    String date,
    double amount,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add_circle, color: Colors.green),
        ),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(date),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteSavingDialog(
                context,
                savingId,
                description,
                amount,
              ),
              tooltip: 'Delete saving',
            ),
          ],
        ),
      ),
    );
  }

  void _showStartSavingDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start to Save'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Monthly Salary',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'e.g., 500.00',
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
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;

              final description = descriptionController.text.trim();
              if (description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a description'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final amount =
                  double.tryParse(amountController.text.trim()) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                // 1) Add saving document
                final savingRef = FirebaseFirestore.instance
                    .collection(AppConstants.savingsCollection)
                    .doc();

                await savingRef.set({
                  'id': savingRef.id,
                  'userId': uid,
                  'description': description,
                  'amount': amount,
                  'date': FieldValue.serverTimestamp(),
                });

                // 2) Create transaction record for history
                final txRef = FirebaseFirestore.instance
                    .collection(AppConstants.transactionsCollection)
                    .doc();

                await txRef.set({
                  'id': txRef.id,
                  'userId': uid,
                  'description': description,
                  'amount': amount,
                  'type': 'deposit',
                  'date': FieldValue.serverTimestamp(),
                });

                // 3) Update user's totalSavings atomically
                final userRef = FirebaseFirestore.instance
                    .collection(AppConstants.usersCollection)
                    .doc(uid);

                await FirebaseFirestore.instance.runTransaction((t) async {
                  final snap = await t.get(userRef);
                  final current =
                      (snap.data()?['totalSavings'] as num?)?.toDouble() ?? 0;
                  final updated = current + amount;
                  t.update(userRef, {'totalSavings': updated});
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saving added successfully!'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add saving: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
            ),
            child: const Text('Start to Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${_monthAbbr(date.month)} ${date.day}, ${date.year}';
  }

  String _monthAbbr(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (m < 1 || m > 12) return '';
    return months[m - 1];
  }

  /// Show confirmation dialog before deleting saving
  void _showDeleteSavingDialog(
    BuildContext context,
    String savingId,
    String description,
    double amount,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Saving'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this saving from history?'),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('\$${amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'Note: This only removes the saving from history. Your total savings will not be affected.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
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
              await _deleteSaving(context, savingId, amount);
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

  /// Delete saving (display only - does NOT affect totalSavings)
  Future<void> _deleteSaving(
    BuildContext context,
    String savingId,
    double amount,
  ) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Delete the saving from history (display only)
      // This does NOT affect the user's totalSavings
      await FirebaseFirestore.instance
          .collection(AppConstants.savingsCollection)
          .doc(savingId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saving deleted from history!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
