class PollingStation {
  final int id;
  final String name;
  final String zone;
  final String province;

  PollingStation({
    required this.id,
    required this.name,
    required this.zone,
    required this.province,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'zone': zone, 'province': province};
  }

  factory PollingStation.fromMap(Map<String, dynamic> map) {
    return PollingStation(
      id: map['id'] as int,
      name: map['name'] as String,
      zone: map['zone'] as String,
      province: map['province'] as String,
    );
  }

  @override
  String toString() {
    return 'PollingStation{id: $id, name: $name, zone: $zone, province: $province}';
  }
}
