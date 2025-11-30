// health_nest/lib/src/screens/terms_of_service_screen.dart

import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  bool _isBengali = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isBengali ? 'সেবার শর্তাবলী' : 'Terms of Service'),
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
          colors: [Colors.blue.shade50, Colors.teal.shade50],
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
              Icon(Icons.gavel, color: Colors.blue.shade700, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isBengali ? 'সেবার শর্তাবলী' : 'Terms of Service',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isBengali
                ? 'কার্যকর তারিখ: ৩০ নভেম্বর, ২০২৫'
                : 'Effective Date: November 30, 2025',
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
        title: '1. Acceptance of Terms',
        content:
            '''By accessing or using HealthNest ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.

These terms constitute a legally binding agreement between you and HealthNest.''',
      ),
      _buildSection(
        title: '2. Description of Service',
        content: '''HealthNest provides:

• Personal health tracking and management tools
• Medicine reminder and drug interaction checking
• Pregnancy and women's health tracking
• Family health profile management
• AI-powered health chatbot assistance
• Health diary and analytics
• Premium community features
• Educational health content

The App is designed to assist with health management but is NOT a substitute for professional medical advice, diagnosis, or treatment.''',
      ),
      _buildSection(
        title: '3. User Eligibility',
        content: '''To use HealthNest, you must:

• Be at least 13 years of age
• Provide accurate and complete registration information
• Maintain the security of your account credentials
• Accept full responsibility for all activities under your account
• Not use the App for any illegal or unauthorized purpose

Parents or guardians must supervise accounts for users under 18.''',
      ),
      _buildSection(
        title: '4. Medical Disclaimer',
        content:
            '''IMPORTANT: HealthNest is a health management tool, not medical advice.

• Always consult qualified healthcare professionals for medical concerns
• Do not delay or disregard professional medical advice based on App information
• The AI chatbot provides general information only, not medical diagnosis
• Drug interaction checker is for reference; consult your pharmacist/doctor
• Emergency situations require immediate medical attention (call emergency services)

HealthNest and its creators are not liable for health outcomes resulting from App use.''',
      ),
      _buildSection(
        title: '5. User Responsibilities',
        content: '''You agree to:

• Provide accurate health information for best results
• Keep your account credentials confidential
• Not share your account with others
• Use the App in compliance with all applicable laws
• Not attempt to hack, reverse engineer, or compromise the App
• Not upload harmful content (viruses, malware, etc.)
• Respect other users in community features
• Report bugs or security issues promptly''',
      ),
      _buildSection(
        title: '6. Premium Services and Payments',
        content: '''Premium features include:

• Unlimited BMI calculations
• Unlimited AI chatbot messages
• Advanced analytics and reports
• Ad-free experience
• Priority support

Payment Terms:
• Monthly: ৳999/month (billed monthly)
• Yearly: ৳9,999/year (billed annually, save 17%)
• 7-day free trial for new users
• Auto-renewal unless canceled 24 hours before period end
• No refunds for partial subscription periods
• Accepted methods: Bkash, Nagad, Rocket

Cancel anytime through App settings.''',
      ),
      _buildSection(
        title: '7. Intellectual Property',
        content:
            '''All content in HealthNest is protected by copyright and intellectual property laws:

• App design, code, and features are owned by HealthNest
• Health content, articles, and educational materials are proprietary
• User-generated content (health data, diary entries) remains yours
• You grant us license to use your data to provide services
• Do not copy, modify, or distribute App content without permission''',
      ),
      _buildSection(
        title: '8. Privacy and Data Protection',
        content:
            '''Your privacy is governed by our Privacy Policy, which includes:

• How we collect, use, and protect your health data
• Third-party service integrations (Firebase, payment gateways)
• Your rights to access, modify, or delete your data
• Data encryption and security measures

Read our full Privacy Policy for complete details.''',
      ),
      _buildSection(
        title: '9. Account Termination',
        content: '''We may suspend or terminate your account if:

• You violate these Terms of Service
• You engage in fraudulent activity
• You abuse or harass other users
• You attempt to compromise App security
• Required by law enforcement

You may delete your account anytime through App settings. All data will be permanently deleted within 30 days.''',
      ),
      _buildSection(
        title: '10. Limitation of Liability',
        content: '''TO THE MAXIMUM EXTENT PERMITTED BY LAW:

• HealthNest is provided "AS IS" without warranties
• We are not liable for health outcomes, medical errors, or missed doses
• Not responsible for third-party service failures (Firebase, payment gateways)
• Not liable for data loss due to device failure or user error
• Maximum liability limited to subscription fees paid in last 12 months

Use the App at your own risk.''',
      ),
      _buildSection(
        title: '11. Changes to Terms',
        content:
            '''We may modify these Terms of Service at any time. Changes will be effective upon:

• Posting updated terms in the App
• Email notification (for significant changes)
• 30-day notice period for major changes

Continued use after changes constitutes acceptance. If you disagree, discontinue use and delete your account.''',
      ),
      _buildSection(
        title: '12. Governing Law',
        content:
            '''These Terms are governed by the laws of Bangladesh. Any disputes will be resolved through:

• Good-faith negotiation first
• Arbitration in Dhaka, Bangladesh (if negotiation fails)
• Bangladesh courts (if arbitration unavailable)''',
      ),
      _buildSection(
        title: '13. Contact Information',
        content: '''For questions about these Terms:

Email: legal@healthnest.com
Support: support@healthnest.com
Phone: +880 1234-567890
Address: Dhaka, Bangladesh

We respond to inquiries within 48-72 hours.''',
      ),
      const SizedBox(height: 24),
      _buildAgreementBox(),
    ];
  }

  List<Widget> _buildBengaliContent() {
    return [
      _buildSection(
        title: '১. শর্তাবলীর গ্রহণযোগ্যতা',
        content:
            '''HealthNest ("অ্যাপ") অ্যাক্সেস বা ব্যবহার করে, আপনি এই সেবার শর্তাবলী দ্বারা আবদ্ধ হতে সম্মত হন। যদি আপনি এই শর্তাবলীর সাথে একমত না হন, অনুগ্রহ করে অ্যাপ ব্যবহার করবেন না।

এই শর্তাবলী আপনার এবং HealthNest এর মধ্যে একটি আইনত বাধ্যতামূলক চুক্তি গঠন করে।''',
      ),
      _buildSection(
        title: '২. সেবার বর্ণনা',
        content: '''HealthNest প্রদান করে:

• ব্যক্তিগত স্বাস্থ্য ট্র্যাকিং এবং পরিচালনা সরঞ্জাম
• ওষুধের রিমাইন্ডার এবং ড্রাগ ইন্টারঅ্যাকশন পরীক্ষা
• গর্ভাবস্থা এবং মহিলাদের স্বাস্থ্য ট্র্যাকিং
• পারিবারিক স্বাস্থ্য প্রোফাইল পরিচালনা
• AI-চালিত স্বাস্থ্য চ্যাটবট সহায়তা
• স্বাস্থ্য ডায়রি এবং বিশ্লেষণ
• প্রিমিয়াম কমিউনিটি ফিচার
• শিক্ষামূলক স্বাস্থ্য কন্টেন্ট

অ্যাপটি স্বাস্থ্য ব্যবস্থাপনায় সহায়তা করার জন্য ডিজাইন করা হয়েছে কিন্তু পেশাদার চিকিৎসা পরামর্শ, নির্ণয় বা চিকিৎসার বিকল্প নয়।''',
      ),
      _buildSection(
        title: '৩. ব্যবহারকারী যোগ্যতা',
        content: '''HealthNest ব্যবহার করতে, আপনাকে অবশ্যই:

• অন্তত ১৩ বছর বয়সী হতে হবে
• সঠিক এবং সম্পূর্ণ নিবন্ধন তথ্য প্রদান করতে হবে
• আপনার অ্যাকাউন্ট শংসাপত্রের সুরক্ষা বজায় রাখতে হবে
• আপনার অ্যাকাউন্টের অধীনে সমস্ত কার্যকলাপের জন্য সম্পূর্ণ দায়িত্ব গ্রহণ করতে হবে
• কোনো অবৈধ বা অননুমোদিত উদ্দেশ্যে অ্যাপ ব্যবহার করবেন না

১৮ বছরের কম বয়সী ব্যবহারকারীদের অ্যাকাউন্ট পিতামাতা বা অভিভাবকদের তত্ত্বাবধান করতে হবে।''',
      ),
      _buildSection(
        title: '৪. চিকিৎসা দাবি পরিত্যাগ',
        content:
            '''গুরুত্বপূর্ণ: HealthNest একটি স্বাস্থ্য ব্যবস্থাপনা সরঞ্জাম, চিকিৎসা পরামর্শ নয়।

• চিকিৎসা উদ্বেগের জন্য সর্বদা যোগ্য স্বাস্থ্যসেবা পেশাদারদের সাথে পরামর্শ করুন
• অ্যাপ তথ্যের উপর ভিত্তি করে পেশাদার চিকিৎসা পরামর্শ বিলম্ব বা উপেক্ষা করবেন না
• AI চ্যাটবট শুধুমাত্র সাধারণ তথ্য প্রদান করে, চিকিৎসা নির্ণয় নয়
• ড্রাগ ইন্টারঅ্যাকশন চেকার রেফারেন্সের জন্য; আপনার ফার্মাসিস্ট/ডাক্তারের সাথে পরামর্শ করুন
• জরুরি পরিস্থিতিতে অবিলম্বে চিকিৎসা মনোযোগ প্রয়োজন (জরুরি সেবা কল করুন)

HealthNest এবং এর স্রষ্টারা অ্যাপ ব্যবহারের ফলে স্বাস্থ্যের ফলাফলের জন্য দায়বদ্ধ নয়।''',
      ),
      _buildSection(
        title: '৫. ব্যবহারকারীর দায়িত্ব',
        content: '''আপনি সম্মত হন:

• সর্বোত্তম ফলাফলের জন্য সঠিক স্বাস্থ্য তথ্য প্রদান করতে
• আপনার অ্যাকাউন্ট শংসাপত্র গোপনীয় রাখতে
• অন্যদের সাথে আপনার অ্যাকাউন্ট শেয়ার না করতে
• সমস্ত প্রযোজ্য আইন মেনে অ্যাপ ব্যবহার করতে
• অ্যাপ হ্যাক, রিভার্স ইঞ্জিনিয়ার বা আপস করার চেষ্টা না করতে
• ক্ষতিকারক কন্টেন্ট আপলোড না করতে (ভাইরাস, ম্যালওয়্যার ইত্যাদি)
• কমিউনিটি ফিচারে অন্য ব্যবহারকারীদের সম্মান করতে
• বাগ বা সুরক্ষা সমস্যা অবিলম্বে রিপোর্ট করতে''',
      ),
      _buildSection(
        title: '৬. প্রিমিয়াম সেবা এবং পেমেন্ট',
        content: '''প্রিমিয়াম ফিচার অন্তর্ভুক্ত:

• সীমাহীন BMI হিসাব
• সীমাহীন AI চ্যাটবট বার্তা
• উন্নত বিশ্লেষণ এবং রিপোর্ট
• বিজ্ঞাপন-মুক্ত অভিজ্ঞতা
• অগ্রাধিকার সহায়তা

পেমেন্ট শর্তাবলী:
• মাসিক: ৳৯৯৯/মাস (মাসিক বিল)
• বার্ষিক: ৳৯,৯৯৯/বছর (বার্ষিক বিল, ১৭% সঞ্চয়)
• নতুন ব্যবহারকারীদের জন্য ৭ দিনের বিনামূল্যে ট্রায়াল
• সময়কাল শেষ হওয়ার ২৪ ঘন্টা আগে বাতিল না করলে স্বয়ংক্রিয় নবায়ন
• আংশিক সাবস্ক্রিপশন সময়ের জন্য কোন রিফান্ড নেই
• গৃহীত পদ্ধতি: বিকাশ, নগদ, রকেট

অ্যাপ সেটিংসের মাধ্যমে যেকোনো সময় বাতিল করুন।''',
      ),
      _buildSection(
        title: '৭. বৌদ্ধিক সম্পত্তি',
        content:
            '''HealthNest এর সমস্ত কন্টেন্ট কপিরাইট এবং বৌদ্ধিক সম্পত্তি আইন দ্বারা সুরক্ষিত:

• অ্যাপ ডিজাইন, কোড এবং ফিচার HealthNest এর মালিকানাধীন
• স্বাস্থ্য কন্টেন্ট, নিবন্ধ এবং শিক্ষামূলক উপকরণ মালিকানা
• ব্যবহারকারী-উত্পন্ন কন্টেন্ট (স্বাস্থ্য ডেটা, ডায়রি এন্ট্রি) আপনার থাকে
• আপনি আমাদের সেবা প্রদান করতে আপনার ডেটা ব্যবহার করার লাইসেন্স প্রদান করেন
• অনুমতি ছাড়া অ্যাপ কন্টেন্ট কপি, পরিবর্তন বা বিতরণ করবেন না''',
      ),
      _buildSection(
        title: '৮. গোপনীয়তা এবং ডেটা সুরক্ষা',
        content:
            '''আপনার গোপনীয়তা আমাদের গোপনীয়তা নীতি দ্বারা নিয়ন্ত্রিত হয়, যা অন্তর্ভুক্ত করে:

• আমরা কীভাবে আপনার স্বাস্থ্য ডেটা সংগ্রহ, ব্যবহার এবং সুরক্ষা করি
• তৃতীয় পক্ষের সেবা একীকরণ (Firebase, পেমেন্ট গেটওয়ে)
• আপনার ডেটা অ্যাক্সেস, পরিবর্তন বা মুছে ফেলার অধিকার
• ডেটা এনক্রিপশন এবং সুরক্ষা ব্যবস্থা

সম্পূর্ণ বিবরণের জন্য আমাদের সম্পূর্ণ গোপনীয়তা নীতি পড়ুন।''',
      ),
      _buildSection(
        title: '৯. অ্যাকাউন্ট সমাপ্তি',
        content: '''আমরা আপনার অ্যাকাউন্ট স্থগিত বা সমাপ্ত করতে পারি যদি:

• আপনি এই সেবার শর্তাবলী লঙ্ঘন করেন
• আপনি প্রতারণামূলক কার্যকলাপে জড়িত হন
• আপনি অন্য ব্যবহারকারীদের অপব্যবহার বা হয়রানি করেন
• আপনি অ্যাপ সুরক্ষা আপস করার চেষ্টা করেন
• আইন প্রয়োগকারী দ্বারা প্রয়োজন

আপনি অ্যাপ সেটিংসের মাধ্যমে যেকোনো সময় আপনার অ্যাকাউন্ট মুছে ফেলতে পারেন। সমস্ত ডেটা ৩০ দিনের মধ্যে স্থায়ীভাবে মুছে ফেলা হবে।''',
      ),
      _buildSection(
        title: '১০. দায়বদ্ধতার সীমাবদ্ধতা',
        content: '''আইন দ্বারা অনুমোদিত সর্বোচ্চ পরিমাণে:

• HealthNest ওয়ারেন্টি ছাড়াই "যেমন আছে" প্রদান করা হয়
• আমরা স্বাস্থ্যের ফলাফল, চিকিৎসা ত্রুটি বা মিস ডোজের জন্য দায়বদ্ধ নই
• তৃতীয় পক্ষের সেবা ব্যর্থতার জন্য দায়ী নই (Firebase, পেমেন্ট গেটওয়ে)
• ডিভাইস ব্যর্থতা বা ব্যবহারকারী ত্রুটির কারণে ডেটা ক্ষতির জন্য দায়বদ্ধ নই
• সর্্বোচ্চ দায়বদ্ধতা গত ১২ মাসে প্রদত্ত সাবস্ক্রিপশন ফিতে সীমাবদ্ধ

আপনার নিজের ঝুঁকিতে অ্যাপ ব্যবহার করুন।''',
      ),
      _buildSection(
        title: '১১. শর্তাবলীর পরিবর্তন',
        content:
            '''আমরা যেকোনো সময় এই সেবার শর্তাবলী সংশোধন করতে পারি। পরিবর্তন কার্যকর হবে:

• অ্যাপে আপডেট করা শর্তাবলী পোস্ট করার পরে
• ইমেইল বিজ্ঞপ্তি (উল্লেখযোগ্য পরিবর্তনের জন্য)
• বড় পরিবর্তনের জন্য ৩০ দিনের নোটিশ সময়কাল

পরিবর্তনের পরে ক্রমাগত ব্যবহার গ্রহণযোগ্যতা গঠন করে। যদি আপনি অসম্মত হন, ব্যবহার বন্ধ করুন এবং আপনার অ্যাকাউন্ট মুছে ফেলুন।''',
      ),
      _buildSection(
        title: '১২. শাসক আইন',
        content:
            '''এই শর্তাবলী বাংলাদেশের আইন দ্বারা নিয়ন্ত্রিত হয়। যে কোনো বিরোধ সমাধান করা হবে:

• প্রথমে সদ্ভাব আলোচনার মাধ্যমে
• ঢাকা, বাংলাদেশে সালিশি (আলোচনা ব্যর্থ হলে)
• বাংলাদেশ আদালত (সালিশি অনুপলব্ধ হলে)''',
      ),
      _buildSection(
        title: '১৩. যোগাযোগের তথ্য',
        content: '''এই শর্তাবলী সম্পর্কে প্রশ্নের জন্য:

ইমেইল: legal@healthnest.com
সহায়তা: support@healthnest.com
ফোন: +৮৮০ ১২৩৪-৫৬৭৮৯০
ঠিকানা: ঢাকা, বাংলাদেশ

আমরা ৪৮-৭২ ঘন্টার মধ্যে অনুসন্ধানের উত্তর দিই।''',
      ),
      const SizedBox(height: 24),
      _buildAgreementBox(),
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
              color: Colors.blue.shade700,
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

  Widget _buildAgreementBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isBengali
                  ? 'অ্যাপ ব্যবহার করে, আপনি এই সেবার শর্তাবলীতে সম্মত হন।'
                  : 'By using the App, you agree to these Terms of Service.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
