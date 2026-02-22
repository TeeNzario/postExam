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

  Map<String, dynamic> toMap() {
    return {
      'report_id': reportId,
      'station_id': stationId,
      'type_id': typeId,
      'reporter_name': reporterName,
      'description': description,
      'evidence_photo': evidencePhoto,
      'timestamp': timestamp.toIso8601String(),
      'ai_result': aiResult,
      'ai_confidence': aiConfidence,
    };
  }

  factory IncidentReport.fromMap(Map<String, dynamic> map) {
    return IncidentReport(
      reportId: map['report_id'] as int,
      stationId: map['station_id'] as int,
      typeId: map['type_id'] as int,
      reporterName: map['reporter_name'] as String?,
      description: map['description'] as String,
      evidencePhoto: map['evidence_photo'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      aiResult: map['ai_result'] as String?,
      aiConfidence: (map['ai_confidence'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'IncidentReport{reportId: $reportId, stationId: $stationId, typeId: $typeId, description: $description}';
  }
}
