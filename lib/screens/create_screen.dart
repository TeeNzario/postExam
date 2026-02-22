import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/data.dart';
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


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
    }
  }

  void _save() {
    if (_selectedStationId == null || _selectedTypeId == null) return;

    final newReport = IncidentReport(
      reportId: reports.length + 1,
      stationId: _selectedStationId!,
      typeId: _selectedTypeId!,
      reporterName: _nameController.text.isEmpty ? null : _nameController.text,
      description: _descriptionController.text,
      evidencePhoto: _imagePath,
      timestamp: DateTime.now(),
      aiResult: 'Money',
      aiConfidence: 0.70,
    );

    reports.add(newReport);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                'หน่วยเลือกตั้ง*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedStationId,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: pollingStations
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
                initialValue: _selectedTypeId,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: violationTypes
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
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
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
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
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
                    backgroundColor: const Color(0xFFFFFFF),
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
