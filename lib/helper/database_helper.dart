import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/polling_station.dart';
import '../models/violation_type.dart';
import '../models/incident_report.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('election_watch.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE polling_stations (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        zone TEXT NOT NULL,
        province TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE violation_types (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        severity TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE incident_reports (
        report_id INTEGER PRIMARY KEY AUTOINCREMENT,
        station_id INTEGER NOT NULL,
        type_id INTEGER NOT NULL,
        reporter_name TEXT,
        description TEXT NOT NULL,
        evidence_photo TEXT,
        timestamp TEXT NOT NULL,
        ai_result TEXT,
        ai_confidence REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (station_id) REFERENCES polling_stations(id),
        FOREIGN KEY (type_id) REFERENCES violation_types(id)
      )
    ''');

    await _seedData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _seedData(db);
    }
  }

  Future<void> _seedData(Database db) async {
    final stationCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM polling_stations'),
    );
    final typeCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM violation_types'),
    );

    if (stationCount == 0) {
      await db.insert('polling_stations', {
        'id': 101,
        'name': 'โรงเรียนวัดพระมหาธาตุ',
        'zone': 'เขต 1',
        'province': 'นครศรีธรรมราช',
      });
      await db.insert('polling_stations', {
        'id': 102,
        'name': 'เต็นท์หน้าตลาดท่าวัง',
        'zone': 'เขต 1',
        'province': 'นครศรีธรรมราช',
      });
      await db.insert('polling_stations', {
        'id': 103,
        'name': 'ศาลากลางหมู่บ้านคีรีวง',
        'zone': 'เขต 2',
        'province': 'นครศรีธรรมราช',
      });
      await db.insert('polling_stations', {
        'id': 104,
        'name': 'หอประชุมอำเภอทุ่งสง',
        'zone': 'เขต 3',
        'province': 'นครศรีธรรมราช',
      });
    }

    if (typeCount == 0) {
      await db.insert('violation_types', {
        'id': 1,
        'name': 'ซื้อสิทธิ์ขายเสียง (Buying Votes)',
        'severity': 'High',
      });
      await db.insert('violation_types', {
        'id': 2,
        'name': 'ขนคนไปลงคะแนน (Transportation)',
        'severity': 'High',
      });
      await db.insert('violation_types', {
        'id': 3,
        'name': 'หาเสียงเกินเวลา (Overtime Campaign)',
        'severity': 'Medium',
      });
      await db.insert('violation_types', {
        'id': 4,
        'name': 'ทำลายป้ายหาเสียง (Vandalism)',
        'severity': 'Low',
      });
      await db.insert('violation_types', {
        'id': 5,
        'name': 'เจ้าหน้าที่วางตัวไม่เป็นกลาง (Bias Official)',
        'severity': 'High',
      });
    }
  }

  //polling stations
  Future<int> insertPollingStation(PollingStation station) async {
    final db = await database;
    return await db.insert(
      'polling_stations',
      station.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PollingStation>> getPollingStations() async {
    final db = await database;
    final maps = await db.query('polling_stations');
    return maps.map((map) => PollingStation.fromMap(map)).toList();
  }

  Future<PollingStation?> getPollingStationById(int id) async {
    final db = await database;
    final maps = await db.query(
      'polling_stations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PollingStation.fromMap(maps.first);
  }

  Future<int> updatePollingStation(PollingStation station) async {
    final db = await database;
    return await db.update(
      'polling_stations',
      station.toMap(),
      where: 'id = ?',
      whereArgs: [station.id],
    );
  }

  Future<int> deletePollingStation(int id) async {
    final db = await database;
    return await db.delete(
      'polling_stations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //violation types
  Future<int> insertViolationType(ViolationType type) async {
    final db = await database;
    return await db.insert(
      'violation_types',
      type.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ViolationType>> getViolationTypes() async {
    final db = await database;
    final maps = await db.query('violation_types');
    return maps.map((map) => ViolationType.fromMap(map)).toList();
  }

  Future<ViolationType?> getViolationTypeById(int id) async {
    final db = await database;
    final maps = await db.query(
      'violation_types',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ViolationType.fromMap(maps.first);
  }

  Future<int> updateViolationType(ViolationType type) async {
    final db = await database;
    return await db.update(
      'violation_types',
      type.toMap(),
      where: 'id = ?',
      whereArgs: [type.id],
    );
  }

  Future<int> deleteViolationType(int id) async {
    final db = await database;
    return await db.delete('violation_types', where: 'id = ?', whereArgs: [id]);
  }

  //incident reports
  Future<int> insertIncidentReport(IncidentReport report) async {
    final db = await database;
    final map = report.toMap();
    map.remove('report_id'); 
    return await db.insert(
      'incident_reports',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<IncidentReport>> getIncidentReports() async {
    final db = await database;
    final maps = await db.query('incident_reports');
    return maps.map((map) => IncidentReport.fromMap(map)).toList();
  }

  Future<IncidentReport?> getIncidentReportById(int reportId) async {
    final db = await database;
    final maps = await db.query(
      'incident_reports',
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
    if (maps.isEmpty) return null;
    return IncidentReport.fromMap(maps.first);
  }

  Future<int> updateIncidentReport(IncidentReport report) async {
    final db = await database;
    return await db.update(
      'incident_reports',
      report.toMap(),
      where: 'report_id = ?',
      whereArgs: [report.reportId],
    );
  }

  Future<int> deleteIncidentReport(int reportId) async {
    final db = await database;
    return await db.delete(
      'incident_reports',
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
  }

  Future<int> getTotalReportCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM incident_reports');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTop3Stations() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT polling_stations.name, COUNT(*) as total
      FROM incident_reports
      JOIN polling_stations
      ON incident_reports.station_id = polling_stations.id
      GROUP BY station_id
      ORDER BY total DESC
      LIMIT 3
    ''');
  }

  Future<bool> checkDuplicateStationName(String name, int excludeId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM polling_stations WHERE name = ? AND id != ?',
      [name, excludeId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<int> countReportsByStation(int stationId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM incident_reports WHERE station_id = ?',
      [stationId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
