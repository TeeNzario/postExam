import '../models/polling_station.dart';
import '../models/violation_type.dart';
import '../models/incident_report.dart';

final List<PollingStation> pollingStations = [
  PollingStation(
    id: 101,
    name: 'โรงเรียนวัดพระมหาธาตุ',
    zone: 'เขต 1',
    province: 'นครศรีธรรมราช',
  ),
  PollingStation(
    id: 102,
    name: 'เต็นท์หน้าตลาดท่าวัง',
    zone: 'เขต 1',
    province: 'นครศรีธรรมราช',
  ),
  PollingStation(
    id: 103,
    name: 'ศาลากลางหมู่บ้านคีรีวง',
    zone: 'เขต 2',
    province: 'นครศรีธรรมราช',
  ),
  PollingStation(
    id: 104,
    name: 'หอประชุมอำเภอทุ่งสง',
    zone: 'เขต 3',
    province: 'นครศรีธรรมราช',
  ),
];

final List<ViolationType> violationTypes = [
  ViolationType(
    id: 1,
    name: 'ซื้อสิทธิ์ขายเสียง (Buying Votes)',
    severity: 'High',
  ),
  ViolationType(
    id: 2,
    name: 'ขนคนไปลงคะแนน (Transportation)',
    severity: 'High',
  ),
  ViolationType(
    id: 3,
    name: 'หาเสียงเกินเวลา (Overtime Campaign)',
    severity: 'Medium',
  ),
  ViolationType(id: 4, name: 'ทำลายป้ายหาเสียง (Vandalism)', severity: 'Low'),
  ViolationType(
    id: 5,
    name: 'เจ้าหน้าที่วางตัวไม่เป็นกลาง (Bias Official)',
    severity: 'High',
  ),
];

List<IncidentReport> reports = [
  IncidentReport(
    reportId: 1,
    stationId: 101,
    typeId: 1,
    reporterName: 'นายโจนาธาน โจสตาร์',
    description: 'มีการให้เงิน 1000 บาทพร้อมกับใบปลิวการเลือกตั้งพรรคไม่โร่',
    evidencePhoto: null,
    timestamp: DateTime(2026, 2, 20, 10, 30),
    aiResult: 'Money',
    aiConfidence: 0.95,
  ),
  IncidentReport(
    reportId: 2,
    stationId: 102,
    typeId: 3,
    reporterName: null,
    description: 'รถแห่เสียงดังรบกวน',
    evidencePhoto: null,
    timestamp: DateTime(2026, 2, 20, 11, 0),
    aiResult: 'Money',
    aiConfidence: 0.75,
  ),
  IncidentReport(
    reportId: 3,
    stationId: 103,
    typeId: 5,
    reporterName: 'นายโจนาธาน โจสตาร์',
    description: 'มีเจ้าหน้าที่วางตัวไม่เป็นกลาง',
    evidencePhoto: null,
    timestamp: DateTime(2026, 2, 20, 12, 0),
    aiResult: null,
    aiConfidence: 0.0,
  ),
];
