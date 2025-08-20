import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/chat_provider.dart';
import '../../constants/app_strings.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      Provider.of<ChatProvider>(context, listen: false)
          .fetchConversations(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Center(child: Text('Please log in to view messages.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chatListTitle),
        centerTitle: true,
      ),
      body: chatProvider.conversations.isEmpty
          ? const Center(child: Text(AppStrings.noMessagesYet))
          : ListView.builder(
              itemCount: chatProvider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = chatProvider.conversations[index];
                final otherUserId = conversation.participants.firstWhere(
                  (id) => id != user.id,
                  orElse: () => user
                      .id, // Fallback for single-user chat (e.g., with admin)
                );

                // Fetch other user's profile to display name and image
                // For a real app, this should be done efficiently (e.g., by fetching user data once)
                final otherUser = chatProvider
                    .conversations[index]; // Placeholder for simplicity

                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150'), // Placeholder image
                    ),
                    title: Text(
                      'User ID: $otherUserId', // In a real app, replace with user name
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '${conversation.lastMessageTimestamp.hour}:${conversation.lastMessageTimestamp.minute}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/chat', arguments: {
                        'chatId': conversation.id,
                        'otherUserId': otherUserId,
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
