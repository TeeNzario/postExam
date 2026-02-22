import 'package:flutter/material.dart';
import '../helper/database_helper.dart';
import '../models/polling_station.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _db = DatabaseHelper.instance;
  List<PollingStation> _stations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final stations = await _db.getPollingStations();
    setState(() {
      _stations = stations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขหน่วยเลือกตั้ง'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _stations.isEmpty
            ? const Center(child: Text('ไม่มีหน่วยเลือกตั้ง'))
            : ListView.builder(
                itemCount: _stations.length,
                itemBuilder: (context, index) {
                  final station = _stations[index];
                  return ListTile(
                    title: Text(station.name),
                    subtitle: Text('${station.zone} ${station.province}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              _EditStationFormScreen(station: station),
                        ),
                      );
                      if (result == true) {
                        _loadStations();
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _EditStationFormScreen extends StatefulWidget {
  final PollingStation station;

  const _EditStationFormScreen({required this.station});

  @override
  State<_EditStationFormScreen> createState() => _EditStationFormScreenState();
}

class _EditStationFormScreenState extends State<_EditStationFormScreen> {
  final _db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _zoneController;
  late final TextEditingController _provinceController;

  static const _validPrefixes = ['โรงเรียน', 'วัด', 'ศาลา', 'หอประชุม', 'เต็นท์'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.station.name);
    _zoneController = TextEditingController(text: widget.station.zone);
    _provinceController = TextEditingController(text: widget.station.province);
  }

  bool _isValidPrefix(String name) {
    return _validPrefixes.any((prefix) => name.startsWith(prefix));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final zone = _zoneController.text.trim();
    final province = _provinceController.text.trim();

    if (!_isValidPrefix(name)) {
      _showError('ชื่อหน่วยต้องขึ้นต้นด้วย: โรงเรียน, วัด, ศาลา, หอประชุม');
      return;
    }

    final isDuplicate = await _db.checkDuplicateStationName(
      name,
      widget.station.id,
    );
    if (isDuplicate) {
      _showError('ชื่อหน่วยเลือกตั้งนี้มีอยู่แล้ว');
      return;
    }

    final reportCount = await _db.countReportsByStation(widget.station.id);

    if (reportCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('ยืนยันการแก้ไข'),
          content: Text(
            'หน่วยเลือกตั้งนี้มี $reportCount รายการแจ้งเหตุ\nต้องการแก้ไขจริงหรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('แก้ไข'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final updated = PollingStation(
      id: widget.station.id,
      name: name,
      zone: zone,
      province: province,
    );
    await _db.updatePollingStation(updated);

    if (mounted) Navigator.pop(context, true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลหน่วย'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ชื่อหน่วยเลือกตั้ง*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'กรุณากรอกชื่อหน่วย'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'เขต*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _zoneController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'กรุณากรอกเขต' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'จังหวัด*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _provinceController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'กรุณากรอกจังหวัด' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text(
                    'บันทึก',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
