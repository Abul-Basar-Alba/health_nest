import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Resources'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FAQs and Guides',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildResourceCard(
              context,
              title: 'Getting Started Guide',
              subtitle: 'Learn how to log your first meal and set goals.',
              icon: Icons.article_rounded,
              onTap: () async {
                final url = Uri.parse('https://your-app.com/getting-started');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            _buildResourceCard(
              context,
              title: 'How BMI is Calculated',
              subtitle: 'A detailed explanation of the BMI formula.',
              icon: Icons.calculate_rounded,
              onTap: () async {
                final url = Uri.parse('https://your-app.com/bmi-guide');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Need More Help?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildResourceCard(
              context,
              title: 'Contact Support',
              subtitle: 'Get in touch with our team for assistance.',
              icon: Icons.support_agent_rounded,
              onTap: () {
                // Navigate to admin contact screen
                Navigator.pushNamed(context, '/admin-contact');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.green),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
