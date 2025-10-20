// lib/src/widgets/premium_lock_widget.dart

import 'package:flutter/material.dart';
import '../services/freemium_service.dart';

/// 🔒 Premium Lock Widget
/// Shows a beautiful lock icon for premium features
class PremiumLockWidget extends StatelessWidget {
  final Widget child;
  final String feature;
  final String lockMessage;
  final VoidCallback? onUpgrade;
  final bool showShimmer;

  const PremiumLockWidget({
    super.key,
    required this.child,
    required this.feature,
    this.lockMessage = 'Premium Feature',
    this.onUpgrade,
    this.showShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: FreemiumService.isPremiumUser(),
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;

        if (isPremium) {
          return child;
        }

        return Stack(
          children: [
            // Blurred child content
            Opacity(
              opacity: 0.3,
              child: child,
            ),

            // Premium overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showPremiumDialog(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Premium lock icon with animation
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1500),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.amber.shade400,
                                        Colors.orange.shade500,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Premium badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade200,
                                  Colors.orange.shade200
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amber.shade400),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.diamond,
                                    color: Colors.amber[700], size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    color: Colors.amber[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Lock message
                          Text(
                            lockMessage,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Upgrade button
                          ElevatedButton.icon(
                            onPressed: () => _showPremiumDialog(context),
                            icon: const Icon(Icons.upgrade, size: 16),
                            label: const Text(
                              'Upgrade Now',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.diamond, color: Colors.amber[700]),
            const SizedBox(width: 8),
            const Text('Premium Feature'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.orange.shade400],
                ),
              ),
              child: const Icon(Icons.lock, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock $feature',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is available with Premium subscription. Upgrade now to access unlimited features!',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 16),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Unlimited Calculator Uses')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 16),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Unlimited AI Chat')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 16),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Advanced Analytics')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              if (onUpgrade != null) {
                onUpgrade!();
              } else {
                Navigator.pushNamed(context, '/premium-services');
              }
            },
            icon: const Icon(Icons.diamond),
            label: const Text('Upgrade Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎯 Premium Badge Widget
/// Shows a small premium badge for premium features
class PremiumBadge extends StatelessWidget {
  final bool showText;
  final double size;

  const PremiumBadge({
    super.key,
    this.showText = true,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 8 : 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade300, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond, color: Colors.white, size: size * 0.8),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              'PRO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 💎 Usage Limit Badge
/// Shows current usage vs limit for free users
class UsageLimitBadge extends StatelessWidget {
  final String feature;
  final int used;
  final int limit;

  const UsageLimitBadge({
    super.key,
    required this.feature,
    required this.used,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (used / limit).clamp(0.0, 1.0);
    final isNearLimit = percentage > 0.8;
    final isAtLimit = used >= limit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAtLimit
            ? Colors.red[100]
            : isNearLimit
                ? Colors.orange[100]
                : Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAtLimit
              ? Colors.red[300]!
              : isNearLimit
                  ? Colors.orange[300]!
                  : Colors.blue[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAtLimit ? Icons.block : Icons.info_outline,
            size: 14,
            color: isAtLimit
                ? Colors.red[600]
                : isNearLimit
                    ? Colors.orange[600]
                    : Colors.blue[600],
          ),
          const SizedBox(width: 4),
          Text(
            '$used/$limit',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAtLimit
                  ? Colors.red[700]
                  : isNearLimit
                      ? Colors.orange[700]
                      : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
