import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ConversationModel> _conversations = [];
  List<MessageModel> _currentMessages = [];
  String? _currentChatId;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get currentMessages => _currentMessages;

  // Use a Stream to listen for real-time changes in conversations
  void fetchConversations(String userId) {
    _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _conversations = snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  // Use a Stream to listen for real-time changes in messages
  void fetchMessages(String chatId) {
    _currentChatId = chatId;
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _currentMessages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList()
          .reversed
          .toList(); // Reverse to show latest messages at the bottom
      notifyListeners();
    });
  }

  // Method to send a new message
  Future<void> sendMessage(
      String senderId, String receiverId, String content) async {
    final chatId = getChatId(senderId, receiverId);
    final chatDocRef = _firestore.collection('chats').doc(chatId);
    final now = DateTime.now();

    final messageData = {
      'senderId': senderId,
      'content': content,
      'timestamp': now,
    };

    // Add message to the messages sub-collection
    await chatDocRef.collection('messages').add(messageData);

    // Update or create the main chat document
    await chatDocRef.set({
      'participants': [senderId, receiverId],
      'lastMessage': content,
      'lastMessageTimestamp': now,
    }, SetOptions(merge: true));
  }

  // This method ensures a consistent chatId regardless of who starts the chat
  String getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // The logic to clear chat data from memory (but not from Firestore)
  void clearChatState() {
    _conversations = [];
    _currentMessages = [];
    _currentChatId = null;
    notifyListeners();
  }

  // Delete a specific message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
      
      // Update last message if deleted message was the last one
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      
      if (messagesSnapshot.docs.isNotEmpty) {
        final lastMsg = messagesSnapshot.docs.first;
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': lastMsg['content'],
          'lastMessageTimestamp': lastMsg['timestamp'],
        });
      } else {
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': '',
          'lastMessageTimestamp': DateTime.now(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting message: $e');
      }
    }
  }

  // Edit a specific message
  Future<void> editMessage(String chatId, String messageId, String newContent) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': newContent,
        'edited': true,
        'editedAt': DateTime.now(),
      });

      // Update last message if edited message was the last one
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      
      if (messagesSnapshot.docs.isNotEmpty && messagesSnapshot.docs.first.id == messageId) {
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': newContent,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error editing message: $e');
      }
    }
  }

  // Clear all messages in a chat
  Future<void> clearAllMessages(String chatId) async {
    try {
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      
      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': '',
        'lastMessageTimestamp': DateTime.now(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing messages: $e');
      }
    }
  }

  // Delete entire chat conversation
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages first
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      
      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the chat document
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting chat: $e');
      }
    }
  }
}
