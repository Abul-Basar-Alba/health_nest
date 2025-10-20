// lib/src/screens/recommendation_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/user_provider.dart';
import '../providers/history_provider.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  RecommendationScreenState createState() => RecommendationScreenState();
}

class RecommendationScreenState extends State<RecommendationScreen> {
  // Add a text controller for the chat input field
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecommendations();
    });
  }

  void _fetchRecommendations() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final recProvider =
        Provider.of<RecommendationProvider>(context, listen: false);

    // Only generate recommendations if user has data and history
    if (userProvider.user != null &&
        historyProvider.history.isNotEmpty &&
        recProvider.recommendationsAreEmpty) {
      recProvider.generateRecommendations(
        user: userProvider.user!,
        history: historyProvider.history,
      );
    }
    // Don't show error message for missing data - just show clean chatbot interface
  }

  bool _hasUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);

    return userProvider.user != null && historyProvider.history.isNotEmpty;
  }

  // New method to handle sending chat messages
  void _sendChatMessage() {
    if (_chatController.text.isNotEmpty) {
      final recProvider =
          Provider.of<RecommendationProvider>(context, listen: false);
      recProvider.sendChatMessage(_chatController.text);
      _chatController.clear();
      // Scroll to the bottom of the chat list
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recProvider = Provider.of<RecommendationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Coach'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(recProvider),
      ),
      // Enable keyboard awareness
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildBody(RecommendationProvider recProvider) {
    bool hasData = _hasUserData();

    return Column(
      children: [
        // Only show recommendations section if user has data
        if (hasData) ...[
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (recProvider.errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          recProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (!recProvider.recommendationsAreEmpty)
                    _buildRecommendationSection(recProvider),
                ],
              ),
            ),
          ),
        ] else ...[
          // Clean welcome message for new users
          Expanded(
            flex: 1,
            child: _buildWelcomeSection(),
          ),
        ],
        // Always show chatbox - it's the main feature
        _buildChatbox(recProvider),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.psychology_rounded,
                    size: 48,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI Health Coach',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your personal AI health assistant is ready to help!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          Icons.chat_bubble_outline,
                          'Ask me anything about health',
                          Colors.green.shade600,
                        ),
                        const SizedBox(height: 6),
                        _buildFeatureItem(
                          Icons.auto_awesome,
                          'Get personalized recommendations',
                          Colors.blue.shade600,
                        ),
                        const SizedBox(height: 6),
                        _buildFeatureItem(
                          Icons.trending_up,
                          'Track your progress with insights',
                          Colors.orange.shade600,
                        ),
                      ],
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

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection(RecommendationProvider recProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalized Recommendations',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green[800],
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          context,
          title: 'Your Health Summary',
          content: recProvider.healthSummary!,
          icon: Icons.analytics_rounded,
          color: Colors.lightGreen,
        ),
        const SizedBox(height: 20),
        Text(
          'Actionable Tips',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green[800],
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          context,
          title: 'Nutrition Tips',
          content: recProvider.nutritionTips!,
          icon: Icons.restaurant_menu_rounded,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          context,
          title: 'Exercise & Activity',
          content: recProvider.exerciseTips!,
          icon: Icons.directions_run_rounded,
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildChatbox(RecommendationProvider recProvider) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            0.5, // Max 50% of screen height
      ),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chat with your AI Health Coach',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 120,
                maxHeight: 180,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: recProvider.chatHistory.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'You are an AI health coach. Answer questions in a helpful and friendly tone.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: recProvider.chatHistory.length,
                      padding: const EdgeInsets.all(8.0),
                      itemBuilder: (context, index) {
                        final message = recProvider.chatHistory[index];
                        final isUser = message.role == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.lightBlue[100]
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color:
                                    isUser ? Colors.black87 : Colors.green[900],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Compact input row
          Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: TextField(
                    controller: _chatController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendChatMessage(),
                    maxLines: null,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask a health question...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              recProvider.isLoading
                  ? const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _sendChatMessage,
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context,
      {required String title,
      required String content,
      required IconData icon,
      required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
