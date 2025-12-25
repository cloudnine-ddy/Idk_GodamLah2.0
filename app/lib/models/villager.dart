/// Model representing a villager in the field agent roster
class Villager {
  final String uuid;
  final String name;
  final String publicKey;
  final String kampung;
  final String aidType;
  final String icNumber;

  const Villager({
    required this.uuid,
    required this.name,
    required this.publicKey,
    required this.kampung,
    required this.aidType,
    required this.icNumber,
  });

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'publicKey': publicKey,
    'kampung': kampung,
    'aidType': aidType,
    'icNumber': icNumber,
  };

  factory Villager.fromJson(Map<String, dynamic> json) => Villager(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    publicKey: json['publicKey'] as String,
    kampung: json['kampung'] as String,
    aidType: json['aidType'] as String,
    icNumber: json['icNumber'] as String,
  );
}
