import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ConversationModel> _conversations = [];
  List<MessageModel> _currentMessages = [];
  String? _currentChatId;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get currentMessages => _currentMessages;

  Future<void> fetchConversations(String userId) async {
    _chatService.getConversations(userId).listen((conversations) {
      _conversations = conversations;
      notifyListeners();
    });
  }

  Future<void> fetchMessages(String chatId) async {
    _currentChatId = chatId;
    _chatService.getMessages(chatId).listen((messages) {
      _currentMessages = messages;
      notifyListeners();
    });
  }

  Future<void> sendMessage(
      String senderId, String receiverId, String content) async {
    final chatId = await _chatService.createOrGetChat(senderId, receiverId);
    final message = MessageModel(
      id: '', // Will be assigned by Firestore
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );
    await _chatService.sendMessage(chatId, message);
  }

  void clearChatState() {
    _conversations = [];
    _currentMessages = [];
    _currentChatId = null;
    notifyListeners();
  }
}
