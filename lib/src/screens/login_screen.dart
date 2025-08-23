// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/user_provider.dart';
// import '../services/auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   LoginScreenState createState() => LoginScreenState();
// }

// class LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//   bool _isSignUp = false;
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   Future<void> _authenticate() async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final authService = AuthService();
//       final userProvider = Provider.of<UserProvider>(context, listen: false);

//       if (_isSignUp) {
//         final user = await authService.signUp(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//           name: _nameController.text.trim(),
//         );
//         if (!mounted) return;
//         userProvider.setUser(user);
//         await Future.delayed(const Duration(milliseconds: 500));
//         Navigator.pushReplacementNamed(context, '/dashboard');
//       } else {
//         final user = await authService.signIn(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//         if (!mounted) return;
//         userProvider.setUser(user);
//         await Future.delayed(const Duration(milliseconds: 500));
//         Navigator.pushReplacementNamed(context, '/dashboard');
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Icon(
//                 Icons.spa_rounded,
//                 size: 80,
//                 color: Colors.green[700],
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'HealthNest',
//                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       color: Colors.green[800],
//                       fontWeight: FontWeight.w900,
//                     ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//               if (_isSignUp)
//                 TextField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Name',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.person),
//                   ),
//                 ),
//               if (_isSignUp) const SizedBox(height: 16),
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 24),
//               if (_errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   child: Text(
//                     _errorMessage!,
//                     style: const TextStyle(color: Colors.red, fontSize: 14),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : ElevatedButton(
//                       onPressed: _authenticate,
//                       child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
//                     ),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _isSignUp = !_isSignUp;
//                     _errorMessage = null;
//                   });
//                 },
//                 child: Text(
//                   _isSignUp
//                       ? 'Already have an account? Sign In'
//                       : 'Don\'t have an account? Sign Up',
//                   style: TextStyle(color: Colors.green[700]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
