// lib/src/screens/premium_services_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../services/freemium_service.dart';
import '../services/payment_service.dart';

class PremiumServicesScreen extends StatefulWidget {
  const PremiumServicesScreen({super.key});

  @override
  State<PremiumServicesScreen> createState() => _PremiumServicesScreenState();
}

class _PremiumServicesScreenState extends State<PremiumServicesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int selectedPlanIndex = 0; // 0 = Monthly, 1 = Yearly

  final List<Map<String, dynamic>> plans = [
    {
      'title': 'Monthly Premium',
      'price': '৳999',
      'period': '/month',
      'originalPrice': '৳1,499',
      'discount': '33% OFF',
      'features': [
        'Unlimited Calculator Uses',
        'Unlimited AI Health Chat',
        'Advanced Analytics Dashboard',
        'Personalized Meal Plans',
        'Custom Workout Routines',
        'Priority Customer Support',
        'Offline Access',
        'Family Sharing (up to 4 members)',
      ],
      'paymentAmount': 999,
      'popular': false,
    },
    {
      'title': 'Yearly Premium',
      'price': '৳8,999',
      'period': '/year',
      'originalPrice': '৳17,988',
      'discount': '50% OFF',
      'features': [
        'Everything in Monthly Plan',
        'Personal Health Coach Access',
        'Advanced Progress Tracking',
        'Custom Health Reports',
        'Nutrition Consultation',
        'Fitness Trainer Access',
        'Premium Course Library',
        'Early Access to New Features',
      ],
      'paymentAmount': 8999,
      'popular': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.green.shade50,
              Colors.amber.shade50,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          elevation: 2,
          backgroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.amber[50]!,
                ],
              ),
            ),
            child: FlexibleSpaceBar(
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.diamond,
                    color: Colors.amber[700],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Premium Services',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // Hero Section
        SliverToBoxAdapter(
          child: _buildHeroSection(),
        ),

        // Current Usage Status
        SliverToBoxAdapter(
          child: _buildCurrentUsageCard(),
        ),

        // Pricing Plans
        SliverToBoxAdapter(
          child: _buildPricingSection(),
        ),

        // Features Comparison
        SliverToBoxAdapter(
          child: _buildFeaturesComparison(),
        ),

        // CTA Section
        SliverToBoxAdapter(
          child: _buildCTASection(),
        ),

        // FAQ
        SliverToBoxAdapter(
          child: _buildFAQSection(),
        ),

        // Bottom Spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Main Hero Animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: 120,
                  height: 120,
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
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.diamond,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Unlock Your Full Potential',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Join thousands of users who have transformed their health journey with premium features',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUsageCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _buildUsageData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final data = snapshot.data!;
          final isPremium = data['isPremium'] as bool;

          if (isPremium) {
            return Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade100, Colors.orange.shade100],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green[600], size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You\'re Already Premium! 🎉',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800],
                            ),
                          ),
                          Text(
                            'Enjoying unlimited access to all features',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final usage = data['usage'] as Map<String, int>;
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.green.shade50],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Current Usage Today',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildUsageRow('🧮 Calculator', usage['calculator'] ?? 0, 20,
                      Colors.orange),
                  _buildUsageRow(
                      '🤖 AI Chat', usage['chat'] ?? 0, 500, Colors.purple),
                  _buildUsageRow('🥗 Nutrition', usage['nutrition'] ?? 0, 10,
                      Colors.green),
                  _buildUsageRow(
                      '👥 Community', usage['community'] ?? 0, 3, Colors.blue),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Upgrade to Premium for unlimited access!',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsageRow(String feature, int used, int limit, Color color) {
    final percentage = (used / limit).clamp(0.0, 1.0);
    final isNearLimit = percentage > 0.8;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$used/$limit',
                  style: TextStyle(
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
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Choose Your Plan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cancel anytime • 7-day free trial included',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Plan Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedPlanIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedPlanIndex == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: selectedPlanIndex == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        'Monthly',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedPlanIndex == 0
                              ? Colors.black87
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedPlanIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedPlanIndex == 1
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: selectedPlanIndex == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Yearly',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedPlanIndex == 1
                                  ? Colors.black87
                                  : Colors.grey[600],
                            ),
                          ),
                          if (selectedPlanIndex == 1) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'SAVE 50%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Selected Plan Card
          _buildPlanCard(plans[selectedPlanIndex]),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: plan['popular']
              ? [Colors.amber.shade100, Colors.orange.shade100]
              : [Colors.blue.shade50, Colors.green.shade50],
        ),
        border: Border.all(
          color: plan['popular'] ? Colors.amber.shade300 : Colors.blue.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (plan['popular'])
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: const Text(
                '🔥 MOST POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Title & Discount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        plan['discount'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pricing
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan['price'],
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      plan['period'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      plan['originalPrice'],
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Features
                ...plan['features'].map<Widget>((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green[600], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),

                // Free Trial Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _startFreeTrial(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_border, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Start 7-Day Free Trial',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Premium Payment Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => _startPayment(plan),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: plan['popular']
                              ? Colors.amber[600]!
                              : Colors.blue[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payment, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Subscribe Now - ${plan['price']}${plan['period']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Then ${plan['price']}${plan['period']} • Cancel anytime',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Free vs Premium Comparison',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildComparisonRow('Calculator Uses', '20/day', 'Unlimited'),
              _buildComparisonRow('AI Health Chat', '500/day', 'Unlimited'),
              _buildComparisonRow('Nutrition Logs', '10/day', 'Unlimited'),
              _buildComparisonRow('Community Posts', '3/day', 'Unlimited'),
              _buildComparisonRow('Analytics Dashboard', '❌', '✅'),
              _buildComparisonRow('Personal Meal Plans', '❌', '✅'),
              _buildComparisonRow('Expert Coach Access', '❌', '✅'),
              _buildComparisonRow('Priority Support', '❌', '✅'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String feature, String free, String premium) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Join 10,000+ Premium Users',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Transform your health journey today with personalized AI coaching and unlimited access to all features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Free Trial Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _startFreeTrial(plans[selectedPlanIndex]),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Start Your Free Trial Now',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Payment Button
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: () => _startPayment(plans[selectedPlanIndex]),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Skip Trial - Subscribe Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'Can I cancel anytime?',
                'Yes! You can cancel your subscription at any time. No questions asked.',
              ),
              _buildFAQItem(
                'What payment methods do you accept?',
                'We accept all major payment methods through SSLCommerz including bKash, Nagad, Rocket, and all major banks.',
              ),
              _buildFAQItem(
                'Is my data secure?',
                'Absolutely! We use bank-level encryption and never share your personal health data.',
              ),
              _buildFAQItem(
                'Do you offer refunds?',
                'We offer a 7-day free trial. If you\'re not satisfied, you can cancel before the trial ends.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _buildUsageData() async {
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

  // Free Trial Method - No payment required
  void _startFreeTrial(Map<String, dynamic> plan) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('দয়া করে প্রথমে লগইন করুন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user already used free trial
    if (await FreemiumService.hasUsedFreeTrial()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Free Trial Already Used',
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'আপনি আগেই ৭ দিনের ফ্রি ট্রায়াল ব্যবহার করেছেন। '
                  'এখন প্রিমিয়াম সাবস্ক্রিপশনের জন্য পেমেন্ট করতে হবে।',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ঠিক আছে', style: TextStyle(fontSize: 14)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startPayment(plan);
              },
              child: const Text('পেমেন্ট করুন', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      );
      return;
    }

    // Start free trial
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('আপনার ৭ দিনের ফ্রি ট্রায়াল শুরু হচ্ছে...'),
          ],
        ),
      ),
    );

    try {
      // Activate free trial
      await FreemiumService.startFreeTrial();

      Navigator.pop(context); // Close loading dialog

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.celebration, color: Colors.green[600]),
              const SizedBox(width: 8),
              const Text('ফ্রি ট্রায়াল শুরু!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎉 অভিনন্দন! আপনার ৭ দিনের ফ্রি ট্রায়াল শুরু হয়েছে।',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('✅ সব প্রিমিয়াম ফিচার এখন unlocked'),
              const Text('✅ কোন লিমিট নেই'),
              const Text('✅ যেকোনো সময় cancel করতে পারবেন'),
              const SizedBox(height: 12),
              Text(
                'ট্রায়াল শেষ হওয়ার পর automatic renewal হবে না। '
                'চালিয়ে যেতে চাইলে subscription করতে হবে।',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to previous screen
              },
              child: const Text('শুরু করুন!'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ত্রুটি হয়েছে: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Premium Payment Method - SSLCommerz integration
  void _startPayment(Map<String, dynamic> plan) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first to subscribe'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show payment options dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.blue[600], size: 20),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Amount: ${plan['price']}${plan['period']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: PaymentService.getPaymentMethods().length,
                  itemBuilder: (context, index) {
                    final method = PaymentService.getPaymentMethods()[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        leading: Text(
                          method['icon'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        title: Text(
                          method['name'],
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          method['description'],
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          Navigator.pop(context);
                          _processPayment(plan, method);
                        },
                      ),
                    );
                  },
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
        ],
      ),
    );
  }

  // Process payment with selected method
  void _processPayment(
      Map<String, dynamic> plan, Map<String, dynamic> paymentMethod) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user!;

    // Show payment processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Initializing ${paymentMethod['name']} payment...'),
            const SizedBox(height: 8),
            Text(
              'Amount: ${plan['price']}${plan['period']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    try {
      // Initialize payment with SSLCommerz
      final paymentResult = await PaymentService.initializePayment(
        customerName: user.name,
        customerEmail: user.email,
        customerPhone: '+8801700000000', // Default phone number
        amount: plan['paymentAmount'].toDouble(),
        productName: plan['title'],
        productCategory: 'health_app_subscription',
      );

      Navigator.pop(context); // Close loading dialog

      if (paymentResult['success']) {
        // Payment gateway initialized successfully
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Payment Gateway Ready',
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ SSLCommerz Demo Payment Ready!',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '📱 Demo Payment করতে:',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // bKash Demo Info
                  if (paymentMethod['name'] == 'bKash') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.pink[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💰 bKash Demo:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('• Mobile: 01700000000',
                              style: TextStyle(fontSize: 12)),
                          Text('• PIN: 1234', style: TextStyle(fontSize: 12)),
                          Text('• OTP: 123456', style: TextStyle(fontSize: 12)),
                          Text('• Amount: ৳${plan['paymentAmount']}',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],

                  // Nagad Demo Info
                  if (paymentMethod['name'] == 'Nagad') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💸 Nagad Demo:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('• Mobile: 01600000000',
                              style: TextStyle(fontSize: 12)),
                          Text('• PIN: 1234', style: TextStyle(fontSize: 12)),
                          Text('• OTP: 123456', style: TextStyle(fontSize: 12)),
                          Text('• Amount: ৳${plan['paymentAmount']}',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],

                  // Card Demo Info
                  if (paymentMethod['name'].contains('Card')) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💳 Demo Card:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('• Card: 4242424242424242',
                              style: TextStyle(fontSize: 12)),
                          Text('• CVV: 123', style: TextStyle(fontSize: 12)),
                          Text('• Expiry: 12/25',
                              style: TextStyle(fontSize: 12)),
                          Text('• Amount: ৳${plan['paymentAmount']}',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaction Details:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('ID: ${paymentResult['tran_id']}'),
                        Text('Amount: ৳${paymentResult['amount']}'),
                        Text('Method: ${paymentMethod['name']}'),
                        Text(
                            'Store: ${paymentResult['demo_info']['store_id']}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '🎯 Real Production এ: Backend API দিয়ে proper payment gateway integration হবে। '
                    'এখন demo mode এ test করতে পারেন।',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _simulatePaymentSuccess(plan, paymentResult);
                },
                child: const Text('Complete Demo Payment'),
              ),
            ],
          ),
        );
      } else {
        // Payment initialization failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${paymentResult['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Simulate successful payment (for demo purposes)
  void _simulatePaymentSuccess(
      Map<String, dynamic> plan, Map<String, dynamic> paymentResult) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎉 Payment completed successfully!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Text(
                '✅ Premium subscription activated',
                style: TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                '✅ All features unlocked',
                style: TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                '✅ SMS confirmation sent',
                style: TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscription Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan: ${plan['title']}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Amount: ${plan['price']}${plan['period']}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Transaction: ${paymentResult['tran_id']}',
                      style: const TextStyle(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Status: Active',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'আপনার প্রিমিয়াম সাবস্ক্রিপশন এখনই active হয়ে গেছে! '
                'সব ফিচার এখন unlimited ব্যবহার করতে পারবেন।',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Great! Start Using',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
