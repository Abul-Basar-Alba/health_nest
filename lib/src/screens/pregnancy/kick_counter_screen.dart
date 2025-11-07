import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/pregnancy_provider.dart';

class KickCounterScreen extends StatefulWidget {
  const KickCounterScreen({super.key});

  @override
  State<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends State<KickCounterScreen> {
  int _kickCount = 0;
  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String? _sessionId;
  bool _isSessionActive = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession(PregnancyProvider provider) async {
    final id = await provider.startKickCountSession();
    if (id != null) {
      setState(() {
        _sessionId = id;
        _startTime = DateTime.now();
        _kickCount = 0;
        _elapsed = Duration.zero;
        _isSessionActive = true;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });
      });
    }
  }

  void _addKick(PregnancyProvider provider) async {
    if (!_isSessionActive || _sessionId == null) return;

    setState(() {
      _kickCount++;
    });

    await provider.updateKickCount(_sessionId!, _kickCount);

    if (_kickCount >= 10) {
      _completeSession(provider);
    }
  }

  void _completeSession(PregnancyProvider provider) {
    _timer?.cancel();
    setState(() {
      _isSessionActive = false;
    });

    final duration = _elapsed.inMinutes;
    final isNormal = duration <= 120;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isNormal ? Icons.check_circle : Icons.warning,
              color: isNormal ? const Color(0xFF98FF98) : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(provider.isBangla ? 'সেশন সম্পূর্ণ' : 'Session Complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.isBangla
                  ? '১০টি লাথি গণনা সম্পূর্ণ!'
                  : '10 kicks counted!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(provider.isBangla ? 'সময়:' : 'Time:'),
                Text(
                  _formatDuration(_elapsed, provider.isBangla),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isNormal)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.isBangla
                            ? 'স্বাভাবিকের চেয়ে বেশি সময় লেগেছে। ডাক্তারের সাথে পরামর্শ করুন।'
                            : 'Took longer than usual. Consult your doctor.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF98FF98),
            ),
            child: Text(provider.isBangla ? 'ঠিক আছে' : 'OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration, bool isBangla) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (isBangla) {
      if (hours > 0) {
        return '$hours ঘন্টা $minutes মিনিট $seconds সেকেন্ড';
      } else if (minutes > 0) {
        return '$minutes মিনিট $seconds সেকেন্ড';
      } else {
        return '$seconds সেকেন্ড';
      }
    } else {
      if (hours > 0) {
        return '${hours}h ${minutes}m ${seconds}s';
      } else if (minutes > 0) {
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
            provider.isBangla ? 'কিক কাউন্টার' : 'Kick Counter',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFF98FF98),
        elevation: 0,
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

                // Main counter
                _buildCounterCard(provider),

                const SizedBox(height: 24),

                // History
                _buildHistoryCard(provider),

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
        color: const Color(0xFF98FF98).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF98FF98).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF98FF98),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              provider.isBangla
                  ? 'শিশুর নড়াচড়া পর্যবেক্ষণের জন্য প্রতিদিন ১০টি লাথি গণনা করুন। সাধারণত ২ ঘন্টার মধ্যে ১০টি লাথি অনুভব করা উচিত।'
                  : 'Count 10 kicks daily to monitor baby\'s movement. You should feel 10 kicks within 2 hours normally.',
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

  Widget _buildCounterCard(PregnancyProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
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
            provider.isBangla ? 'লাথির সংখ্যা' : 'Kick Count',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF98FF98).withOpacity(0.3),
                  const Color(0xFF98FF98).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF98FF98),
                width: 4,
              ),
            ),
            child: Center(
              child: Text(
                '$_kickCount',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF98FF98),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_isSessionActive) ...[
            Text(
              _formatDuration(_elapsed, provider.isBangla),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addKick(provider),
                  icon: const Icon(Icons.add),
                  label: Text(
                    provider.isBangla ? 'লাথি যোগ করুন' : 'Add Kick',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF98FF98),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () => _startSession(provider),
              icon: const Icon(Icons.play_arrow),
              label: Text(
                provider.isBangla ? 'শুরু করুন' : 'Start',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98FF98),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryCard(PregnancyProvider provider) {
    final history = provider.kickCounts.take(10).toList();

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
            provider.isBangla ? 'ইতিহাস' : 'History',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  provider.isBangla ? 'কোন রেকর্ড নেই' : 'No records yet',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...history.map((kickCount) {
              final isComplete = kickCount.isComplete();
              final isNormal = kickCount.isNormalDuration();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isComplete
                      ? (isNormal ? const Color(0xFF98FF98) : Colors.orange)
                          .withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isComplete
                        ? (isNormal ? const Color(0xFF98FF98) : Colors.orange)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isComplete ? Icons.check_circle : Icons.pending,
                      color: isComplete
                          ? (isNormal ? const Color(0xFF98FF98) : Colors.orange)
                          : Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.isBangla
                                ? '${kickCount.kickCount} লাথি'
                                : '${kickCount.kickCount} kicks',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            provider.isBangla
                                ? kickCount.getDurationTextBN()
                                : kickCount.getDurationText(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${kickCount.startTime.day}/${kickCount.startTime.month}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
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
}
