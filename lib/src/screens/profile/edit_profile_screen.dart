// lib/src/screens/profile/edit_profile_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:health_nest/src/config/auth_colors.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/services/enhanced_auth_service.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = EnhancedAuthService();

  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;

  String? _selectedGender;
  String? _selectedActivityLevel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _heightController = TextEditingController(
      text: user?.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: user?.weight?.toString() ?? '',
    );
    _ageController = TextEditingController(
      text: user?.age?.toString() ?? '',
    );
    _selectedGender = user?.gender;
    _selectedActivityLevel = user?.activityLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final result = await _authService.updateUserProfile(
      userId: userId,
      name: _nameController.text.trim(),
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      age: int.tryParse(_ageController.text),
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        // Refresh user data
        await userProvider.refreshUser();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE3FDFD), // Mint
              const Color(0xFFA6E3E9), // Teal
              const Color(0xFF71C9CE), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: const Text(
                      'Update Your Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    child: _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender Selection
                  FadeInRight(
                    duration: const Duration(milliseconds: 600),
                    child: _buildGenderSelector(),
                  ),
                  const SizedBox(height: 16),

                  // Age Field
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    child: _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 10 || age > 100) {
                          return 'Please enter a valid age (10-100)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Height Field
                  FadeInRight(
                    duration: const Duration(milliseconds: 600),
                    child: _buildTextField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        final height = double.tryParse(value);
                        if (height == null || height < 100 || height > 250) {
                          return 'Please enter a valid height (100-250 cm)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weight Field
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 30 || weight > 200) {
                          return 'Please enter a valid weight (30-200 kg)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activity Level
                  FadeInRight(
                    duration: const Duration(milliseconds: 600),
                    child: _buildActivityLevelSelector(),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF38b6ff),
                            Color(0xFF0072ff),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0072ff).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _saveProfile,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AuthColors.accentBlue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AuthColors.accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
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
          color: isSelected ? AuthColors.accentBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AuthColors.accentBlue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedActivityLevel,
            decoration: InputDecoration(
              prefixIcon:
                  Icon(Icons.fitness_center, color: AuthColors.accentBlue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: const Text('Select activity level'),
            items: AuthConstants.activityLevels.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(level),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedActivityLevel = value);
            },
            validator: (value) {
              if (value == null) {
                return 'Please select your activity level';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
