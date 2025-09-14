// lib/src/screens/documentation_screen.dart

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
              'FAQs',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              question: 'Why is a healthy diet important?',
              answer:
                  'A healthy diet is crucial for maintaining a healthy body weight and preventing chronic diseases. It provides essential nutrients, boosts the immune system, and reduces the risk of heart disease and diabetes.',
            ),
            _buildFAQItem(
              context,
              question: 'What are the benefits of a balanced diet?',
              answer:
                  'A balanced diet improves digestion, boosts energy levels, and enhances mental clarity. It can also lead to better skin health and a reduced risk of certain cancers.',
            ),
            _buildFAQItem(
              context,
              question: 'How does exercise help prevent diseases?',
              answer:
                  'Regular exercise strengthens the heart and lungs, lowers blood pressure, and helps control blood sugar levels. It helps prevent conditions like type 2 diabetes, high blood pressure, and obesity.',
            ),
            _buildFAQItem(
              context,
              question: 'How much exercise should I do regularly?',
              answer:
                  'Adults should aim for at least 150 minutes of moderate-intensity or 75 minutes of vigorous-intensity aerobic exercise per week. Even a 30-minute walk each day is highly beneficial.',
            ),
            const SizedBox(height: 24),
            Text(
              'Guides & Resources',
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
                final url = Uri.parse(
                    'https://www.nhs.uk/live-well/eat-well/how-to-eat-a-balanced-diet/eating-a-balanced-diet/');
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

  Widget _buildFAQItem(BuildContext context,
      {required String question, required String answer}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(question, style: Theme.of(context).textTheme.titleMedium),
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(answer, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
