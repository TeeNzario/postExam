class IncidentReport {
  final int reportId;
  final int stationId;
  final int typeId;
  final String? reporterName;
  final String description;
  final String? evidencePhoto;
  final DateTime timestamp;
  final String? aiResult;
  final double aiConfidence;

  IncidentReport({
    required this.reportId,
    required this.stationId,
    required this.typeId,
    this.reporterName,
    required this.description,
    this.evidencePhoto,
    required this.timestamp,
    this.aiResult,
    required this.aiConfidence,
  });
}
