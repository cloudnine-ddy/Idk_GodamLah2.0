import 'dart:math';
import '../models/villager.dart';
import '../models/field_transaction.dart';

/// Service for Field Agent Mode operations
/// Manages local roster, verification, and transaction caching
class FieldAgentService {
  // Singleton pattern
  static final FieldAgentService _instance = FieldAgentService._internal();
  factory FieldAgentService() => _instance;
  FieldAgentService._internal();

  // Local storage (in-memory for now, would use Hive/Isar in production)
  final List<Villager> _roster = [];
  final List<FieldTransaction> _pendingTransactions = [];
  DateTime? _lastSyncTime;
  bool _isSynced = false;

  // Getters
  List<Villager> get roster => List.unmodifiable(_roster);
  List<FieldTransaction> get pendingTransactions => 
      _pendingTransactions.where((t) => !t.isUploaded).toList();
  int get pendingCount => pendingTransactions.length;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSynced => _isSynced;
  int get rosterCount => _roster.length;

  // ============================================================================
  // Stage 1: Sync Daily Roster
  // ============================================================================
  
  /// Simulates downloading roster from server
  /// In production, this would fetch from API and store in Hive/Isar
  Future<void> syncRoster({
    required Function(int current, int total) onProgress,
  }) async {
    _roster.clear();
    
    // Generate 50 mock villagers
    final mockVillagers = _generateMockRoster();
    
    for (int i = 0; i < mockVillagers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      _roster.add(mockVillagers[i]);
      onProgress(i + 1, mockVillagers.length);
    }
    
    _lastSyncTime = DateTime.now();
    _isSynced = true;
  }

  List<Villager> _generateMockRoster() {
    final random = Random();
    final kampungs = [
      'Kampung Sungai Besar',
      'Kampung Parit Raja',
      'Kampung Tanjung Sepat',
      'Kampung Air Hitam',
      'Kampung Bukit Tinggi',
      'Kampung Jeram',
      'Kampung Kuala Selangor',
    ];
    
    final aidTypes = ['STR', 'BKM', 'BPPT', 'eKasih', 'BR1M'];
    
    final names = [
      'Ahmad Bin Abdullah', 'Siti Aminah Binti Hassan', 'Mohd Razak Bin Ismail',
      'Tan Ah Kow', 'Lim Mei Ling', 'Wong Chee Keong', 'Lee Siew Lan',
      'Muthu A/L Raman', 'Lakshmi A/P Krishnan', 'Subramaniam A/L Pillai',
      'Fatimah Binti Omar', 'Zainab Binti Ali', 'Kamariah Binti Yusof',
      'Ong Beng Huat', 'Ng Siew Mei', 'Chan Kok Leong', 'Goh Ah Seng',
      'Ramasamy A/L Muniandy', 'Devi A/P Gopal', 'Kumar A/L Selvam',
      'Roslan Bin Mohd', 'Noraini Binti Awang', 'Hasnah Binti Hashim',
      'Chong Wai Kuan', 'Yap Siew Fong', 'Teo Boon Keat', 'Koh Ah Lian',
      'Ganesh A/L Raju', 'Priya A/P Samy', 'Vijay A/L Nair',
      'Ibrahim Bin Kassim', 'Aminah Binti Daud', 'Hassan Bin Othman',
      'Liew Chee Meng', 'Foo Kah Wai', 'Sim Boon Hwa', 'Chia Siew Ting',
      'Sundaram A/L Veloo', 'Meena A/P Arumugam', 'Ravi A/L Suppiah',
      'Azizah Binti Zainal', 'Mariam Binti Ismail', 'Rafidah Binti Ahmad',
      'Ho Weng Fatt', 'Yeoh Siew Lin', 'Khoo Beng Soon', 'Ooi Ah Kow',
      'Bala A/L Krishnan', 'Shanti A/P Muthusamy', 'Mohan A/L Perumal',
    ];
    
    return List.generate(50, (index) {
      final name = names[index % names.length];
      return Villager(
        uuid: 'UUID-${(1000 + index).toString().padLeft(6, '0')}',
        name: name,
        publicKey: 'PK-${random.nextInt(999999).toString().padLeft(6, '0')}',
        kampung: kampungs[random.nextInt(kampungs.length)],
        aidType: aidTypes[random.nextInt(aidTypes.length)],
        icNumber: '${500000 + random.nextInt(400000)}-${10 + random.nextInt(90)}-${1000 + random.nextInt(9000)}',
      );
    });
  }

  // ============================================================================
  // Stage 2: Offline Verification
  // ============================================================================
  
  /// Simulates NFC card read and returns villager data
  /// In production, this would:
  /// 1. Read UUID from NFC
  /// 2. Generate nonce
  /// 3. Get signature from card
  /// 4. Verify signature using stored public key
  Future<Map<String, dynamic>?> simulateNFCVerification() async {
    if (_roster.isEmpty) {
      return {'error': 'No roster synced. Please sync first.'};
    }
    
    // Simulate NFC read delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Randomly pick a villager for simulation
    final random = Random();
    final villager = _roster[random.nextInt(_roster.length)];
    
    // Simulate verification (90% success rate)
    if (random.nextDouble() > 0.9) {
      return {
        'success': false,
        'error': 'Signature verification failed',
      };
    }
    
    return {
      'success': true,
      'villager': villager,
    };
  }

  /// Look up villager by UUID (for real NFC implementation)
  Villager? findVillagerByUuid(String uuid) {
    try {
      return _roster.firstWhere((v) => v.uuid == uuid);
    } catch (_) {
      return null;
    }
  }

  // ============================================================================
  // Stage 3: Action & Caching
  // ============================================================================
  
  /// Record an action for a villager
  Future<FieldTransaction> recordAction({
    required Villager villager,
    required String actionType,
    required String actionDetails,
  }) async {
    final transaction = FieldTransaction(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      villagerUuid: villager.uuid,
      villagerName: villager.name,
      actionType: actionType,
      actionDetails: actionDetails,
      timestamp: DateTime.now(),
      isUploaded: false,
    );
    
    _pendingTransactions.add(transaction);
    return transaction;
  }

  /// Upload pending transactions (when online)
  Future<int> uploadPendingTransactions({
    required Function(int current, int total) onProgress,
  }) async {
    final pending = pendingTransactions;
    if (pending.isEmpty) return 0;
    
    int uploadedCount = 0;
    
    for (int i = 0; i < pending.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Mark as uploaded
      final index = _pendingTransactions.indexOf(pending[i]);
      if (index != -1) {
        _pendingTransactions[index] = pending[i].copyWith(isUploaded: true);
        uploadedCount++;
      }
      
      onProgress(i + 1, pending.length);
    }
    
    return uploadedCount;
  }

  /// Get recent transactions for a villager
  List<FieldTransaction> getTransactionsForVillager(String uuid) {
    return _pendingTransactions
        .where((t) => t.villagerUuid == uuid)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Clear all data (for testing)
  void reset() {
    _roster.clear();
    _pendingTransactions.clear();
    _lastSyncTime = null;
    _isSynced = false;
  }
}
