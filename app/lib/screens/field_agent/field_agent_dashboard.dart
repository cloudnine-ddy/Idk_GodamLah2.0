import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/field_agent_service.dart';
import '../../models/villager.dart';
import 'villager_profile_screen.dart';

/// Field Agent Dashboard - Professional dark-themed interface for government officers
class FieldAgentDashboard extends StatefulWidget {
  const FieldAgentDashboard({super.key});

  @override
  State<FieldAgentDashboard> createState() => _FieldAgentDashboardState();
}

class _FieldAgentDashboardState extends State<FieldAgentDashboard>
    with TickerProviderStateMixin {
  final FieldAgentService _service = FieldAgentService();

  // UI State
  bool _isSyncing = false;
  bool _isScanning = false;
  int _syncProgress = 0;
  int _syncTotal = 50;

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Colors - Professional Dark Theme
  static const Color _primaryDark = Color(0xFF0D1B2A);
  static const Color _secondaryDark = Color(0xFF1B263B);
  static const Color _accentTeal = Color(0xFF0EA5E9);
  static const Color _warningAmber = Color(0xFFF59E0B);
  static const Color _successGreen = Color(0xFF10B981);
  static const Color _dangerRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSyncSection(),
                      const SizedBox(height: 24),
                      _buildScanButton(),
                      const SizedBox(height: 24),
                      _buildPendingUploadsSection(),
                      const SizedBox(height: 24),
                      _buildQuickStats(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _secondaryDark,
        border: Border(
          bottom: BorderSide(
            color: _accentTeal.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield,
              color: _accentTeal,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIELD AGENT MODE',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Officer: Encik Ahmad',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Stage 1: Sync Section
  // ============================================================================
  Widget _buildSyncSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _secondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _service.isSynced
              ? _successGreen.withOpacity(0.5)
              : _accentTeal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sync,
                color: _service.isSynced ? _successGreen : _accentTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'SYNC STATUS',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _service.isSynced
                        ? _successGreen.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _service.isSynced ? Icons.check_circle : Icons.cloud_off,
                    color: _service.isSynced ? _successGreen : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _service.isSynced
                            ? '✅ Ready for Field'
                            : 'Not Synced',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _service.isSynced
                            ? '${_service.rosterCount} Records | Last: ${_formatTime(_service.lastSyncTime)}'
                            : 'Sync to download roster',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress or Sync Button
          const SizedBox(height: 16),
          if (_isSyncing)
            Column(
              children: [
                LinearProgressIndicator(
                  value: _syncProgress / _syncTotal,
                  backgroundColor: _primaryDark,
                  valueColor: const AlwaysStoppedAnimation<Color>(_accentTeal),
                ),
                const SizedBox(height: 8),
                Text(
                  'Downloading... $_syncProgress / $_syncTotal',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _accentTeal,
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _syncRoster,
                icon: const Icon(Icons.cloud_download),
                label: Text(
                  _service.isSynced ? 'Re-Sync Roster' : 'Sync Daily Roster',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--';
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $amPm';
  }

  Future<void> _syncRoster() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSyncing = true;
      _syncProgress = 0;
    });

    await _service.syncRoster(
      onProgress: (current, total) {
        setState(() {
          _syncProgress = current;
          _syncTotal = total;
        });
      },
    );

    if (mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isSyncing = false;
      });
    }
  }

  // ============================================================================
  // Stage 2: Scan Button
  // ============================================================================
  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _service.isSynced && !_isScanning ? _scanVillagerID : null,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _service.isSynced
                ? [const Color(0xFF1E40AF), const Color(0xFF3B82F6)]
                : [Colors.grey[800]!, Colors.grey[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _service.isSynced
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            ScaleTransition(
              scale: _service.isSynced && !_isScanning
                  ? _pulseAnimation
                  : const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: _isScanning
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : Icon(
                          Icons.contactless,
                          size: 48,
                          color: _service.isSynced
                              ? Colors.white
                              : Colors.grey[500],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isScanning ? 'Scanning...' : '🔵 Scan Villager ID',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _service.isSynced
                  ? _isScanning
                      ? 'Hold card near device'
                      : 'Tap to verify villager via NFC'
                  : 'Sync roster first to enable',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanVillagerID() async {
    HapticFeedback.mediumImpact();
    setState(() => _isScanning = true);

    final result = await _service.simulateNFCVerification();

    if (mounted) {
      setState(() => _isScanning = false);

      if (result?['success'] == true) {
        HapticFeedback.heavyImpact();
        final villager = result!['villager'] as Villager;
        
        // Navigate to villager profile
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VillagerProfileScreen(villager: villager),
          ),
        ).then((_) {
          setState(() {}); // Refresh pending count
        });
      } else {
        _showVerificationFailed(result?['error'] ?? 'Unknown error');
      }
    }
  }

  void _showVerificationFailed(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _secondaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error, color: _dangerRed),
            const SizedBox(width: 12),
            Text(
              'Verification Failed',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          error,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: _accentTeal),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Stage 3: Pending Uploads
  // ============================================================================
  Widget _buildPendingUploadsSection() {
    final pendingCount = _service.pendingCount;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _secondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: pendingCount > 0
            ? Border.all(color: _warningAmber.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pendingCount > 0
                  ? _warningAmber.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.cloud_upload,
              color: pendingCount > 0 ? _warningAmber : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pendingCount > 0
                      ? '⚠️ Pending Uploads: $pendingCount'
                      : 'No Pending Uploads',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  pendingCount > 0
                      ? 'Connect to internet to sync'
                      : 'All actions synced',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (pendingCount > 0)
            IconButton(
              onPressed: () {
                // Show pending queue - could expand to full screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$pendingCount transactions waiting to upload'),
                    backgroundColor: _warningAmber,
                  ),
                );
              },
              icon: const Icon(Icons.chevron_right, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            value: _service.rosterCount.toString(),
            label: 'Roster',
            color: _accentTeal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            value: _service.pendingTransactions.where((t) => t.isUploaded).length.toString(),
            label: 'Completed',
            color: _successGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending,
            value: _service.pendingCount.toString(),
            label: 'Pending',
            color: _warningAmber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _secondaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
