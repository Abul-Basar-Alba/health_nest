// lib/src/screens/admin_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/admin_message_model.dart';
import '../providers/user_provider.dart';
import '../services/admin_message_service.dart';

class AdminChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const AdminChatScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AdminMessageService _chatService = AdminMessageService();

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(
        Provider.of<UserProvider>(context, listen: false).user!.id,
        widget.recipientId,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<UserProvider>(context).user!.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.recipientName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Add more options if needed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Chat messages section ---
          Expanded(
            child: StreamBuilder<List<AdminMessageModel>>(
              stream:
                  _chatService.getMessages(currentUserId, widget.recipientId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading messages',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send a message to ${widget.recipientName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          gradient: isMe
                              ? const LinearGradient(
                                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isMe ? null : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isMe ? 20 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isMe
                                  ? const Color(0xFF6A11CB).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : const Color(0xFF1A1A1A),
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- Message input box with premium style button ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Message Input Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) => _sendMessage(),
                        maxLines: null,
                        style: const TextStyle(fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Premium Send Button with Gradient
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A11CB).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _sendMessage,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
