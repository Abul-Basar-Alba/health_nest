// health_nest/lib/src/screens/help_support_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade600, Colors.indigo.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Frequently Asked Questions',
            icon: Icons.question_answer,
            children: [
              _buildFAQItem(
                context,
                question: 'How do I track my health data?',
                answer:
                    'Go to the Home screen and use the various tracking features like BMI Calculator, Water Intake, Sleep Tracker, etc. All your data is saved automatically.',
              ),
              _buildFAQItem(
                context,
                question: 'How does the AI Chatbot work?',
                answer:
                    'Our AI Chatbot uses advanced language processing to understand your health questions and provide personalized advice in both Bengali and English. Simply tap the green chat button.',
              ),
              _buildFAQItem(
                context,
                question: 'Can I track multiple family members?',
                answer:
                    'Yes! HealthNest supports family profiles. Go to Settings > Family Health to add and manage family members.',
              ),
              _buildFAQItem(
                context,
                question: 'How do I set up medicine reminders?',
                answer:
                    'Navigate to Medicine Reminder section from the drawer menu. Add your medicines with dosage and timing, and you\'ll receive notifications.',
              ),
              _buildFAQItem(
                context,
                question: 'Is my health data secure?',
                answer:
                    'Absolutely! All your health data is encrypted and stored securely in Firebase. We follow strict privacy guidelines and never share your data with third parties.',
              ),
              _buildFAQItem(
                context,
                question: 'How do I use the Pregnancy Tracker?',
                answer:
                    'Go to the Pregnancy section from the drawer. Enter your due date or last menstrual period date, and the app will track your pregnancy week by week with tips and guidance.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Contact Support',
            icon: Icons.support_agent,
            children: [
              _buildContactItem(
                context,
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@healthnest.com',
                onTap: () => _launchEmail('support@healthnest.com'),
              ),
              _buildContactItem(
                context,
                icon: Icons.phone,
                title: 'Phone Support',
                subtitle: '+880 1234-567890',
                onTap: () => _launchPhone('+8801234567890'),
              ),
              _buildContactItem(
                context,
                icon: Icons.chat_bubble,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Tutorials & Guides',
            icon: Icons.school,
            children: [
              _buildGuideItem(
                context,
                title: 'Getting Started',
                subtitle: 'Learn the basics of HealthNest',
                icon: Icons.play_circle_outline,
                onTap: () => Navigator.pushNamed(context, '/documentation'),
              ),
              _buildGuideItem(
                context,
                title: 'Feature Walkthrough',
                subtitle: 'Explore all features step by step',
                icon: Icons.explore,
                onTap: () => _showComingSoon(context),
              ),
              _buildGuideItem(
                context,
                title: 'Video Tutorials',
                subtitle: 'Watch how-to videos',
                icon: Icons.videocam,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Report an Issue',
            icon: Icons.bug_report,
            children: [
              _buildReportItem(
                context,
                title: 'Bug Report',
                subtitle: 'Found a bug? Let us know',
                icon: Icons.bug_report,
                onTap: () => _showBugReportDialog(context),
              ),
              _buildReportItem(
                context,
                title: 'Feature Request',
                subtitle: 'Suggest new features',
                icon: Icons.lightbulb_outline,
                onTap: () => _showFeatureRequestDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.support_agent, size: 60, color: Colors.indigo.shade600),
            const SizedBox(height: 12),
            const Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse FAQs or contact our support team',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.indigo.shade600),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Icon(icon, color: Colors.indigo.shade600),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildGuideItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: Icon(icon, color: Colors.green.shade600),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade50,
          child: Icon(icon, color: Colors.orange.shade600),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAppInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'HealthNest',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2025 HealthNest. All rights reserved.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=HealthNest Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Coming Soon'),
          ],
        ),
        content: const Text(
          'This feature is under development and will be available in the next update!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final TextEditingController bugController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange),
            SizedBox(width: 8),
            Text('Report a Bug'),
          ],
        ),
        content: TextField(
          controller: bugController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Describe the bug you encountered...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showFeatureRequestDialog(BuildContext context) {
    final TextEditingController featureController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('Feature Request'),
          ],
        ),
        content: TextField(
          controller: featureController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Describe the feature you want...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature request submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
