// lib/src/widgets/premium_showcase_widget.dart

import 'package:flutter/material.dart';
import '../services/freemium_service.dart';

class PremiumShowcaseWidget extends StatelessWidget {
  final String feature;
  final VoidCallback onUpgradePressed;

  const PremiumShowcaseWidget({
    super.key,
    required this.feature,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    final promptData = FreemiumService.getPremiumPrompt(feature);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
            Colors.orange.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade300.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promptData['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Unlock unlimited access',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Message
          Text(
            promptData['message'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 20),

          // Benefits list
          const Text(
            'Premium Benefits:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ...promptData['benefits'].map<Widget>((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 24),

          // CTA Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onUpgradePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    promptData['ctaText'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Usage Limit Warning Widget
class UsageLimitWarning extends StatelessWidget {
  final String feature;
  final int remaining;
  final int total;

  const UsageLimitWarning({
    super.key,
    required this.feature,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ((total - remaining) / total * 100).clamp(0, 100);
    final isWarning = remaining <= 3;
    final isCritical = remaining <= 1;

    Color color = Colors.green;
    if (isCritical) {
      color = Colors.red;
    } else if (isWarning) {
      color = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isCritical
                ? Icons.warning
                : isWarning
                    ? Icons.info
                    : Icons.check,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FreemiumService.getFeatureDisplayInfo(feature)['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$remaining of $total uses remaining today',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: color.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeWidth: 3,
                ),
                Center(
                  child: Text(
                    '$remaining',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Daily Usage Summary Widget
class DailyUsageSummary extends StatefulWidget {
  const DailyUsageSummary({super.key});

  @override
  State<DailyUsageSummary> createState() => _DailyUsageSummaryState();
}

class _DailyUsageSummaryState extends State<DailyUsageSummary> {
  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final summary = await FreemiumService.getDailySummary();
    setState(() {
      _summary = summary;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_summary == null) {
      return const SizedBox.shrink();
    }

    final isPremium = _summary!['isPremium'] as bool;
    final features = _summary!['features'] as Map<String, dynamic>;

    if (isPremium) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade200, Colors.amber.shade400],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Unlimited access to all features',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Today\'s Usage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.entries.map((entry) {
              final feature = entry.key;
              final data = entry.value as Map<String, dynamic>;
              final usage = data['usage'] as int;
              final limit = data['limit'] as int;
              final remaining = data['remaining'] as int;

              if (limit <= 0) return const SizedBox.shrink();

              return UsageLimitWarning(
                feature: feature,
                remaining: remaining,
                total: limit,
              );
            }),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Navigate to premium screen
                },
                icon: const Icon(Icons.star, color: Colors.orange),
                label: const Text(
                  'Upgrade to Premium for Unlimited Access',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
