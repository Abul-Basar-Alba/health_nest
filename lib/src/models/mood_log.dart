import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for mood and energy tracking
/// Tracks emotional state and energy levels
class MoodLog {
  final String id;
  final String userId;
  final String
      mood; // 'happy', 'sad', 'anxious', 'calm', 'stressed', 'tired', etc.
  final int energyLevel; // 1-5 scale (1=very low, 5=very high)
  final DateTime timestamp;
  final String? notes;
  final DateTime createdAt;

  MoodLog({
    required this.id,
    required this.userId,
    required this.mood,
    required this.energyLevel,
    required this.timestamp,
    this.notes,
    required this.createdAt,
  });

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mood': mood,
      'energyLevel': energyLevel,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore document
  factory MoodLog.fromMap(String id, Map<String, dynamic> map) {
    return MoodLog(
      id: id,
      userId: map['userId'] as String,
      mood: map['mood'] as String,
      energyLevel: map['energyLevel'] as int,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Create a copy with optional field updates
  MoodLog copyWith({
    String? id,
    String? userId,
    String? mood,
    int? energyLevel,
    DateTime? timestamp,
    String? notes,
    DateTime? createdAt,
  }) {
    return MoodLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get mood emoji
  String get moodEmoji {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'excited':
        return '😊';
      case 'sad':
      case 'unhappy':
      case 'down':
        return '😢';
      case 'anxious':
      case 'worried':
      case 'nervous':
        return '😰';
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return '😌';
      case 'stressed':
      case 'overwhelmed':
        return '😫';
      case 'tired':
      case 'exhausted':
      case 'sleepy':
        return '😴';
      case 'angry':
      case 'frustrated':
      case 'irritated':
        return '😠';
      case 'neutral':
      case 'okay':
      case 'fine':
        return '😐';
      case 'energetic':
      case 'motivated':
        return '🤗';
      case 'sick':
      case 'unwell':
        return '🤒';
      default:
        return '😊';
    }
  }

  /// Get mood color
  /// Returns MaterialColor value as int
  int get moodColor {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'excited':
      case 'energetic':
      case 'motivated':
        return 0xFF4CAF50; // Green 500
      case 'sad':
      case 'unhappy':
      case 'down':
        return 0xFF2196F3; // Blue 500
      case 'anxious':
      case 'worried':
      case 'nervous':
        return 0xFFFFA726; // Orange 400
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return 0xFF00BCD4; // Cyan 500
      case 'stressed':
      case 'overwhelmed':
        return 0xFFFF5722; // Deep Orange 500
      case 'tired':
      case 'exhausted':
      case 'sleepy':
        return 0xFF9C27B0; // Purple 500
      case 'angry':
      case 'frustrated':
      case 'irritated':
        return 0xFFD32F2F; // Red 700
      case 'neutral':
      case 'okay':
      case 'fine':
        return 0xFF9E9E9E; // Grey 500
      case 'sick':
      case 'unwell':
        return 0xFF795548; // Brown 500
      default:
        return 0xFF4CAF50; // Green 500
    }
  }

  /// Get energy level description
  String get energyLevelDescription {
    switch (energyLevel) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Unknown';
    }
  }

  /// Get energy level emoji
  String get energyLevelEmoji {
    switch (energyLevel) {
      case 1:
        return '🔋'; // Empty battery
      case 2:
        return '🔋'; // Low battery
      case 3:
        return '🔋'; // Half battery
      case 4:
        return '⚡'; // High energy
      case 5:
        return '⚡⚡'; // Very high energy
      default:
        return '🔋';
    }
  }

  /// Check if mood is positive
  bool get isPositiveMood {
    const positiveMoods = [
      'happy',
      'joyful',
      'excited',
      'calm',
      'peaceful',
      'relaxed',
      'energetic',
      'motivated'
    ];
    return positiveMoods.contains(mood.toLowerCase());
  }

  /// Check if mood is negative
  bool get isNegativeMood {
    const negativeMoods = [
      'sad',
      'unhappy',
      'down',
      'anxious',
      'worried',
      'nervous',
      'stressed',
      'overwhelmed',
      'angry',
      'frustrated',
      'irritated',
      'sick',
      'unwell'
    ];
    return negativeMoods.contains(mood.toLowerCase());
  }

  @override
  String toString() {
    return 'MoodLog(id: $id, mood: $mood, energy: $energyLevel, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MoodLog &&
        other.id == id &&
        other.userId == userId &&
        other.mood == mood &&
        other.energyLevel == energyLevel &&
        other.timestamp == timestamp &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        mood.hashCode ^
        energyLevel.hashCode ^
        timestamp.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }

  /// Static mood options
  static const List<String> moodOptions = [
    'happy',
    'sad',
    'anxious',
    'calm',
    'stressed',
    'tired',
    'angry',
    'neutral',
    'energetic',
    'sick',
  ];

  /// Get display name for mood
  static String getMoodDisplay(String mood) {
    return mood[0].toUpperCase() + mood.substring(1);
  }
}
