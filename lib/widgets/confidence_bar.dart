import 'package:flutter/material.dart';

class ConfidenceBar extends StatelessWidget {
  final double confidence;
  final String aiResult;

  const ConfidenceBar({
    super.key,
    required this.confidence,
    required this.aiResult,
  });

  @override
  Widget build(BuildContext context) {
    int percentage = (confidence * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ค่าความมั่นใจ ($aiResult)',
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                child: LinearProgressIndicator(
                  value: confidence,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
