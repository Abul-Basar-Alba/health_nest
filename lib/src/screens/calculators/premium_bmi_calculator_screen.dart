// lib/src/screens/calculators/premium_bmi_calculator_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../services/history_service.dart';

class PremiumBMICalculatorScreen extends StatefulWidget {
  const PremiumBMICalculatorScreen({super.key});

  @override
  State<PremiumBMICalculatorScreen> createState() =>
      _PremiumBMICalculatorScreenState();
}

class _PremiumBMICalculatorScreenState extends State<PremiumBMICalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedActivityLevel = 'Moderate';
  bool _showResult = false;
  bool _isSaved = false; // Track if result is saved

  // Results
  double _bmi = 0.0;
  String _bmiCategory = '';
  Color _bmiColor = Colors.green;
  double _bmr = 0.0;
  double _dailyCalories = 0.0;
  double _idealWeight = 0.0;
  double _bodyFat = 0.0;
  String _healthAdvice = '';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active'
  ];

  final Map<String, double> _activityMultipliers = {
    'Sedentary': 1.2,
    'Light': 1.375,
    'Moderate': 1.55,
    'Active': 1.725,
    'Very Active': 1.9,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageController.text);
    final weight = double.parse(_weightController.text);
    final height = double.parse(_heightController.text);

    // Calculate BMI
    final heightInMeters = height / 100;
    _bmi = weight / (heightInMeters * heightInMeters);

    // Determine BMI Category
    if (_bmi < 18.5) {
      _bmiCategory = 'Underweight';
      _bmiColor = Colors.blue;
      _healthAdvice =
          'You may need to gain some weight. Consult a nutritionist for a healthy diet plan.';
    } else if (_bmi < 25) {
      _bmiCategory = 'Normal';
      _bmiColor = Colors.green;
      _healthAdvice =
          'Great! You\'re in a healthy weight range. Keep up the good work!';
    } else if (_bmi < 30) {
      _bmiCategory = 'Overweight';
      _bmiColor = Colors.orange;
      _healthAdvice =
          'Consider a balanced diet and regular exercise to reach a healthier weight.';
    } else {
      _bmiCategory = 'Obese';
      _bmiColor = Colors.red;
      _healthAdvice =
          'Consult a healthcare professional for a personalized weight loss plan.';
    }

    // Calculate BMR (Basal Metabolic Rate)
    if (_selectedGender == 'Male') {
      _bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      _bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Calculate Daily Calories
    _dailyCalories =
        _bmr * (_activityMultipliers[_selectedActivityLevel] ?? 1.2);

    // Calculate Ideal Weight (using Devine formula)
    if (_selectedGender == 'Male') {
      _idealWeight = 50 + 2.3 * ((height / 2.54) - 60);
    } else {
      _idealWeight = 45.5 + 2.3 * ((height / 2.54) - 60);
    }

    // Estimate Body Fat Percentage (simplified formula)
    if (_selectedGender == 'Male') {
      _bodyFat = 1.20 * _bmi + 0.23 * age - 16.2;
    } else {
      _bodyFat = 1.20 * _bmi + 0.23 * age - 5.4;
    }
    _bodyFat = _bodyFat.clamp(0, 100);

    setState(() {
      _showResult = true;
      _isSaved = false; // Reset saved status
    });

    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isPremium = userProvider.user?.isPremium ?? false;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea), // Purple
              const Color(0xFF764ba2), // Dark Purple
              const Color(0xFFF093FB), // Pink
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: _showResult
                    ? _buildResultView(isPremium)
                    : _buildInputForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BMI Calculator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Track your health metrics',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.stars, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

  Widget _buildInputForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInLeft(
              duration: const Duration(milliseconds: 600),
              child: _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Gender',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderOption('Male', Icons.male),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGenderOption('Female', Icons.female),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 100),
              child: _buildGlassCard(
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.cake,
                      suffix: 'years',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final age = int.tryParse(value);
                        if (age == null || age < 10 || age > 100) {
                          return '10-100 years';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _weightController,
                      label: 'Weight',
                      icon: Icons.monitor_weight,
                      suffix: 'kg',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 20 || weight > 300) {
                          return '20-300 kg';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _heightController,
                      label: 'Height',
                      icon: Icons.height,
                      suffix: 'cm',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final height = double.tryParse(value);
                        if (height == null || height < 100 || height > 250) {
                          return '100-250 cm';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInLeft(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity Level',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _activityLevels.map((level) {
                        return _buildActivityChip(level);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 300),
              child: _buildCalculateButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(bool isPremium) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // BMI Result Card
          FadeIn(
            duration: const Duration(milliseconds: 600),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildGlassCard(
                child: Column(
                  children: [
                    const Text(
                      'Your BMI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _bmiColor.withOpacity(0.3),
                            _bmiColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _bmiColor.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _bmi.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _bmiCategory,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _healthAdvice,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Basic Metrics (Always visible)
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.insights, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Basic Metrics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMetricRow('BMR (Base Metabolic Rate)',
                      '${_bmr.toStringAsFixed(0)} kcal/day'),
                  _buildMetricRow('Daily Calories',
                      '${_dailyCalories.toStringAsFixed(0)} kcal/day'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Premium Metrics (Locked for non-premium)
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: _buildPremiumMetrics(isPremium),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          const SizedBox(height: 16),

          // Action Buttons
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 600),
            child: _isSaved
                ? _buildRecommendationButtons()
                : _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Recalculate',
            Icons.refresh,
            Colors.white.withOpacity(0.2),
            () {
              setState(() {
                _showResult = false;
                _isSaved = false;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            'Save Result',
            Icons.save,
            const Color(0xFF667eea).withOpacity(0.8),
            () async {
              // Save to history
              try {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  final historyService = HistoryService();

                  await historyService.saveBMIHistory(
                    userId: userId,
                    bmi: _bmi,
                    category: _bmiCategory,
                    weight: double.parse(_weightController.text),
                    height: double.parse(_heightController.text),
                    age: int.parse(_ageController.text),
                    gender: _selectedGender,
                    activityLevel: _selectedActivityLevel,
                    bmr: _bmr,
                    dailyCalories: _dailyCalories.toInt(),
                    idealWeight: _idealWeight,
                    bodyFat: _bodyFat,
                  );

                  setState(() {
                    _isSaved = true;
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Result saved to history successfully! 🎉'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      children: [
        if (isMobile)
          // Mobile: Stack buttons vertically
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  'Recommendations',
                  Icons.lightbulb,
                  const Color(0xFFFFD700).withOpacity(0.9),
                  () {
                    Navigator.pushNamed(context, '/recommendations');
                  },
                  isMobile: true,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  'Nutrition Plan',
                  Icons.restaurant_menu,
                  const Color(0xFF00B894).withOpacity(0.9),
                  () {
                    Navigator.pushNamed(context, '/nutrition');
                  },
                  isMobile: true,
                ),
              ),
            ],
          )
        else
          // Desktop: Keep buttons side by side
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Recommendations',
                  Icons.lightbulb,
                  const Color(0xFFFFD700).withOpacity(0.9),
                  () {
                    Navigator.pushNamed(context, '/recommendations');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'Nutrition Plan',
                  Icons.restaurant_menu,
                  const Color(0xFF00B894).withOpacity(0.9),
                  () {
                    Navigator.pushNamed(context, '/nutrition');
                  },
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        // Beautiful back button with gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isSaved = false;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Back to actions',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumMetrics(bool isPremium) {
    if (isPremium) {
      return _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Premium Metrics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
                'Ideal Weight', '${_idealWeight.toStringAsFixed(1)} kg'),
            _buildMetricRow('Body Fat %', '${_bodyFat.toStringAsFixed(1)}%'),
            _buildMetricRow('Weight to Goal',
                '${(_weightController.text.isEmpty ? 0 : double.parse(_weightController.text) - _idealWeight).abs().toStringAsFixed(1)} kg'),
            const SizedBox(height: 16),
            _buildProgressBar('Body Fat', _bodyFat, 30),
          ],
        ),
      );
    } else {
      return _buildLockedPremiumCard();
    }
  }

  Widget _buildLockedPremiumCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(0.2),
                      border: Border.all(color: Colors.amber, width: 3),
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 40,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Premium Metrics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock advanced health insights',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureChip('Ideal Weight'),
                      _buildFeatureChip('Body Fat %'),
                      _buildFeatureChip('Weight Goals'),
                      _buildFeatureChip('Progress Tracking'),
                      _buildFeatureChip('Personalized Tips'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/premium-services');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.workspace_premium,
                                  color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Upgrade to Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: child,
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => setState(() => _selectedGender = gender),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.6)
                : Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon, color: Colors.white),
        suffixText: suffix,
        suffixStyle:
            const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        errorStyle: const TextStyle(
            color: Colors.redAccent, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildActivityChip(String level) {
    final isSelected = _selectedActivityLevel == level;
    return FilterChip(
      label: Text(
        level,
        style: TextStyle(
          color: isSelected ? const Color(0xFF667eea) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedActivityLevel = level);
      },
      backgroundColor: Colors.white.withOpacity(0.9),
      selectedColor: Colors.white,
      checkmarkColor: const Color(0xFF667eea),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF667eea) : Colors.black26,
          width: isSelected ? 3 : 1.5,
        ),
      ),
      elevation: isSelected ? 8 : 2,
      shadowColor: isSelected
          ? const Color(0xFF667eea).withOpacity(0.5)
          : Colors.black26,
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFFF093FB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _calculate,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calculate, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Calculate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, double max) {
    final percentage = (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFFF093FB)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isMobile = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: isMobile ? 22 : 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
