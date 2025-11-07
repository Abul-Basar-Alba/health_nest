// lib/src/screens/settings/voice_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/pregnancy_provider.dart';
import '../../services/tts_service.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  final TtsService _ttsService = TtsService();
  bool _isInitializing = true;
  List<String> _availableLanguages = [];

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
    final languages = await _ttsService.getAvailableLanguages();
    setState(() {
      _availableLanguages = languages;
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              provider.isBangla ? 'ভয়েস সেটিংস' : 'Voice Settings',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF009688), // Teal
            elevation: 0,
          ),
          body: _isInitializing
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.volume_up,
                              size: 64,
                              color: Colors.teal[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.isBangla
                                  ? 'ভয়েস রিমাইন্ডার'
                                  : 'Voice Reminders',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.isBangla
                                  ? 'রিমাইন্ডারের জন্য ভয়েস সেটিংস কাস্টমাইজ করুন'
                                  : 'Customize voice settings for reminders',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Enable/Disable Toggle
                    Card(
                      child: SwitchListTile(
                        title: Text(
                          provider.isBangla
                              ? 'ভয়েস রিমাইন্ডার সক্রিয় করুন'
                              : 'Enable Voice Reminders',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          provider.isBangla
                              ? 'রিমাইন্ডারের জন্য ভয়েস নোটিফিকেশন শুনুন'
                              : 'Hear voice notifications for reminders',
                        ),
                        value: _ttsService.isEnabled,
                        onChanged: (value) async {
                          await _ttsService.setEnabled(value);
                          setState(() {});

                          if (value) {
                            _testVoice(provider.isBangla);
                          }
                        },
                        activeThumbColor: Colors.teal,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Volume Control
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.volume_up, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  provider.isBangla ? 'ভলিউম' : 'Volume',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _ttsService.volume,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              label:
                                  (_ttsService.volume * 100).round().toString(),
                              onChanged: _ttsService.isEnabled
                                  ? (value) async {
                                      await _ttsService.setVolume(value);
                                      setState(() {});
                                    }
                                  : null,
                            ),
                            Text(
                              '${(_ttsService.volume * 100).round()}%',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Pitch Control
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.graphic_eq, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  provider.isBangla ? 'পিচ' : 'Pitch',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _ttsService.pitch,
                              min: 0.5,
                              max: 2.0,
                              divisions: 15,
                              label: _ttsService.pitch.toStringAsFixed(1),
                              onChanged: _ttsService.isEnabled
                                  ? (value) async {
                                      await _ttsService.setPitch(value);
                                      setState(() {});
                                    }
                                  : null,
                            ),
                            Text(
                              _ttsService.pitch.toStringAsFixed(1),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Speed Control
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.speed, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  provider.isBangla ? 'গতি' : 'Speed',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _ttsService.rate,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              label: _ttsService.rate.toStringAsFixed(1),
                              onChanged: _ttsService.isEnabled
                                  ? (value) async {
                                      await _ttsService.setRate(value);
                                      setState(() {});
                                    }
                                  : null,
                            ),
                            Text(
                              '${(_ttsService.rate * 10).round()}/10',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Test Voice Buttons
                    Text(
                      provider.isBangla ? 'ভয়েস টেস্ট করুন' : 'Test Voice',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // English Test
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF2196F3),
                          child: Text(
                            'EN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: const Text('Test English Voice'),
                        subtitle: const Text(
                          'This is a test of the English voice reminder',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: _ttsService.isEnabled
                              ? () => _testVoice(false)
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Bangla Test
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF4CAF50),
                          child: Text(
                            'বাং',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: const Text('বাংলা ভয়েস টেস্ট করুন'),
                        subtitle: const Text(
                          'এটি বাংলা ভয়েস রিমাইন্ডারের একটি পরীক্ষা',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: _ttsService.isEnabled
                              ? () => _testVoice(true)
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Language Info
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                Text(
                                  provider.isBangla
                                      ? 'ভাষা সাপোর্ট'
                                      : 'Language Support',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.isBangla
                                  ? 'আপনার ডিভাইস ${_availableLanguages.contains("bn-IN") ? "বাংলা" : "ইংরেজি"} ভয়েস সাপোর্ট করে। ${_availableLanguages.contains("bn-IN") ? "" : "বাংলা ভয়েস ব্যবহার করতে, আপনার ডিভাইসে বাংলা ভাষা প্যাক ইনস্টল করুন।"}'
                                  : 'Your device supports ${_availableLanguages.contains("bn-IN") ? "Bangla" : "English"} voice. ${_availableLanguages.contains("bn-IN") ? "" : "To use Bangla voice, install Bangla language pack on your device."}',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stop Button
                    ElevatedButton.icon(
                      onPressed: () => _ttsService.stop(),
                      icon: const Icon(Icons.stop),
                      label: Text(
                        provider.isBangla ? 'ভয়েস বন্ধ করুন' : 'Stop Voice',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _testVoice(bool isBangla) async {
    if (isBangla) {
      await _ttsService.speak(
        'এটি বাংলা ভয়েস রিমাইন্ডারের একটি পরীক্ষা। আপনার সেটিংস সঠিক কিনা দেখুন।',
        isBangla: true,
      );
    } else {
      await _ttsService.speak(
        'This is a test of the English voice reminder system. Check if your settings are correct.',
        isBangla: false,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBangla ? 'ভয়েস টেস্ট চলছে...' : 'Playing voice test...',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }
}
