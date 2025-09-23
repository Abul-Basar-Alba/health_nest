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

    if (userProvider.user != null &&
        historyProvider.history.isNotEmpty &&
        recProvider.recommendationsAreEmpty) {
      recProvider.generateRecommendations(
        user: userProvider.user!,
        history: historyProvider.history,
      );
    } else {
      if (userProvider.user == null || historyProvider.history.isEmpty) {
        recProvider.setErrorMessage(
            'No user or historical data available to generate recommendations.');
      }
    }
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
      body: _buildBody(recProvider),
    );
  }

  Widget _buildBody(RecommendationProvider recProvider) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Existing recommendation section
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
                  else if (recProvider.recommendationsAreEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No recommendations generated. Please check your data or try again later.',
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    _buildRecommendationSection(recProvider),
                ],
              ),
            ),
          ),
        ),
        // --- New Chatbox Section ---
        if (recProvider.healthSummary != null) _buildChatbox(recProvider),
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chat with your AI Health Coach',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 200, // Fixed height for the chat history window
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: recProvider.chatHistory.length,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              itemBuilder: (context, index) {
                final message = recProvider.chatHistory[index];
                final isUser = message.role == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.lightBlue[100] : Colors.green[50],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                          color: isUser ? Colors.black87 : Colors.green[900]),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Ask a health question...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  onSubmitted: (value) => _sendChatMessage(),
                ),
              ),
              const SizedBox(width: 8),
              recProvider.isLoading
                  ? const CircularProgressIndicator()
                  : FloatingActionButton(
                      onPressed: _sendChatMessage,
                      backgroundColor: Colors.green[700],
                      mini: true,
                      child: const Icon(Icons.send, color: Colors.white),
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
