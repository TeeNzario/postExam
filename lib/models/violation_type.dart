class ViolationType {
  final int id;
  final String name;
  final String? severity;

  ViolationType({required this.id, required this.name, this.severity});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'severity': severity};
  }

  factory ViolationType.fromMap(Map<String, dynamic> map) {
    return ViolationType(
      id: map['id'] as int,
      name: map['name'] as String,
      severity: map['severity'] as String?,
    );
  }

  @override
  String toString() {
    return 'ViolationType{id: $id, name: $name, severity: $severity}';
  }
}
