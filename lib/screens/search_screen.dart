import 'package:flutter/material.dart';
import '../helper/database_helper.dart';
import '../models/incident_report.dart';
import '../widgets/report_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _db = DatabaseHelper.instance;
  final _searchController = TextEditingController();

  List<IncidentReport> _results = [];
  Map<int, String> _stationNames = {};
  Map<int, String> _typeNames = {};
  String? _selectedSeverity;
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<String> _severityOptions = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    final stations = await _db.getPollingStations();
    final types = await _db.getViolationTypes();
    setState(() {
      _stationNames = {for (var s in stations) s.id: s.name};
      _typeNames = {for (var t in types) t.id: t.name};
    });
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);

    final db = await _db.database;
    final keyword = _searchController.text.trim();

    String sql = '''
      SELECT ir.* FROM incident_reports ir
      JOIN violation_types vt ON ir.type_id = vt.id
      WHERE 1=1
    ''';
    List<dynamic> args = [];

    if (keyword.isNotEmpty) {
      sql += ' AND (ir.reporter_name LIKE ? OR ir.description LIKE ?)';
      args.add('%$keyword%');
      args.add('%$keyword%');
    }

    if (_selectedSeverity != null) {
      sql += ' AND vt.severity = ?';
      args.add(_selectedSeverity);
    }

    sql += ' ORDER BY ir.report_id DESC';

    final maps = await db.rawQuery(sql, args);
    final reports = maps.map((m) => IncidentReport.fromMap(m)).toList();

    setState(() {
      _results = reports;
      _isLoading = false;
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ค้นหารายการแจ้งเหตุ"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'ค้นหาชื่อผู้แจ้ง หรือรายละเอียด...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DropdownButtonFormField<String>(
                value: _selectedSeverity,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                hint: const Text('เลือกระดับความรุนแรง'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('ทั้งหมด'),
                  ),
                  ..._severityOptions.map(
                    (s) => DropdownMenuItem(value: s, child: Text(s)),
                  ),
                ],
                onChanged: (v) {
                  setState(() => _selectedSeverity = v);
                  _search();
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'ค้นหา',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasSearched
                  ? const Center(child: Text('กรุณาค้นหา'))
                  : _results.isEmpty
                  ? const Center(child: Text('ไม่มีที่คุณต้นหา'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final report = _results[index];
                        return ReportCard(
                          report: report,
                          stationName:
                              _stationNames[report.stationId] ?? 'ไม่ทราบ',
                          typeName: _typeNames[report.typeId] ?? 'ไม่ทราบ',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
