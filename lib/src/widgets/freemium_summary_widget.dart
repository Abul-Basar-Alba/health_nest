// lib/src/widgets/freemium_summary_widget.dart

import 'package:flutter/material.dart';

import '../services/freemium_service.dart';

/// 🎯 Freemium Summary Widget
/// Shows user's daily usage and premium status in a beautiful card
class FreemiumSummaryWidget extends StatelessWidget {
  const FreemiumSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _buildFreemiumData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: SizedBox(
              height: 120,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = snapshot.data!;
        final isPremium = data['isPremium'] as bool;
        final usageData = data['usage'] as Map<String, int>;

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isPremium
                    ? [Colors.amber.shade50, Colors.orange.shade50]
                    : [Colors.blue.shade50, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Icon(
                      isPremium ? Icons.diamond : Icons.star_border,
                      color: isPremium ? Colors.amber[700] : Colors.blue[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? 'Premium Member 💎' : 'Free Plan ⭐',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isPremium
                                        ? Colors.amber[800]
                                        : Colors.blue[800],
                                  ),
                        ),
                        Text(
                          isPremium
                              ? 'Unlimited access to all features!'
                              : 'Great start! Track your usage below',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Upgrade',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                if (!isPremium) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Today\'s Usage',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Usage indicators
                  Row(
                    children: [
                      Expanded(
                        child: _buildUsageIndicator(
                          '🧮 Calculator',
                          usageData['calculator'] ?? 0,
                          20,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUsageIndicator(
                          '🤖 AI Chat',
                          usageData['chat'] ?? 0,
                          500,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUsageIndicator(
                          '🥗 Nutrition',
                          usageData['nutrition'] ?? 0,
                          10,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUsageIndicator(
                          '👥 Community',
                          usageData['community'] ?? 0,
                          3,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.amber[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Unlimited Calculator • AI Chat • Nutrition Logs • Community Posts',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsageIndicator(String label, int used, int limit, Color color) {
    final percentage = (used / limit).clamp(0.0, 1.0);
    final isNearLimit = percentage > 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$used/$limit',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isNearLimit ? Colors.red[600] : color,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            isNearLimit ? Colors.red : color,
          ),
          minHeight: 4,
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _buildFreemiumData() async {
    final isPremium = await FreemiumService.isPremiumUser();

    final usage = {
      'calculator': await FreemiumService.getDailyUsage('calculator_uses'),
      'chat': await FreemiumService.getDailyUsage('ai_chat_messages'),
      'nutrition': await FreemiumService.getDailyUsage('nutrition_logs'),
      'community': await FreemiumService.getDailyUsage('community_posts'),
    };

    return {
      'isPremium': isPremium,
      'usage': usage,
    };
  }
}

/// 🎁 Quick Premium Benefits Widget
class PremiumBenefitsWidget extends StatelessWidget {
  const PremiumBenefitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.diamond, color: Colors.amber[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Premium Benefits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._benefits.map((benefit) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Show premium upgrade dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.diamond, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Premium upgrade coming soon! 🚀'),
                      ],
                    ),
                    backgroundColor: Colors.amber[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upgrade),
                  const SizedBox(width: 8),
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<String> _benefits = [
    'Unlimited Calculator Uses',
    'Unlimited AI Health Chat',
    'Unlimited Nutrition Logging',
    'Unlimited Community Posts',
    'Advanced Analytics & Insights',
    'Priority Customer Support',
    'Custom Meal Plans',
    'Offline Downloads',
  ];
}
