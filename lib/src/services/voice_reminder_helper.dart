// lib/src/services/voice_reminder_helper.dart

import 'tts_service.dart';

class VoiceReminderHelper {
  static final VoiceReminderHelper _instance = VoiceReminderHelper._internal();
  factory VoiceReminderHelper() => _instance;
  VoiceReminderHelper._internal();

  final TtsService _ttsService = TtsService();

  // Initialize TTS
  Future<void> initialize() async {
    await _ttsService.initialize();
  }

  // Speak any reminder
  Future<void> speakReminder({
    required String title,
    required String message,
    required bool isBangla,
  }) async {
    await _ttsService.speakReminder(title, message, isBangla: isBangla);
  }

  // Speak doctor visit reminder
  Future<void> speakDoctorVisit({
    required String visitType,
    required String doctorName,
    required DateTime visitDate,
    required bool isBangla,
  }) async {
    await _ttsService.speakDoctorVisitReminder(
      visitType: visitType,
      doctorName: doctorName,
      visitDate: visitDate,
      isBangla: isBangla,
    );
  }

  // Speak medicine reminder
  Future<void> speakMedicine({
    required String medicineName,
    required String dosage,
    required bool isBangla,
  }) async {
    await _ttsService.speakMedicineReminder(
      medicineName: medicineName,
      dosage: dosage,
      isBangla: isBangla,
    );
  }

  // Speak feeding reminder
  Future<void> speakFeedingReminder({
    required bool isBangla,
  }) async {
    final text = isBangla
        ? 'খাওয়ানোর রিমাইন্ডার। আপনার শিশুকে খাওয়ানোর সময় হয়েছে।'
        : 'Feeding reminder. Time to feed your baby.';

    await _ttsService.speak(text, isBangla: isBangla);
  }

  // Speak checkup reminder
  Future<void> speakCheckupReminder({
    required String checkupType,
    required bool isBangla,
  }) async {
    final text = isBangla
        ? 'চেকআপের রিমাইন্ডার। আপনার $checkupType এর জন্য সময় হয়েছে।'
        : 'Checkup reminder. Time for your $checkupType.';

    await _ttsService.speak(text, isBangla: isBangla);
  }

  // Speak kick count reminder
  Future<void> speakKickCountReminder({
    required bool isBangla,
  }) async {
    final text = isBangla
        ? 'কিক কাউন্টের রিমাইন্ডার। আপনার শিশুর লাথির সংখ্যা রেকর্ড করার সময় হয়েছে।'
        : 'Kick count reminder. Time to record your baby\'s kicks.';

    await _ttsService.speak(text, isBangla: isBangla);
  }

  // Speak water intake reminder
  Future<void> speakWaterReminder({
    required bool isBangla,
  }) async {
    final text = isBangla
        ? 'পানি পানের রিমাইন্ডার। হাইড্রেটেড থাকার জন্য পানি পান করুন।'
        : 'Water reminder. Drink water to stay hydrated.';

    await _ttsService.speak(text, isBangla: isBangla);
  }

  // Speak contraction alert
  Future<void> speakContractionAlert({
    required int frequency,
    required bool isBangla,
  }) async {
    await _ttsService.speakContractionAlert(
      frequency: frequency,
      isBangla: isBangla,
    );
  }

  // Speak week milestone
  Future<void> speakWeekMilestone({
    required int week,
    required String milestone,
    required bool isBangla,
  }) async {
    await _ttsService.speakWeekMilestone(
      week: week,
      milestone: milestone,
      isBangla: isBangla,
    );
  }

  // Speak exercise reminder
  Future<void> speakExerciseReminder({
    required String exerciseType,
    required bool isBangla,
  }) async {
    final text = isBangla
        ? 'ব্যায়ামের রিমাইন্ডার। $exerciseType করার সময় হয়েছে।'
        : 'Exercise reminder. Time for $exerciseType.';

    await _ttsService.speak(text, isBangla: isBangla);
  }

  // Speak medication schedule
  Future<void> speakMedicationSchedule({
    required List<String> medications,
    required bool isBangla,
  }) async {
    if (medications.isEmpty) return;

    final medicineList = medications.join(', ');
    final text = isBangla
        ? 'ওষুধের সময়সূচী। আজ আপনার নিতে হবে: $medicineList।'
        : 'Medication schedule. Today you need to take: $medicineList.';

    await _ttsService.speak(text, isBangla: isBangla);
  }

  // Speak prenatal vitamin reminder
  Future<void> speakVitaminReminder({
    required bool isBangla,
  }) async {
    final text = isBangla
        ? 'ভিটামিনের রিমাইন্ডার। আপনার প্রসবপূর্ব ভিটামিন নেওয়ার সময় হয়েছে।'
        : 'Vitamin reminder. Time to take your prenatal vitamins.';

    await _ttsService.speak(text, isBangla: isBangla);
  }

  // Speak appointment confirmation
  Future<void> speakAppointmentConfirmation({
    required String appointmentType,
    required DateTime appointmentTime,
    required bool isBangla,
  }) async {
    final timeStr =
        '${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')}';

    final text = isBangla
        ? 'অ্যাপয়েন্টমেন্ট নিশ্চিতকরণ। আপনার $appointmentType $timeStr এ।'
        : 'Appointment confirmation. Your $appointmentType is at $timeStr.';

    await _ttsService.speak(text, isBangla: isBangla);
  }

  // Stop voice
  Future<void> stop() async {
    await _ttsService.stop();
  }

  // Check if voice is enabled
  bool get isEnabled => _ttsService.isEnabled;

  // Get voice settings
  double get volume => _ttsService.volume;
  double get pitch => _ttsService.pitch;
  double get rate => _ttsService.rate;
}
