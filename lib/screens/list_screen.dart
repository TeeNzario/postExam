import 'package:flutter/material.dart';
import '../helper/database_helper.dart';
import '../models/incident_report.dart';
import '../widgets/report_card.dart';
import 'create_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _db = DatabaseHelper.instance;
  List<IncidentReport> _reports = [];
  Map<int, String> _stationNames = {};
  Map<int, String> _typeNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final reports = await _db.getIncidentReports();
    final stations = await _db.getPollingStations();
    final types = await _db.getViolationTypes();

    setState(() {
      _reports = reports;
      _stationNames = {for (var s in stations) s.id: s.name};
      _typeNames = {for (var t in types) t.id: t.name};
      _isLoading = false;
    });
  }

  Future<void> _deleteReport(int reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteIncidentReport(reportId);
      setState(() {
        _reports.removeWhere((r) => r.reportId == reportId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการแจ้งเหตุ"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: _reports.isEmpty
                  ? const Center(child: Text('ไม่มีรายการแจ้งเหตุ'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        final report = _reports[index];
                        return ReportCard(
                          report: report,
                          stationName:
                              _stationNames[report.stationId] ?? 'ไม่ทราบ',
                          typeName: _typeNames[report.typeId] ?? 'ไม่ทราบ',
                          onDelete: () => _deleteReport(report.reportId),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateScreen()),
              );
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
              'แจ้งเหตุเลย',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
