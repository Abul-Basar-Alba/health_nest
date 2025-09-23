// lib/src/models/history_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final String id;
  final Timestamp timestamp;
  final String type; // 'calculation', 'step', 'nutrition'
  final Map<String, dynamic> data;

  HistoryModel({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.data,
  });

  /// Firestore থেকে ডেটা রূপান্তর
  factory HistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return HistoryModel(
      id: id,
      timestamp: map['timestamp'] as Timestamp,
      type: map['type'] as String,
      data: map['data'] as Map<String, dynamic>,
    );
  }

  /// Firestore এ ডেটা সেভ করার জন্য
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'type': type,
      'data': data,
    };
  }
}
