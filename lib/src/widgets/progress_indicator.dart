import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int goal;
  final int currentValue;
  final String label;

  const ProgressIndicatorWidget({
    super.key,
    required this.goal,
    required this.currentValue,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = goal > 0 ? currentValue / goal : 0.0;
    final Color progressColor = progress >= 1.0 ? Colors.green : Colors.blue;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentValue.toString(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
