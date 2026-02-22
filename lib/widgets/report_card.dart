import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../constants/data.dart';
import 'confidence_bar.dart';

class ReportCard extends StatelessWidget {
  final IncidentReport report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final violationType = violationTypes.firstWhere(
      (v) => v.id == report.typeId,
    );
    final displayName =
        (report.reporterName == null || report.reporterName!.isEmpty)
        ? 'พลเมอืงดี'
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
                    Text(
                      violationType.name,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      displayName,
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
                child: report.evidencePhoto != null
                    ? Image.asset(
                        report.evidencePhoto!,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[300],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
