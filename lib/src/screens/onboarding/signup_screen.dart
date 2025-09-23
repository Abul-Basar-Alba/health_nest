// lib/src/screens/onboarding/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart'; // এই লাইনটি যোগ করুন

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final user = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );
      if (!mounted) return;
      userProvider.setUser(user);
      // সঠিক রুট ব্যবহার করে প্রোফাইল সেটআপ স্ক্রিনে যান
      Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : e.toString();
        _isLoading = false;
      });
    }
  }

  // Google Sign-In এর জন্য নতুন ফাংশন
  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final user = await authService.signInWithGoogle();
      if (!mounted) return;
      userProvider.setUser(user);
      // Google Sign-In সফল হলে ড্যাশবোর্ডে বা প্রোফাইল সেটআপে যান
      // এখানে ধরে নেওয়া হচ্ছে, যদি নতুন ব্যবহারকারী হয়, তবে তাকে প্রোফাইল সেটআপে পাঠানো হবে
      // অথবা আপনি সরাসরি ড্যাশবোর্ডে পাঠাতে পারেন যদি প্রোফাইল সেটআপ অটোমেটিক হ্যান্ডেল হয়
      Navigator.pushReplacementNamed(
          context, AppRoutes.dashboard); // অথবা AppRoutes.profileSetup
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : e.toString();
        _isLoading = false;
      });
      // যদি Google Sign-In বাতিল করা হয়, তাহলে মেসেজ দেখানোর দরকার নেই
      if (e.toString().contains('Google Sign-In was cancelled')) {
        _errorMessage = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create an Account',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC4F7D2), // হালকা মিন্ট সবুজ
              Color(0xFFA5DFF5), // হালকা আকাশী নীল
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 60,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'Join our community!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                    labelStyle: const TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.green),
                    labelStyle: const TextStyle(color: Colors.black54),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                    labelStyle: const TextStyle(color: Colors.black54),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.green))
                    : ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        child: const Text('Sign Up',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                const SizedBox(height: 16),
                // Google Sign-In বাটন
                _isLoading
                    ? const SizedBox.shrink() // লোডিং থাকলে বাটন দেখাবে না
                    : ElevatedButton(
                        onPressed: _handleGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.grey)),
                          elevation: 3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/google_logo.png',
                                height: 24), // আপনার Google লোগোর পাথ দিন
                            const SizedBox(width: 8),
                            const Text('Sign Up with Google',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
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
