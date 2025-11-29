// HealthNest AI Chatbot - Web Frontend Style
// Exact replica of AI-Project/frontend design for mobile

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_chatbot_provider.dart';
import '../providers/user_provider.dart';

class AIChatbotWebStyleScreen extends StatefulWidget {
  const AIChatbotWebStyleScreen({super.key});

  @override
  State<AIChatbotWebStyleScreen> createState() =>
      _AIChatbotWebStyleScreenState();
}

class _AIChatbotWebStyleScreenState extends State<AIChatbotWebStyleScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Profile form controllers
  final TextEditingController _ageController =
      TextEditingController(text: '25');
  final TextEditingController _weightController =
      TextEditingController(text: '70');
  final TextEditingController _heightController =
      TextEditingController(text: '170');
  String _selectedGender = 'male';
  String _selectedActivity = 'moderate';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final chatProvider =
          Provider.of<AIChatbotProvider>(context, listen: false);

      final currentUser = userProvider.user;
      if (currentUser != null) {
        _ageController.text = (currentUser.age ?? 25).toString();
        _weightController.text = (currentUser.weight ?? 70.0).toString();
        _heightController.text = (currentUser.height ?? 170.0).toString();
        _selectedGender = currentUser.gender == 'পুরুষ' ? 'male' : 'female';

        chatProvider.initializeWithProfile(currentUser);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    final chatProvider = Provider.of<AIChatbotProvider>(context, listen: false);
    await chatProvider.sendMessage(message);
    _scrollToBottom();
  }

  void _askQuestion(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  void _updateProfile() {
    final chatProvider = Provider.of<AIChatbotProvider>(context, listen: false);

    // Update profile using the updateProfile method
    chatProvider.updateProfile({
      'age': int.tryParse(_ageController.text) ?? 25,
      'gender': _selectedGender,
      'weight': double.tryParse(_weightController.text) ?? 70.0,
      'height': double.tryParse(_heightController.text) ?? 170.0,
      'activity': _selectedActivity,
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Profile updated successfully!'),
        backgroundColor: Color(0xFF667eea),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f4f6),
      appBar: _buildHeader(),
      drawer: _buildSidebar(),
      body: Column(
        children: [
          _buildChatHeader(),
          Expanded(child: _buildMessagesList()),
          _buildQuickQuestions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  // Header - Logo + Title
  PreferredSizeWidget _buildHeader() {
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF667eea)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🏥', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HealthNest AI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                'Your Personal Health Assistant',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6b7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sidebar - User Profile
  Widget _buildSidebar() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Your Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Personalize your health insights',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Profile Form
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildInputField('Age', _ageController, TextInputType.number),
                  const SizedBox(height: 16),
                  _buildDropdown(
                      'Gender',
                      _selectedGender,
                      [
                        const DropdownMenuItem(
                            value: 'male', child: Text('Male')),
                        const DropdownMenuItem(
                            value: 'female', child: Text('Female')),
                        const DropdownMenuItem(
                            value: 'other', child: Text('Other')),
                      ],
                      (val) => setState(() => _selectedGender = val!)),
                  const SizedBox(height: 16),
                  _buildInputField(
                      'Weight (kg)', _weightController, TextInputType.number),
                  const SizedBox(height: 16),
                  _buildInputField(
                      'Height (cm)', _heightController, TextInputType.number),
                  const SizedBox(height: 16),
                  _buildDropdown(
                      'Activity Level',
                      _selectedActivity,
                      [
                        const DropdownMenuItem(
                            value: 'sedentary', child: Text('Sedentary')),
                        const DropdownMenuItem(
                            value: 'light', child: Text('Light')),
                        const DropdownMenuItem(
                            value: 'moderate', child: Text('Moderate')),
                        const DropdownMenuItem(
                            value: 'active', child: Text('Active')),
                        const DropdownMenuItem(
                            value: 'very_active', child: Text('Very Active')),
                      ],
                      (val) => setState(() => _selectedActivity = val!)),
                  const SizedBox(height: 24),
                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: const Color(0xFF667eea),
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildInputField(
      String label, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6b7280),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFf9fafb),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFe5e7eb), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFe5e7eb), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563eb), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value,
      List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6b7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFf9fafb),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFe5e7eb), width: 2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Chat Header with Status
  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFe5e7eb), width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '💬 Chat with HealthNest AI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          Consumer<AIChatbotProvider>(
            builder: (context, chatProvider, _) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: chatProvider.isLoading
                      ? const Color(0xFFfef3c7)
                      : const Color(0xFFd1fae5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: chatProvider.isLoading
                            ? const Color(0xFFf59e0b)
                            : const Color(0xFF10b981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      chatProvider.isLoading ? 'Typing...' : 'Ready',
                      style: TextStyle(
                        color: chatProvider.isLoading
                            ? const Color(0xFF92400e)
                            : const Color(0xFF065f46),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Messages List
  Widget _buildMessagesList() {
    return Consumer<AIChatbotProvider>(
      builder: (context, chatProvider, _) {
        if (chatProvider.messages.isEmpty) {
          return _buildWelcomeMessage();
        }

        return Container(
          color: const Color(0xFFf3f4f6),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: chatProvider.messages.length,
            itemBuilder: (context, index) {
              final message = chatProvider.messages[index];
              return _buildMessage(message);
            },
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      color: const Color(0xFFf3f4f6),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🤖', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Hello! I\'m your HealthNest AI assistant.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'I can help you with:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                _buildFeatureItem('🥗 Nutrition & Diet advice'),
                _buildFeatureItem('💪 Exercise & Fitness recommendations'),
                _buildFeatureItem('📊 BMI & Health calculations'),
                _buildFeatureItem('🤰 Pregnancy guidance'),
                _buildFeatureItem('👩 Women\'s health support'),
                _buildFeatureItem('❓ General health questions'),
                const SizedBox(height: 12),
                const Text(
                  'Ask me anything about your health! 😊',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6b7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Bot Avatar
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          // Message Content
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? null : Colors.white,
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            // User Avatar
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Quick Questions
  Widget _buildQuickQuestions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFf9fafb),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const Text(
              'Quick questions:',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6b7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            _buildQuickButton('🌟 Improve health', 'How to improve health?'),
            const SizedBox(width: 8),
            _buildQuickButton('📊 Healthy BMI', 'What is healthy BMI?'),
            const SizedBox(width: 8),
            _buildQuickButton(
                '🏃 Weight loss', 'Best exercises for weight loss?'),
            const SizedBox(width: 8),
            _buildQuickButton('💧 Water intake', 'How much water daily?'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, String question) {
    return OutlinedButton(
      onPressed: () => _askQuestion(question),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFe5e7eb), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  // Input Area
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFe5e7eb), width: 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me about health, nutrition, fitness...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9ca3af),
                ),
                filled: true,
                fillColor: const Color(0xFFf9fafb),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide:
                      const BorderSide(color: Color(0xFFe5e7eb), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide:
                      const BorderSide(color: Color(0xFFe5e7eb), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563eb), width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: const Row(
                    children: [
                      Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('📤', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollToBottom();
  }
}
