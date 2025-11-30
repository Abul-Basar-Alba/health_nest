// health_nest/lib/src/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isBengali = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isBengali ? 'গোপনীয়তা নীতি' : 'Privacy Policy'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade600, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              setState(() => _isBengali = !_isBengali);
            },
            tooltip: _isBengali ? 'Switch to English' : 'বাংলায় দেখুন',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (_isBengali)
              ..._buildBengaliContent()
            else
              ..._buildEnglishContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.teal.shade700, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isBengali
                      ? 'আপনার গোপনীয়তা আমাদের অগ্রাধিকার'
                      : 'Your Privacy is Our Priority',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isBengali
                ? 'সর্বশেষ আপডেট: ৩০ নভেম্বর, ২০২৫'
                : 'Last Updated: November 30, 2025',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEnglishContent() {
    return [
      _buildSection(
        title: '1. Information We Collect',
        content: '''We collect the following types of information:

• Personal Information: Name, email, phone number, date of birth, gender
• Health Data: Medical records, medicine schedules, pregnancy tracking, menstrual cycle data, blood pressure, glucose levels, weight, sleep patterns
• Device Information: Device type, operating system, unique device identifiers
• Usage Data: App features used, interaction patterns, session duration
• Location Data: Approximate location for nearby healthcare services (with your permission)''',
      ),
      _buildSection(
        title: '2. How We Use Your Information',
        content: '''We use your information to:

• Provide personalized health tracking and recommendations
• Send medicine reminders and health notifications
• Enable AI chatbot health assistance
• Track pregnancy development and women's health cycles
• Generate health reports and analytics
• Improve app functionality and user experience
• Ensure app security and prevent fraud
• Communicate important updates and features''',
      ),
      _buildSection(
        title: '3. Data Storage and Security',
        content: '''Your data security is critical to us:

• All data is encrypted in transit using SSL/TLS
• Stored securely on Firebase Cloud Firestore with encryption at rest
• Regular security audits and vulnerability assessments
• Access controls and authentication mechanisms
• Automatic backups to prevent data loss
• No sharing with third parties without explicit consent''',
      ),
      _buildSection(
        title: '4. Third-Party Services',
        content: '''We integrate with the following services:

• Firebase (Google): Authentication, database, storage, messaging
• Google Sign-In: Optional authentication method
• Payment Gateways: Bkash, Nagad (for premium subscriptions)
• Analytics: Anonymous usage statistics for improvement

Each service has its own privacy policy that governs data handling.''',
      ),
      _buildSection(
        title: '5. Your Rights and Choices',
        content: '''You have the right to:

• Access your personal data at any time
• Update or correct your information
• Delete your account and all associated data
• Opt-out of notifications and marketing communications
• Export your health data in PDF/CSV format
• Withdraw consent for data processing
• Request data portability''',
      ),
      _buildSection(
        title: '6. Data Retention',
        content: '''We retain your data as follows:

• Active accounts: Data retained while account is active
• Deleted accounts: Data permanently deleted within 30 days
• Backup data: Removed from backups within 90 days
• Legal requirements: Data may be retained longer if required by law''',
      ),
      _buildSection(
        title: '7. Children\'s Privacy',
        content:
            '''HealthNest is designed for users 13 years and older. We do not knowingly collect personal information from children under 13. Family profiles for minors must be managed by parents or legal guardians.''',
      ),
      _buildSection(
        title: '8. Changes to Privacy Policy',
        content:
            '''We may update this Privacy Policy periodically. We will notify you of significant changes via:

• In-app notification
• Email notification (if provided)
• Prominent notice on the app

Continued use of the app after changes constitutes acceptance of the updated policy.''',
      ),
      _buildSection(
        title: '9. Contact Us',
        content: '''For privacy concerns or questions:

Email: privacy@healthnest.com
Phone: +880 1234-567890
Address: Dhaka, Bangladesh

We aim to respond to all inquiries within 48 hours.''',
      ),
      const SizedBox(height: 24),
      _buildAcceptanceBox(),
    ];
  }

  List<Widget> _buildBengaliContent() {
    return [
      _buildSection(
        title: '১. আমরা যে তথ্য সংগ্রহ করি',
        content: '''আমরা নিম্নলিখিত ধরনের তথ্য সংগ্রহ করি:

• ব্যক্তিগত তথ্য: নাম, ইমেইল, ফোন নম্বর, জন্ম তারিখ, লিঙ্গ
• স্বাস্থ্য তথ্য: চিকিৎসা রেকর্ড, ওষুধের সময়সূচী, গর্ভাবস্থা ট্র্যাকিং, মাসিক চক্র তথ্য, রক্তচাপ, গ্লুকোজ মাত্রা, ওজন, ঘুমের ধরন
• ডিভাইস তথ্য: ডিভাইসের ধরন, অপারেটিং সিস্টেম, অনন্য শনাক্তকারী
• ব্যবহারের তথ্য: ব্যবহৃত অ্যাপ ফিচার, ইন্টারঅ্যাকশন প্যাটার্ন, সেশনের সময়কাল
• অবস্থান তথ্য: কাছাকাছি স্বাস্থ্যসেবার জন্য আনুমানিক অবস্থান (আপনার অনুমতি সহ)''',
      ),
      _buildSection(
        title: '২. আমরা কিভাবে আপনার তথ্য ব্যবহার করি',
        content: '''আমরা আপনার তথ্য ব্যবহার করি:

• ব্যক্তিগত স্বাস্থ্য ট্র্যাকিং এবং সুপারিশ প্রদান করতে
• ওষুধের রিমাইন্ডার এবং স্বাস্থ্য বিজ্ঞপ্তি পাঠাতে
• AI চ্যাটবট স্বাস্থ্য সহায়তা সক্ষম করতে
• গর্ভাবস্থার বিকাশ এবং মহিলাদের স্বাস্থ্য চক্র ট্র্যাক করতে
• স্বাস্থ্য রিপোর্ট এবং বিশ্লেষণ তৈরি করতে
• অ্যাপের কার্যকারিতা এবং ব্যবহারকারীর অভিজ্ঞতা উন্নত করতে
• অ্যাপ নিরাপত্তা নিশ্চিত করতে এবং জালিয়াতি প্রতিরোধ করতে
• গুরুত্বপূর্ণ আপডেট এবং ফিচার যোগাযোগ করতে''',
      ),
      _buildSection(
        title: '৩. ডেটা সংরক্ষণ এবং সুরক্ষা',
        content: '''আপনার ডেটা সুরক্ষা আমাদের জন্য গুরুত্বপূর্ণ:

• সমস্ত ডেটা SSL/TLS ব্যবহার করে ট্রানজিটে এনক্রিপ্ট করা হয়
• Firebase Cloud Firestore এ এনক্রিপশন সহ নিরাপদে সংরক্ষিত
• নিয়মিত সুরক্ষা অডিট এবং দুর্বলতা মূল্যায়ন
• অ্যাক্সেস নিয়ন্ত্রণ এবং প্রমাণীকরণ পদ্ধতি
• ডেটা ক্ষতি প্রতিরোধের জন্য স্বয়ংক্রিয় ব্যাকআপ
• স্পষ্ট সম্মতি ছাড়া তৃতীয় পক্ষের সাথে কোন শেয়ারিং নেই''',
      ),
      _buildSection(
        title: '৪. তৃতীয় পক্ষের সেবা',
        content: '''আমরা নিম্নলিখিত সেবাগুলির সাথে একীভূত করি:

• Firebase (Google): প্রমাণীকরণ, ডাটাবেস, স্টোরেজ, মেসেজিং
• Google Sign-In: ঐচ্ছিক প্রমাণীকরণ পদ্ধতি
• পেমেন্ট গেটওয়ে: বিকাশ, নগদ (প্রিমিয়াম সাবস্ক্রিপশনের জন্য)
• Analytics: উন্নতির জন্য বেনামী ব্যবহার পরিসংখ্যান

প্রতিটি সেবার নিজস্ব গোপনীয়তা নীতি রয়েছে যা ডেটা পরিচালনা নিয়ন্ত্রণ করে।''',
      ),
      _buildSection(
        title: '৫. আপনার অধিকার এবং পছন্দ',
        content: '''আপনার অধিকার আছে:

• যেকোনো সময় আপনার ব্যক্তিগত ডেটা অ্যাক্সেস করার
• আপনার তথ্য আপডেট বা সংশোধন করার
• আপনার অ্যাকাউন্ট এবং সমস্ত সম্পর্কিত ডেটা মুছে ফেলার
• বিজ্ঞপ্তি এবং মার্কেটিং যোগাযোগ থেকে অপ্ট-আউট করার
• PDF/CSV ফর্ম্যাটে আপনার স্বাস্থ্য ডেটা রপ্তানি করার
• ডেটা প্রক্রিয়াকরণের জন্য সম্মতি প্রত্যাহার করার
• ডেটা বহনযোগ্যতার অনুরোধ করার''',
      ),
      _buildSection(
        title: '৬. ডেটা ধারণ',
        content: '''আমরা আপনার ডেটা নিম্নরূপ ধরে রাখি:

• সক্রিয় অ্যাকাউন্ট: অ্যাকাউন্ট সক্রিয় থাকাকালীন ডেটা ধরে রাখা হয়
• মুছে ফেলা অ্যাকাউন্ট: ৩০ দিনের মধ্যে ডেটা স্থায়ীভাবে মুছে ফেলা হয়
• ব্যাকআপ ডেটা: ৯০ দিনের মধ্যে ব্যাকআপ থেকে সরানো হয়
• আইনি প্রয়োজনীয়তা: আইন দ্বারা প্রয়োজন হলে ডেটা দীর্ঘ সময় ধরে রাখা হতে পারে''',
      ),
      _buildSection(
        title: '৭. শিশুদের গোপনীয়তা',
        content:
            '''HealthNest ১৩ বছর এবং তার বেশি বয়সী ব্যবহারকারীদের জন্য ডিজাইন করা হয়েছে। আমরা জেনেশুনে ১৩ বছরের কম বয়সী শিশুদের কাছ থেকে ব্যক্তিগত তথ্য সংগ্রহ করি না। নাবালকদের পারিবারিক প্রোফাইল অবশ্যই পিতামাতা বা আইনি অভিভাবকদের দ্বারা পরিচালিত হতে হবে।''',
      ),
      _buildSection(
        title: '৮. গোপনীয়তা নীতিতে পরিবর্তন',
        content:
            '''আমরা পর্যায়ক্রমে এই গোপনীয়তা নীতি আপডেট করতে পারি। আমরা আপনাকে উল্লেখযোগ্য পরিবর্তনের বিষয়ে জানাবো:

• ইন-অ্যাপ বিজ্ঞপ্তি
• ইমেইল বিজ্ঞপ্তি (প্রদান করা হলে)
• অ্যাপে বিশিষ্ট নোটিশ

পরিবর্তনের পরে অ্যাপের ক্রমাগত ব্যবহার আপডেট করা নীতির গ্রহণযোগ্যতা গঠন করে।''',
      ),
      _buildSection(
        title: '৯. আমাদের সাথে যোগাযোগ করুন',
        content: '''গোপনীয়তা উদ্বেগ বা প্রশ্নের জন্য:

ইমেইল: privacy@healthnest.com
ফোন: +৮৮০ ১২৩৪-৫৬৭৮৯০
ঠিকানা: ঢাকা, বাংলাদেশ

আমরা ৪৮ ঘন্টার মধ্যে সমস্ত অনুসন্ধানের উত্তর দেওয়ার লক্ষ্য রাখি।''',
      ),
      const SizedBox(height: 24),
      _buildAcceptanceBox(),
    ];
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isBengali
                  ? 'HealthNest ব্যবহার করে, আপনি এই গোপনীয়তা নীতির সাথে সম্মত হন।'
                  : 'By using HealthNest, you agree to this Privacy Policy.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
