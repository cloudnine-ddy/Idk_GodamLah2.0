/// Model for a bound dependent (senior that guardian can act on behalf of)
class Dependent {
  final String id;
  final String icNumber;
  final String fullName;
  final String nickname;
  final DateTime boundAt;
  final String bindingMethod; // 'nfc' or 'qr'

  Dependent({
    required this.id,
    required this.icNumber,
    required this.fullName,
    required this.nickname,
    required this.boundAt,
    required this.bindingMethod,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ic_number': icNumber,
    'full_name': fullName,
    'nickname': nickname,
    'bound_at': boundAt.toIso8601String(),
    'binding_method': bindingMethod,
  };

  factory Dependent.fromJson(Map<String, dynamic> json) => Dependent(
    id: json['id'],
    icNumber: json['ic_number'],
    fullName: json['full_name'],
    nickname: json['nickname'],
    boundAt: DateTime.parse(json['bound_at']),
    bindingMethod: json['binding_method'],
  );
}
