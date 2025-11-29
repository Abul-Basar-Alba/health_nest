import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userId = userProvider.user?.id;
    if (userId != null) {
      chatProvider.fetchConversations(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUserId = Provider.of<UserProvider>(context).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
      ),
      body: chatProvider.conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation from\nCommunity Members!',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: chatProvider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = chatProvider.conversations[index];
                final otherUserId = conversation.participants.firstWhere(
                  (id) => id != currentUserId,
                  orElse: () => '',
                );

                if (otherUserId.isEmpty) return const SizedBox();

                return FutureBuilder<UserModel?>(
                  future: Provider.of<UserProvider>(context, listen: false)
                      .getUserById(otherUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return const SizedBox();
                    }

                    final otherUser = snapshot.data!;
                    final now = DateTime.now();
                    final difference =
                        now.difference(conversation.lastMessageTimestamp);
                    final hasUnread =
                        false; // You can implement unread logic later

                    return Dismissible(
                      key: Key(conversation.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Chat'),
                              content: Text(
                                'Are you sure you want to delete this conversation with ${otherUser.name}?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        chatProvider.deleteChat(conversation.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Chat with ${otherUser.name} deleted'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          gradient: hasUnread
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFE3F2FD),
                                    Color(0xFFFFFFFF)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: hasUnread ? null : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: otherUser.profileImageUrl != null
                                ? NetworkImage(otherUser.profileImageUrl!)
                                : null,
                            backgroundColor: const Color(0xFF6A11CB),
                            child: otherUser.profileImageUrl == null
                                ? Text(
                                    otherUser.name.isNotEmpty
                                        ? otherUser.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            otherUser.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              conversation.lastMessage.isEmpty
                                  ? 'No messages yet'
                                  : conversation.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          trailing: Text(
                            _formatTimestamp(difference),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatId: conversation.id,
                                  otherUserId: otherUserId,
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                            _showChatOptions(
                                context, conversation.id, otherUser.name);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showChatOptions(BuildContext context, String chatId, String userName) {
    // Get provider reference before showing bottom sheet
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.delete_sweep, color: Color(0xFF6A11CB)),
                title: const Text('Clear All Messages'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Clear Messages'),
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
                    await chatProvider.clearAllMessages(chatId);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Chat'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete Chat'),
                      content: Text(
                        'Are you sure you want to delete this conversation with $userName?',
                      ),
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
                    await chatProvider.deleteChat(chatId);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(Duration difference) {
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
