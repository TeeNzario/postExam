import 'dart:io';
import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import 'confidence_bar.dart';

class ReportCard extends StatelessWidget {
  final IncidentReport report;
  final String stationName;
  final String typeName;
  final VoidCallback? onDelete;

  const ReportCard({
    super.key,
    required this.report,
    required this.stationName,
    required this.typeName,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        (report.reporterName == null || report.reporterName!.isEmpty)
        ? 'พลเมืองดี'
        : report.reporterName!;

    return GestureDetector(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(typeName, style: const TextStyle(fontSize: 18)),
                    Text(
                      '$displayName • $stationName',
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    ConfidenceBar(confidence: report.aiConfidence),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                child:
                    report.evidencePhoto != null &&
                        File(report.evidencePhoto!).existsSync()
                    ? Image.file(
                        File(report.evidencePhoto!),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      )
                    : Container(width: 90, height: 90, color: Colors.grey[300]),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
