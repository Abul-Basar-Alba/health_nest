// lib/src/models/admin_message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMessageModel {
  final String senderId;
  final String receiverId;
  final String text;
  final Timestamp timestamp;

  AdminMessageModel({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  factory AdminMessageModel.fromMap(Map<String, dynamic> map) {
    return AdminMessageModel(
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      text: map['text'] as String,
      timestamp: map['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
