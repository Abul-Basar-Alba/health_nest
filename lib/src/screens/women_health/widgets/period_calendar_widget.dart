// lib/src/screens/women_health/widgets/period_calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../women_health_colors.dart';

class PeriodCalendarWidget extends StatefulWidget {
  final List<DateTime> periodDays;
  final List<DateTime> fertileDays;
  final DateTime? ovulationDay;

  const PeriodCalendarWidget({
    super.key,
    this.periodDays = const [],
    this.fertileDays = const [],
    this.ovulationDay,
  });

  @override
  State<PeriodCalendarWidget> createState() => _PeriodCalendarWidgetState();
}

class _PeriodCalendarWidgetState extends State<PeriodCalendarWidget> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthSelector(),
        const SizedBox(height: 16),
        _buildWeekdayHeaders(),
        const SizedBox(height: 8),
        _buildCalendarGrid(),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: WomenHealthColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_left),
            color: WomenHealthColors.primaryPink,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: WomenHealthColors.darkText,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_right),
            color: WomenHealthColors.primaryPink,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WomenHealthColors.lightText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: firstWeekday + totalDays,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return const SizedBox.shrink();
        }

        final day = index - firstWeekday + 1;
        final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected =
            _selectedDate != null && _isSameDay(date, _selectedDate!);
        final isPeriodDay = widget.periodDays.any((d) => _isSameDay(d, date));
        final isFertileDay = widget.fertileDays.any((d) => _isSameDay(d, date));
        final isOvulation = widget.ovulationDay != null &&
            _isSameDay(widget.ovulationDay!, date);

        return _buildDayCell(
          day,
          date,
          isToday: isToday,
          isSelected: isSelected,
          isPeriodDay: isPeriodDay,
          isFertileDay: isFertileDay,
          isOvulation: isOvulation,
        );
      },
    );
  }

  Widget _buildDayCell(
    int day,
    DateTime date, {
    required bool isToday,
    required bool isSelected,
    required bool isPeriodDay,
    required bool isFertileDay,
    required bool isOvulation,
  }) {
    Color? backgroundColor;
    Color? textColor = WomenHealthColors.darkText;
    Widget? indicator;

    if (isPeriodDay) {
      backgroundColor = WomenHealthColors.periodRed.withOpacity(0.2);
      textColor = WomenHealthColors.periodRed;
      indicator = Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: WomenHealthColors.periodRed,
          shape: BoxShape.circle,
        ),
      );
    } else if (isOvulation) {
      backgroundColor = WomenHealthColors.ovulationBlue.withOpacity(0.2);
      textColor = WomenHealthColors.ovulationBlue;
      indicator = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: WomenHealthColors.ovulationBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: WomenHealthColors.ovulationBlue.withOpacity(0.5),
              blurRadius: 4,
            ),
          ],
        ),
      );
    } else if (isFertileDay) {
      backgroundColor = WomenHealthColors.lightMint.withOpacity(0.5);
      textColor = WomenHealthColors.mintGreen;
    }

    if (isSelected) {
      backgroundColor = WomenHealthColors.primaryPink;
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        _showDayDetails(date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(
                  color: WomenHealthColors.primaryPink,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
            if (indicator != null) ...[
              const SizedBox(height: 2),
              indicator,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: WomenHealthColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legend',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: WomenHealthColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('Period', WomenHealthColors.periodRed),
              _buildLegendItem('Fertile', WomenHealthColors.mintGreen),
              _buildLegendItem('Ovulation', WomenHealthColors.ovulationBlue),
              _buildLegendItem('Today', WomenHealthColors.primaryPink,
                  border: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool border = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: border ? Colors.transparent : color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: color, width: 2) : null,
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: WomenHealthColors.mediumText,
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showDayDetails(DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DayDetailsSheet(date: date),
    );
  }
}

class DayDetailsSheet extends StatefulWidget {
  final DateTime date;

  const DayDetailsSheet({super.key, required this.date});

  @override
  State<DayDetailsSheet> createState() => _DayDetailsSheetState();
}

class _DayDetailsSheetState extends State<DayDetailsSheet> {
  final List<String> _selectedSymptoms = [];
  String _selectedMood = 'neutral';
  int _flowLevel = 3;
  int _painLevel = 0;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(widget.date),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: WomenHealthColors.darkText,
                  ),
                ),
                const SizedBox(height: 24),
                _buildMoodSelector(),
                const SizedBox(height: 20),
                _buildFlowLevelSelector(),
                const SizedBox(height: 20),
                _buildPainLevelSelector(),
                const SizedBox(height: 20),
                _buildSymptomsSelector(),
                const SizedBox(height: 20),
                _buildNotesField(),
                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WomenHealthColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildMoodChip('happy', '😊', 'Happy'),
            _buildMoodChip('calm', '😌', 'Calm'),
            _buildMoodChip('energetic', '⚡', 'Energetic'),
            _buildMoodChip('neutral', '😐', 'Neutral'),
            _buildMoodChip('tired', '😴', 'Tired'),
            _buildMoodChip('anxious', '😰', 'Anxious'),
            _buildMoodChip('sad', '😢', 'Sad'),
            _buildMoodChip('irritable', '😠', 'Irritable'),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodChip(String value, String emoji, String label) {
    final isSelected = _selectedMood == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? WomenHealthColors.primaryPink
              : WomenHealthColors.palePink,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? WomenHealthColors.primaryPink
                : WomenHealthColors.lightPink,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : WomenHealthColors.mediumText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flow Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WomenHealthColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _flowLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: WomenHealthColors.periodRed,
                label: _getFlowLabel(_flowLevel),
                onChanged: (value) {
                  setState(() => _flowLevel = value.toInt());
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: WomenHealthColors.lightPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getFlowLabel(_flowLevel),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: WomenHealthColors.periodRed,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getFlowLabel(int level) {
    switch (level) {
      case 1:
        return 'Spotting';
      case 2:
        return 'Light';
      case 3:
        return 'Medium';
      case 4:
        return 'Heavy';
      case 5:
        return 'Very Heavy';
      default:
        return 'Medium';
    }
  }

  Widget _buildPainLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pain Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WomenHealthColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _painLevel.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: WomenHealthColors.symptomOrange,
                label: '$_painLevel/10',
                onChanged: (value) {
                  setState(() => _painLevel = value.toInt());
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: WomenHealthColors.lightPeach,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_painLevel/10',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: WomenHealthColors.symptomOrange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSymptomsSelector() {
    final symptoms = [
      'Cramps',
      'Headache',
      'Nausea',
      'Bloating',
      'Fatigue',
      'Mood Swings',
      'Tender Breasts',
      'Back Pain',
      'Acne',
      'Food Cravings',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptoms',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WomenHealthColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symptoms.map((symptom) {
            final isSelected = _selectedSymptoms.contains(symptom);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSymptoms.remove(symptom);
                  } else {
                    _selectedSymptoms.add(symptom);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? WomenHealthColors.primaryPurple
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? WomenHealthColors.primaryPurple
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  symptom,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? Colors.white
                        : WomenHealthColors.mediumText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WomenHealthColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any additional notes...',
            hintStyle: TextStyle(color: WomenHealthColors.lightText),
            filled: true,
            fillColor: WomenHealthColors.palePink,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Save logic here
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log saved successfully!'),
              backgroundColor: WomenHealthColors.primaryPink,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: WomenHealthColors.primaryPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save Log',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
