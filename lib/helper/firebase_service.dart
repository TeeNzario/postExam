import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_report.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  FirebaseService._init();

  final _firestore = FirebaseFirestore.instance;

  Future<void> insertIncidentReportToFirebase(IncidentReport report) async {
    final map = report.toMap();
    map.remove('report_id');
    map['evidence_photo'] = 'OFFLINE_ONLY';
    await _firestore.collection('incident_reports').add(map);
  }
}
