/// Model representing a cached field transaction
class FieldTransaction {
  final String id;
  final String villagerUuid;
  final String villagerName;
  final String actionType; // 'aid_distributed', 'status_update', etc.
  final String actionDetails;
  final DateTime timestamp;
  final bool isUploaded;

  const FieldTransaction({
    required this.id,
    required this.villagerUuid,
    required this.villagerName,
    required this.actionType,
    required this.actionDetails,
    required this.timestamp,
    this.isUploaded = false,
  });

  FieldTransaction copyWith({
    String? id,
    String? villagerUuid,
    String? villagerName,
    String? actionType,
    String? actionDetails,
    DateTime? timestamp,
    bool? isUploaded,
  }) {
    return FieldTransaction(
      id: id ?? this.id,
      villagerUuid: villagerUuid ?? this.villagerUuid,
      villagerName: villagerName ?? this.villagerName,
      actionType: actionType ?? this.actionType,
      actionDetails: actionDetails ?? this.actionDetails,
      timestamp: timestamp ?? this.timestamp,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }

  String get actionLabel {
    switch (actionType) {
      case 'aid_distributed':
        return 'Aid Distributed';
      case 'status_update':
        return 'Status Updated';
      case 'home_visit':
        return 'Home Visit Completed';
      default:
        return actionType;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'villagerUuid': villagerUuid,
    'villagerName': villagerName,
    'actionType': actionType,
    'actionDetails': actionDetails,
    'timestamp': timestamp.toIso8601String(),
    'isUploaded': isUploaded,
  };

  factory FieldTransaction.fromJson(Map<String, dynamic> json) => FieldTransaction(
    id: json['id'] as String,
    villagerUuid: json['villagerUuid'] as String,
    villagerName: json['villagerName'] as String,
    actionType: json['actionType'] as String,
    actionDetails: json['actionDetails'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isUploaded: json['isUploaded'] as bool? ?? false,
  );
}
