import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get a stream of all conversations for a specific user.
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc))
            .toList());
  }

  /// Get a stream of all messages in a specific chat.
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  /// Send a new message to a conversation.
  Future<void> sendMessage(
      String chatId, MessageModel message, String text) async {
    // Add the message to the sub-collection
    await _db
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // Update the parent conversation with the last message details
    await _db.collection('conversations').doc(chatId).update({
      'lastMessage': message.content,
      'lastMessageTimestamp': message.timestamp,
    });
  }

  /// Create a new conversation if it doesn't exist.
  Future<String> createOrGetChat(
      String currentUserId, String otherUserId) async {
    // A unique chat ID for two users, regardless of order
    final List<String> participants = [currentUserId, otherUserId]..sort();
    final String chatId = participants.join('_');

    final doc = await _db.collection('conversations').doc(chatId).get();

    if (!doc.exists) {
      // Create a new chat if it doesn't exist
      await _db.collection('conversations').doc(chatId).set({
        'participants': participants,
        'lastMessage': '',
        'lastMessageTimestamp': DateTime.now(),
      });
    }
    return chatId;
  }
}
