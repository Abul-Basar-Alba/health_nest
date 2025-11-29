import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = userProvider.user;

    if (currentUser != null) {
      await chatProvider.sendMessage(
        currentUser.id,
        widget.otherUserId,
        messageText,
      );
      _messageController.clear();
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showMessageOptions(
      BuildContext context, String messageId, String currentContent) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF6A11CB)),
                title: const Text('Edit Message'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, messageId, currentContent);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Message'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(context, messageId);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _deleteMessage(BuildContext context, String messageId) async {
    // Get provider reference before async operation
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await chatProvider.deleteMessage(widget.chatId, messageId);
    }
  }

  void _showEditDialog(
      BuildContext context, String messageId, String currentContent) {
    // Get provider reference before showing dialog
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final TextEditingController editController =
        TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          maxLines: null,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new message',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newContent = editController.text.trim();
              Navigator.pop(dialogContext);

              if (newContent.isNotEmpty && newContent != currentContent) {
                await chatProvider.editMessage(
                    widget.chatId, messageId, newContent);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      // Dispose controller after dialog is closed
      editController.dispose();
    });
  }

  void _showClearChatDialog(BuildContext context) async {
    // Get provider reference before async operation
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Messages'),
        content: const Text(
          'Are you sure you want to clear all messages in this chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await chatProvider.clearAllMessages(widget.chatId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: FutureBuilder<UserModel?>(
          future: userProvider.getUserById(widget.otherUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Loading...',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Text(
                'Chat',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }
            return Text(
              snapshot.data!.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearChatDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All Messages'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading messages',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                          'Send a message to start chatting',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return MessageModel.fromFirestore(doc);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageDoc = snapshot.data!.docs[index];
                    final isSentByMe =
                        message.senderId == userProvider.user?.id;
                    return Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: isSentByMe
                            ? () => _showMessageOptions(
                                  context,
                                  messageDoc.id,
                                  message.content,
                                )
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSentByMe
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF6A11CB),
                                      Color(0xFF2575FC)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSentByMe ? null : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isSentByMe ? 20 : 4),
                              bottomRight: Radius.circular(isSentByMe ? 4 : 20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSentByMe
                                    ? const Color(0xFF6A11CB).withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isSentByMe
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A),
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                              if (message.edited == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Edited',
                                    style: TextStyle(
                                      color: isSentByMe
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.grey[600],
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
