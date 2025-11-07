import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/pregnancy_provider.dart';

class ContractionTimerScreen extends StatefulWidget {
  const ContractionTimerScreen({super.key});

  @override
  State<ContractionTimerScreen> createState() => _ContractionTimerScreenState();
}

class _ContractionTimerScreenState extends State<ContractionTimerScreen> {
  bool _isTimingContraction = false;
  DateTime? _contractionStartTime;
  Timer? _timer;
  Duration _contractionDuration = Duration.zero;
  String _intensity = 'medium';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startContraction() {
    setState(() {
      _isTimingContraction = true;
      _contractionStartTime = DateTime.now();
      _contractionDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _contractionDuration =
            DateTime.now().difference(_contractionStartTime!);
      });
    });
  }

  void _stopContraction(PregnancyProvider provider) async {
    _timer?.cancel();

    final durationSeconds = _contractionDuration.inSeconds;

    await provider.addContraction(
      durationSeconds: durationSeconds,
      intensity: _intensity,
    );

    setState(() {
      _isTimingContraction = false;
      _contractionDuration = Duration.zero;
      _intensity = 'medium';
    });

    if (!mounted) return;

    // Check if pattern indicates active labor
    if (provider.isActiveLaborPattern()) {
      _showLaborWarning(provider);
    }
  }

  void _showLaborWarning(PregnancyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.isBangla
                    ? 'সক্রিয় প্রসব বেদনার সম্ভাবনা'
                    : 'Possible Active Labor',
              ),
            ),
          ],
        ),
        content: Text(
          provider.isBangla
              ? 'আপনার সংকোচন নিয়মিত এবং সক্রিয় প্রসব বেদনার লক্ষণ দেখাচ্ছে। অবিলম্বে হাসপাতালে যান বা ডাক্তারের সাথে যোগাযোগ করুন।'
              : 'Your contractions are regular and indicate possible active labor. Go to hospital or contact your doctor immediately.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(provider.isBangla ? 'বুঝেছি' : 'Understood'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration, bool isBangla) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (isBangla) {
      if (minutes > 0) {
        return '$minutes মিনিট $seconds সেকেন্ড';
      } else {
        return '$seconds সেকেন্ড';
      }
    } else {
      if (minutes > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${seconds}s';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC),
      appBar: AppBar(
        title: Consumer<PregnancyProvider>(
          builder: (context, provider, _) => Text(
            provider.isBangla ? 'সংকোচন টাইমার' : 'Contraction Timer',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFFE6E6FA),
        elevation: 0,
        actions: [
          Consumer<PregnancyProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: provider.isBangla ? 'সব মুছুন' : 'Clear All',
              onPressed: () => _showClearConfirmation(provider),
            ),
          ),
        ],
      ),
      body: Consumer<PregnancyProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Info card
                _buildInfoCard(provider),

                const SizedBox(height: 24),

                // Timer card
                _buildTimerCard(provider),

                const SizedBox(height: 24),

                // Pattern analysis
                if (provider.contractions.isNotEmpty)
                  _buildPatternAnalysis(provider),

                const SizedBox(height: 16),

                // Contractions list
                _buildContractionsList(provider),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(PregnancyProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6FA).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE6E6FA).withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFE6E6FA),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              provider.isBangla
                  ? 'প্রসব বেদনা শুরু হলে প্রতিটি সংকোচন টাইম করুন। সংকোচন ৫ মিনিট পর পর, ৪৫-৬০ সেকেন্ড স্থায়ী হলে হাসপাতালে যান।'
                  : 'Time each contraction when labor starts. Go to hospital when contractions are 5 minutes apart, lasting 45-60 seconds.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(PregnancyProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            provider.isBangla ? 'সংকোচনের সময়' : 'Contraction Duration',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF6B4D9D),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isTimingContraction
                    ? [
                        const Color(0xFF9B7DCD),
                        const Color(0xFF7B5DAD),
                      ]
                    : [
                        const Color(0xFFE8E0F0),
                        const Color(0xFFD8D0E0),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isTimingContraction
                      ? const Color(0xFF9B7DCD).withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _formatDuration(_contractionDuration, provider.isBangla),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _isTimingContraction
                      ? Colors.white
                      : const Color(0xFF6B4D9D),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_isTimingContraction) ...[
            Text(
              provider.isBangla ? 'তীব্রতা:' : 'Intensity:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B4D9D),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildIntensityButton(
                  provider,
                  'low',
                  provider.isBangla ? 'হালকা' : 'Mild',
                  const Color(0xFF4CAF50),
                ),
                _buildIntensityButton(
                  provider,
                  'medium',
                  provider.isBangla ? 'মাঝারি' : 'Moderate',
                  const Color(0xFFFF9800),
                ),
                _buildIntensityButton(
                  provider,
                  'high',
                  provider.isBangla ? 'তীব্র' : 'Strong',
                  const Color(0xFFF44336),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _stopContraction(provider),
                icon: const Icon(Icons.stop, size: 22),
                label: Text(
                  provider.isBangla ? 'বন্ধ করুন' : 'Stop',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startContraction,
                icon: const Icon(Icons.play_arrow, size: 26),
                label: Text(
                  provider.isBangla ? 'শুরু করুন' : 'Start',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B7DCD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIntensityButton(
    PregnancyProvider provider,
    String value,
    String label,
    Color color,
  ) {
    final isSelected = _intensity == value;

    return GestureDetector(
      onTap: () => setState(() => _intensity = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPatternAnalysis(PregnancyProvider provider) {
    final contractions = provider.contractions.take(3).toList();
    if (contractions.length < 2) return const SizedBox();

    final avgInterval = contractions
            .where((c) => c.intervalMinutes != null)
            .map((c) => c.intervalMinutes!)
            .fold(0, (a, b) => a + b) ~/
        contractions.where((c) => c.intervalMinutes != null).length;

    final avgDuration =
        contractions.map((c) => c.durationSeconds).fold(0, (a, b) => a + b) ~/
            contractions.length;

    final isRegular = provider.isActiveLaborPattern();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRegular
              ? [Colors.red.withOpacity(0.2), Colors.orange.withOpacity(0.2)]
              : [Colors.blue.withOpacity(0.1), Colors.green.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRegular ? Colors.red : Colors.blue,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRegular ? Icons.warning : Icons.analytics,
                color: isRegular ? Colors.red : Colors.blue,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                provider.isBangla ? 'প্যাটার্ন বিশ্লেষণ' : 'Pattern Analysis',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    provider.isBangla ? 'গড় ব্যবধান' : 'Avg Interval',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.isBangla
                        ? '$avgInterval মিনিট'
                        : '$avgInterval min',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Column(
                children: [
                  Text(
                    provider.isBangla ? 'গড় সময়কাল' : 'Avg Duration',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.isBangla
                        ? '$avgDuration সেকেন্ড'
                        : '$avgDuration sec',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isRegular) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.isBangla
                          ? 'নিয়মিত সংকোচন! হাসপাতালে যাওয়ার সময় হতে পারে।'
                          : 'Regular contractions! It may be time to go to hospital.',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContractionsList(PregnancyProvider provider) {
    final contractions = provider.contractions;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.isBangla
                ? 'আজকের সংকোচন (${contractions.length})'
                : 'Today\'s Contractions (${contractions.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (contractions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  provider.isBangla
                      ? 'আজ কোন সংকোচন রেকর্ড করা হয়নি'
                      : 'No contractions recorded today',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...contractions.map((contraction) {
              final intensityColor = contraction.intensity == 'high'
                  ? Colors.red
                  : contraction.intensity == 'medium'
                      ? Colors.orange
                      : Colors.green;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: intensityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: intensityColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: intensityColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                provider.isBangla
                                    ? contraction.getIntensityTextBN()
                                    : contraction.getIntensityTextEN(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: intensityColor,
                                ),
                              ),
                              Text(
                                '${contraction.startTime.hour}:${contraction.startTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.timer,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                provider.isBangla
                                    ? contraction.getDurationTextBN()
                                    : contraction.getDurationText(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (contraction.intervalMinutes != null) ...[
                                const SizedBox(width: 16),
                                Icon(Icons.schedule,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  provider.isBangla
                                      ? '${contraction.intervalMinutes} মিনিট পূর্বে'
                                      : '${contraction.intervalMinutes} min ago',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showClearConfirmation(PregnancyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider.isBangla ? 'নিশ্চিত করুন' : 'Confirm'),
        content: Text(
          provider.isBangla
              ? 'আজকের সব সংকোচন মুছে ফেলবেন?'
              : 'Clear all today\'s contractions?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(provider.isBangla ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.clearAllContractions();
              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(provider.isBangla ? 'মুছুন' : 'Clear'),
          ),
        ],
      ),
    );
  }
}
