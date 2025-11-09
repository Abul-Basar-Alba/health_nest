// lib/src/screens/auth/profile_setup_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../config/auth_colors.dart';
import '../../services/enhanced_auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String userId;

  const ProfileSetupScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _authService = EnhancedAuthService();
  final _pageController = PageController();

  int _currentPage = 0;
  bool _isLoading = false;

  // Profile data
  String _gender = 'Male';
  int _age = 25;
  double _weight = 70.0; // kg
  double _height = 170.0; // cm
  String _activityLevel = 'Moderate';

  // BMI data
  double _bmi = 0.0;
  String _bmiCategory = '';
  Color _bmiCategoryColor = AuthColors.accentGreen;
  int _dailyCalories = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      print('📄 Moving to next page from $_currentPage to ${_currentPage + 1}');
      _pageController.nextPage(
        duration: AuthConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      print('⚠️ Already at last page (5)');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AuthConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _calculateBMI() {
    final heightInMeters = _height / 100;
    _bmi = _weight / (heightInMeters * heightInMeters);

    if (_bmi < 18.5) {
      _bmiCategory = 'Underweight';
      _bmiCategoryColor = AuthColors.bmiUnderweight;
    } else if (_bmi < 25) {
      _bmiCategory = 'Normal';
      _bmiCategoryColor = AuthColors.bmiNormal;
    } else if (_bmi < 30) {
      _bmiCategory = 'Overweight';
      _bmiCategoryColor = AuthColors.bmiOverweight;
    } else {
      _bmiCategory = 'Obese';
      _bmiCategoryColor = AuthColors.bmiObese;
    }

    // Calculate daily calories
    double bmr;
    if (_gender == 'Male') {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age + 5;
    } else {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age - 161;
    }

    final activityMultiplier =
        AuthConstants.activityLevelMultipliers[_activityLevel] ?? 1.55;
    _dailyCalories = (bmr * activityMultiplier).round();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    _calculateBMI();

    print('🔵 Saving profile with:');
    print('  Gender: $_gender');
    print('  Age: $_age');
    print('  Weight: $_weight kg');
    print('  Height: $_height cm');
    print('  Activity: $_activityLevel');
    print('  BMI: ${_bmi.toStringAsFixed(1)}');
    print('  Category: $_bmiCategory');
    print('  Calories: $_dailyCalories');

    final result = await _authService.saveUserProfile(
      userId: widget.userId,
      gender: _gender,
      age: _age,
      weight: _weight,
      height: _height,
      activityLevel: _activityLevel,
    );

    print('🔵 Save result: $result');

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      print('✅ Profile saved successfully, navigating to BMI page');
      // Show BMI page
      _nextPage();
    } else {
      print('❌ Profile save failed: ${result['message']}');
      _showErrorSnackBar(result['message']);
    }
  }

  void _completeSetup() {
    print('🏠 Completing setup, navigating to main navigation...');
    // Navigate to MainNavigation (with bottom bar)
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/main', // MainNavigation widget with bottom bar
      (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AuthColors.accentCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuthColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Page Indicator
              if (_currentPage < 4)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AuthConstants.largePadding,
                  ),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 5,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: AuthColors.accentBlue,
                      dotColor: AuthColors.lightGrey,
                    ),
                  ),
                ),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _buildGenderPage(),
                    _buildAgePage(),
                    _buildWeightPage(),
                    _buildHeightPage(),
                    _buildActivityPage(),
                    _buildBMIResultPage(),
                  ],
                ),
              ),

              // Navigation Buttons
              if (_currentPage < 5) _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.all(AuthConstants.largePadding),
        child: Row(
          children: [
            if (_currentPage > 0 && _currentPage < 5)
              IconButton(
                onPressed: _previousPage,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AuthColors.darkNavy,
                ),
              ),
            Expanded(
              child: Text(
                _currentPage < 5
                    ? 'Complete Your Profile'
                    : 'Your Health Report',
                style: AuthTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
            ),
            if (_currentPage > 0 && _currentPage < 5)
              const SizedBox(width: 48), // Balance the back button
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPage() {
    return FadeInUp(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AuthConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Icon(
              Icons.person_outline,
              size: 80,
              color: AuthColors.accentBlue,
            ),
            const SizedBox(height: AuthConstants.largePadding),
            const Text(
              'What\'s your gender?',
              style: AuthTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuthConstants.xlargePadding),
            Row(
              children: [
                Expanded(
                  child: _buildGenderCard('Male', Icons.male),
                ),
                const SizedBox(width: AuthConstants.largePadding),
                Expanded(
                  child: _buildGenderCard('Female', Icons.female),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(String gender, IconData icon) {
    final isSelected = _gender == gender;
    return GestureDetector(
      onTap: () => setState(() => _gender = gender),
      child: AnimatedContainer(
        duration: AuthConstants.fastAnimation,
        padding: const EdgeInsets.all(AuthConstants.xlargePadding),
        decoration: BoxDecoration(
          color: isSelected ? AuthColors.accentBlue : Colors.white,
          borderRadius: BorderRadius.circular(AuthConstants.largeRadius),
          border: Border.all(
            color: isSelected ? AuthColors.accentBlue : AuthColors.lightGrey,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AuthColors.accentBlue.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 60,
              color: isSelected ? Colors.white : AuthColors.accentBlue,
            ),
            const SizedBox(height: AuthConstants.mediumPadding),
            Text(
              gender,
              style: AuthTextStyles.heading3.copyWith(
                color: isSelected ? Colors.white : AuthColors.darkNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgePage() {
    return FadeInUp(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AuthConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Icon(
              Icons.cake_outlined,
              size: 80,
              color: AuthColors.accentBlue,
            ),
            const SizedBox(height: AuthConstants.largePadding),
            const Text(
              'How old are you?',
              style: AuthTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuthConstants.xlargePadding),
            Container(
              padding: const EdgeInsets.all(AuthConstants.xlargePadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AuthConstants.largeRadius),
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
                  Text(
                    '$_age',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: AuthColors.accentBlue,
                    ),
                  ),
                  const Text(
                    'years',
                    style: AuthTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AuthConstants.largePadding),
                  Slider(
                    value: _age.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 90,
                    activeColor: AuthColors.accentBlue,
                    onChanged: (value) {
                      setState(() => _age = value.round());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightPage() {
    return FadeInUp(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AuthConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Icon(
              Icons.monitor_weight_outlined,
              size: 80,
              color: AuthColors.accentBlue,
            ),
            const SizedBox(height: AuthConstants.largePadding),
            const Text(
              'What\'s your weight?',
              style: AuthTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuthConstants.xlargePadding),
            Container(
              padding: const EdgeInsets.all(AuthConstants.xlargePadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AuthConstants.largeRadius),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _weight.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: AuthColors.accentBlue,
                        ),
                      ),
                      const SizedBox(width: AuthConstants.smallPadding),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'kg',
                          style: AuthTextStyles.heading3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AuthConstants.largePadding),
                  Slider(
                    value: _weight,
                    min: 30,
                    max: 200,
                    divisions: 340,
                    activeColor: AuthColors.accentBlue,
                    onChanged: (value) {
                      setState(() => _weight = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightPage() {
    return FadeInUp(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AuthConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Icon(
              Icons.height_outlined,
              size: 80,
              color: AuthColors.accentBlue,
            ),
            const SizedBox(height: AuthConstants.largePadding),
            const Text(
              'What\'s your height?',
              style: AuthTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuthConstants.xlargePadding),
            Container(
              padding: const EdgeInsets.all(AuthConstants.xlargePadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AuthConstants.largeRadius),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _height.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: AuthColors.accentBlue,
                        ),
                      ),
                      const SizedBox(width: AuthConstants.smallPadding),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'cm',
                          style: AuthTextStyles.heading3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AuthConstants.largePadding),
                  Slider(
                    value: _height,
                    min: 100,
                    max: 250,
                    divisions: 300,
                    activeColor: AuthColors.accentBlue,
                    onChanged: (value) {
                      setState(() => _height = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPage() {
    return FadeInUp(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AuthConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.directions_run,
              size: 60,
              color: AuthColors.accentBlue,
            ),
            const SizedBox(height: AuthConstants.mediumPadding),
            const Text(
              'Activity Level',
              style: AuthTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuthConstants.smallPadding),
            Text(
              'How active are you daily?',
              style: AuthTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuthConstants.largePadding),
            ...AuthConstants.activityLevels.map((level) {
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: AuthConstants.smallPadding),
                child: _buildActivityCard(level),
              );
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String level) {
    final isSelected = _activityLevel == level;
    String description = '';

    switch (level) {
      case 'Sedentary':
        description = 'Little or no exercise';
        break;
      case 'Light':
        description = 'Exercise 1-3 times/week';
        break;
      case 'Moderate':
        description = 'Exercise 4-5 times/week';
        break;
      case 'Active':
        description = 'Daily exercise or intense 3-4 times/week';
        break;
      case 'Very Active':
        description = 'Intense exercise 6-7 times/week';
        break;
    }

    return GestureDetector(
      onTap: () => setState(() => _activityLevel = level),
      child: AnimatedContainer(
        duration: AuthConstants.fastAnimation,
        padding: const EdgeInsets.all(AuthConstants.mediumPadding),
        decoration: BoxDecoration(
          color: isSelected ? AuthColors.accentBlue : Colors.white,
          borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
          border: Border.all(
            color: isSelected ? AuthColors.accentBlue : AuthColors.lightGrey,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AuthColors.accentBlue.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.white : AuthColors.accentBlue,
            ),
            const SizedBox(width: AuthConstants.mediumPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: AuthTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AuthColors.darkNavy,
                    ),
                  ),
                  Text(
                    description,
                    style: AuthTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : AuthColors.mediumGrey,
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

  Widget _buildBMIResultPage() {
    return FadeInUp(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AuthConstants.largePadding),
        child: Column(
          children: [
            // BMI Circle
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: _bmiCategoryColor.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: _bmiCategoryColor,
                    ),
                  ),
                  const Text(
                    'BMI',
                    style: AuthTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AuthConstants.largePadding),

            // BMI Category Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AuthConstants.largePadding,
                vertical: AuthConstants.mediumPadding,
              ),
              decoration: BoxDecoration(
                color: _bmiCategoryColor,
                borderRadius: BorderRadius.circular(AuthConstants.largeRadius),
              ),
              child: Text(
                _bmiCategory,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: AuthConstants.xlargePadding),

            // Health Stats Card
            Container(
              padding: const EdgeInsets.all(AuthConstants.largePadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AuthConstants.largeRadius),
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
                  const Text(
                    'Your Health Summary',
                    style: AuthTextStyles.heading3,
                  ),
                  const SizedBox(height: AuthConstants.largePadding),
                  _buildStatRow(Icons.person, 'Gender', _gender),
                  _buildStatRow(Icons.cake, 'Age', '$_age years'),
                  _buildStatRow(Icons.monitor_weight, 'Weight',
                      '${_weight.toStringAsFixed(1)} kg'),
                  _buildStatRow(Icons.height, 'Height',
                      '${_height.toStringAsFixed(1)} cm'),
                  _buildStatRow(
                      Icons.directions_run, 'Activity', _activityLevel),
                  const Divider(height: AuthConstants.xlargePadding),
                  _buildStatRow(
                    Icons.local_fire_department,
                    'Daily Calories',
                    '$_dailyCalories kcal',
                    highlight: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AuthConstants.xlargePadding),

            // BMI Categories Reference
            Container(
              padding: const EdgeInsets.all(AuthConstants.largePadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BMI Categories',
                    style: AuthTextStyles.heading3,
                  ),
                  const SizedBox(height: AuthConstants.mediumPadding),
                  _buildBMICategoryRow(
                      'Underweight', '< 18.5', AuthColors.bmiUnderweight),
                  _buildBMICategoryRow(
                      'Normal', '18.5 - 24.9', AuthColors.bmiNormal),
                  _buildBMICategoryRow(
                      'Overweight', '25 - 29.9', AuthColors.bmiOverweight),
                  _buildBMICategoryRow('Obese', '≥ 30', AuthColors.bmiObese),
                ],
              ),
            ),

            const SizedBox(height: AuthConstants.xlargePadding),

            // Complete Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _completeSetup,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                  ),
                  elevation: AuthConstants.mediumElevation,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AuthColors.primaryButtonGradient,
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Start Your Journey',
                      style: AuthTextStyles.buttonText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuthConstants.mediumPadding),
      child: Row(
        children: [
          Icon(
            icon,
            color: highlight ? AuthColors.accentCoral : AuthColors.accentBlue,
            size: 24,
          ),
          const SizedBox(width: AuthConstants.mediumPadding),
          Expanded(
            child: Text(
              label,
              style: AuthTextStyles.bodyLarge,
            ),
          ),
          Text(
            value,
            style: AuthTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: highlight ? AuthColors.accentCoral : AuthColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICategoryRow(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuthConstants.smallPadding),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AuthConstants.mediumPadding),
          Expanded(
            child: Text(
              category,
              style: AuthTextStyles.bodyMedium,
            ),
          ),
          Text(
            range,
            style: AuthTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AuthConstants.largePadding,
          AuthConstants.mediumPadding,
          AuthConstants.largePadding,
          AuthConstants.largePadding,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : _currentPage == 4
                    ? _saveProfile
                    : _nextPage,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
              ),
              elevation: AuthConstants.mediumElevation,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AuthColors.primaryButtonGradient,
                borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
              ),
              child: Container(
                alignment: Alignment.center,
                child: _isLoading
                    ? const SpinKitThreeBounce(
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        _currentPage == 4 ? 'Calculate BMI' : 'Continue',
                        style: AuthTextStyles.buttonText,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
