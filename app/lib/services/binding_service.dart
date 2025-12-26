import 'dart:math';
import '../models/dependent.dart';

/// Service for managing dependent bindings
/// Currently uses mock data - can be replaced with Supabase later
class BindingService {
  // Singleton pattern
  static final BindingService _instance = BindingService._internal();
  factory BindingService() => _instance;
  BindingService._internal();

  // Mock storage for bound dependents
  final List<Dependent> _boundDependents = [];

  // Mock storage for pending QR codes
  final Map<String, _QRBindingRequest> _pendingQRRequests = {};

  /// Get all bound dependents
  List<Dependent> get boundDependents => List.unmodifiable(_boundDependents);

  /// Simulate NFC card read - returns mock card data
  Future<Map<String, String>?> simulateNFCRead({bool isGuardian = false}) async {
    // Simulate NFC reading delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Return mock card data
    if (isGuardian) {
      return {
        'ic_number': '880101-10-5566',
        'full_name': 'Ahmad bin Ibrahim',
        'card_type': 'guardian',
      };
    } else {
      // Random senior data for demo
      final seniors = [
        {'ic_number': '450315-08-1234', 'full_name': 'Ng Boon Phooi'},
        {'ic_number': '520820-04-5678', 'full_name': 'Siti Aminah binti Hassan'},
        {'ic_number': '481105-02-9012', 'full_name': 'Rajendran a/l Krishnan'},
      ];
      return seniors[Random().nextInt(seniors.length)];
    }
  }

  /// Bind a new dependent via NFC
  Future<Dependent> bindViaNFC({
    required String seniorIC,
    required String seniorName,
    required String nickname,
  }) async {
    // Simulate backend save
    await Future.delayed(const Duration(milliseconds: 800));

    final dependent = Dependent(
      id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
      icNumber: seniorIC,
      fullName: seniorName,
      nickname: nickname,
      boundAt: DateTime.now(),
      bindingMethod: 'nfc',
    );

    _boundDependents.add(dependent);
    return dependent;
  }

  /// Generate a time-sensitive QR code for binding
  String generateBindingQRCode({
    required String seniorIC,
    required String seniorName,
  }) {
    final requestId = 'qr_${DateTime.now().millisecondsSinceEpoch}';
    final expiresAt = DateTime.now().add(const Duration(minutes: 5));

    _pendingQRRequests[requestId] = _QRBindingRequest(
      requestId: requestId,
      seniorIC: seniorIC,
      seniorName: seniorName,
      expiresAt: expiresAt,
      isAccepted: null,
    );

    // Return encoded QR data
    return 'JAGAID_BIND|$requestId|$seniorIC|$seniorName|${expiresAt.millisecondsSinceEpoch}';
  }

  /// Parse QR code data
  Map<String, String>? parseQRCode(String qrData) {
    try {
      if (!qrData.startsWith('JAGAID_BIND|')) return null;

      final parts = qrData.split('|');
      if (parts.length != 5) return null;

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[4]));
      if (DateTime.now().isAfter(expiresAt)) {
        return null; // Expired
      }

      return {
        'request_id': parts[1],
        'senior_ic': parts[2],
        'senior_name': parts[3],
      };
    } catch (e) {
      return null;
    }
  }

  /// Accept a binding request (called by senior)
  Future<void> acceptBindingRequest(String requestId) async {
    final request = _pendingQRRequests[requestId];
    if (request != null) {
      _pendingQRRequests[requestId] = _QRBindingRequest(
        requestId: request.requestId,
        seniorIC: request.seniorIC,
        seniorName: request.seniorName,
        expiresAt: request.expiresAt,
        isAccepted: true,
      );
    }
  }

  /// Deny a binding request (called by senior)
  Future<void> denyBindingRequest(String requestId) async {
    final request = _pendingQRRequests[requestId];
    if (request != null) {
      _pendingQRRequests[requestId] = _QRBindingRequest(
        requestId: request.requestId,
        seniorIC: request.seniorIC,
        seniorName: request.seniorName,
        expiresAt: request.expiresAt,
        isAccepted: false,
      );
    }
  }

  /// Complete QR binding (called by guardian after senior accepts)
  Future<Dependent?> completeQRBinding({
    required String requestId,
    required String nickname,
  }) async {
    final request = _pendingQRRequests[requestId];
    if (request == null || request.isAccepted != true) {
      return null;
    }

    // Simulate backend save
    await Future.delayed(const Duration(milliseconds: 800));

    final dependent = Dependent(
      id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
      icNumber: request.seniorIC,
      fullName: request.seniorName,
      nickname: nickname,
      boundAt: DateTime.now(),
      bindingMethod: 'qr',
    );

    _boundDependents.add(dependent);
    _pendingQRRequests.remove(requestId);

    return dependent;
  }

  /// Remove a bound dependent
  void removeDependent(String id) {
    _boundDependents.removeWhere((d) => d.id == id);
  }
}

class _QRBindingRequest {
  final String requestId;
  final String seniorIC;
  final String seniorName;
  final DateTime expiresAt;
  final bool? isAccepted;

  _QRBindingRequest({
    required this.requestId,
    required this.seniorIC,
    required this.seniorName,
    required this.expiresAt,
    required this.isAccepted,
  });
}
