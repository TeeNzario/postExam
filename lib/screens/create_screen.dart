import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../helper/database_helper.dart';
import '../helper/firebase_service.dart';
import '../models/polling_station.dart';
import '../models/violation_type.dart';
import '../models/incident_report.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedStationId;
  int? _selectedTypeId;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imagePath;

  final _db = DatabaseHelper.instance;
  List<PollingStation> _stations = [];
  List<ViolationType> _types = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stations = await _db.getPollingStations();
    final types = await _db.getViolationTypes();
    setState(() {
      _stations = stations;
      _types = types;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
    }
  }

  Future<String?> _saveImageToAssets(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final assetsDir = Directory(p.join(appDir.path, 'assets'));
    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourcePath)}';
    final destPath = p.join(assetsDir.path, fileName);
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStationId == null || _selectedTypeId == null) return;

    String? savedImagePath;
    if (_imagePath != null) {
      savedImagePath = await _saveImageToAssets(_imagePath!);
    }

    final newReport = IncidentReport(
      reportId: 0, // auto-increment by SQLite
      stationId: _selectedStationId!,
      typeId: _selectedTypeId!,
      reporterName: _nameController.text.isEmpty ? null : _nameController.text,
      description: _descriptionController.text,
      evidencePhoto: savedImagePath,
      timestamp: DateTime.now(),
      aiResult: 'Money',
      aiConfidence: 0.70,
    );

    await _db.insertIncidentReport(newReport);
    await FirebaseService.instance.insertIncidentReportToFirebase(newReport);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'หน่วยเลือกตั้ง*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedStationId,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: _stations
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(
                          s.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedStationId = v),
                validator: (v) => v == null ? 'กรุณาเลือกหน่วยเลือกตั้ง' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'ประเภทความผิด*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedTypeId,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: _types
                    .map(
                      (v) => DropdownMenuItem(value: v.id, child: Text(v.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedTypeId = v),
                validator: (v) => v == null ? 'กรุณาเลือกประเภทความผิด' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'ชื่อผู้แจ้ง',
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
              ),
              const SizedBox(height: 20),
              const Text(
                'รายละเอียด',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'กรุณากรอกรายละเอียด' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'รูปภาพหลักฐาน',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('อัพโหลด'),
                  ),
                  const SizedBox(width: 12),
                  if (_imagePath != null)
                    ClipRRect(
                      child: Image.file(
                        File(_imagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    foregroundColor: Colors.black,
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
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
