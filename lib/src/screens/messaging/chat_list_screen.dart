import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
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

    // This is the fix that was implemented: the Scaffold widget.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: chatProvider.conversations.isEmpty
          ? const Center(
              child: Text(
                'No messages yet. Start a conversation!',
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: chatProvider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = chatProvider.conversations[index];
                final otherUserId = conversation.participants.firstWhere(
                  (id) => id != currentUserId,
                );

                return FutureBuilder<UserModel?>(
                  future: Provider.of<UserProvider>(context, listen: false)
                      .getUserById(otherUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('Loading user...'),
                        subtitle: Text('Loading...'),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return ListTile(
                        title: Text(otherUserId),
                        subtitle: Text(conversation.lastMessage),
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
                      );
                    }
                    final otherUser = snapshot.data;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: otherUser?.profileImageUrl != null
                            ? NetworkImage(otherUser!.profileImageUrl!)
                            : const AssetImage(
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                      ),
                      title: Text(otherUser?.name ?? 'Unknown User'),
                      subtitle: Text(conversation.lastMessage),
                      trailing: Text(
                        _formatTimestamp(conversation.lastMessageTimestamp),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
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
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
