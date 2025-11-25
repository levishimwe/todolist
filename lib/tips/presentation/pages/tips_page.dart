import 'package:flutter/material.dart';
import 'package:savesmart/core/utils/constants.dart';

/// Tips page
class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F9F2), // Light green background from Figma
      appBar: AppBar(
        title: const Text(
          'Financial Tips',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConstants.primaryGreen,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo at the top
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Image.asset(
                'assets/images/tipspage--logo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildTipCard(
            'Weekly Financial Tip',
            'Budgeting Basics',
            'Learn how to create and manage an effective budget that helps identify areas where you can save money.',
            'assets/images/weekly--financial.png',
            const Color(0xFF4CAF50), // Green
          ),
          _buildTipCard(
            'Educational Articles',
            'Saving Strategies',
            'Discover effective ways to grow your savings and reach your financial goals faster.',
            'assets/images/savings--strategies.png',
            const Color(0xFF2196F3), // Blue
          ),
          _buildTipCard(
            'Educational Articles',
            'Budgeting Basics',
            'Learn how to create and manage an effective budget',
            'assets/images/bugeting--strategies.png',
            const Color(0xFF4CAF50), // Green
          ),
          _buildTipCard(
            'Money Tips',
            'Student Finance',
            'Tips for managing your finances during college',
            'assets/images/student--finance.png',
            const Color(0xFFFF9800), // Orange
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
    String category,
    String title,
    String description,
    String imagePath,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image icon with green background container (like Figma)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD6F5E6), // Light green background like Figma
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
