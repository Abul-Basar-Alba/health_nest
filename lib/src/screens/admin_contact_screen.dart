// lib/src/screens/admin_contact_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'admin_chat_screen.dart';

class AdminContactScreen extends StatefulWidget {
  const AdminContactScreen({super.key});

  @override
  AdminContactScreenState createState() => AdminContactScreenState();
}

class AdminContactScreenState extends State<AdminContactScreen> {
  // Define a list of common questions and answers
  final List<Map<String, String>> faq = [
    {
      'question': 'How can I reset my password?',
      'answer':
          'You can reset your password from the login screen by clicking on "Forgot Password". We will send a password reset link to your registered email address.'
    },
    {
      'question': 'How does the nutrition tracker work?',
      'answer':
          'The nutrition tracker uses the Edamam API to provide detailed nutritional information for various food items. You can search for food and add it to your daily log to track your calorie intake.'
    },
    {
      'question': 'How can I upgrade my account to premium?',
      'answer':
          'You can upgrade your account to a premium plan by visiting the "Paid Services" section on your dashboard. This will unlock exclusive features like personalized diet plans and one-on-one sessions with our experts.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, how can we help?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Before contacting us, please check if your question is answered below:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 24),
            // FAQ Section
            _buildFaqSection(),
            const SizedBox(height: 32),
            // The new section to initiate a chat
            Text(
              'Still need to talk to a human?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  final currentUser = userProvider.user;

                  if (currentUser != null) {
                    const String adminId = 'SZQYWWWw28fza8MiWYep8snmcox1';
                    // Navigate to the chat screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdminChatScreen(
                          recipientId: adminId,
                          recipientName: 'Admin',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.support_agent_rounded),
                label: const Text('Chat with Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: faq.length,
      itemBuilder: (context, index) {
        return ExpansionTile(
          title: Text(faq[index]['question']!,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(faq[index]['answer']!),
            ),
          ],
        );
      },
    );
  }
}
