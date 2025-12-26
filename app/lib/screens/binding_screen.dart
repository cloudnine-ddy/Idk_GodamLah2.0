import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../services/binding_service.dart';
import '../models/dependent.dart';

class BindingScreen extends StatefulWidget {
  const BindingScreen({super.key});

  @override
  State<BindingScreen> createState() => _BindingScreenState();
}

class _BindingScreenState extends State<BindingScreen>
    with TickerProviderStateMixin {
  final BindingService _bindingService = BindingService();

  // State
  int _currentStep = 0; // 0=method, 1=role(QR)/auth(NFC), 2=qr-display/scan/senior-tap, 3=nickname, 4=success
  String _selectedMethod = ''; // 'nfc' or 'qr'
  String _selectedRole = ''; // 'guardian' or 'senior' (for QR)
  bool _isProcessing = false;
  String? _seniorIC;
  String? _seniorName;
  final TextEditingController _nicknameController = TextEditingController();

  // QR specific state
  String? _qrCodeData;
  int _qrCountdownSeconds = 300; // 5 minutes
  Timer? _countdownTimer;
  bool _isScanning = false;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nicknameController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Bind New Dependent',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: _handleBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressBar(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFF1565C0),
      child: Row(
        children: [
          _buildProgressDot(0, 'Method'),
          _buildProgressLine(0),
          _buildProgressDot(1, 'Your ID'),
          _buildProgressLine(1),
          _buildProgressDot(2, "Senior's ID"),
          _buildProgressLine(2),
          _buildProgressDot(3, 'Nickname'),
        ],
      ),
    );
  }

  Widget _buildProgressDot(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: isCurrent ? 32 : 24,
            height: isCurrent ? 32 : 24,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
            ),
            child: Center(
              child: isActive && _currentStep > step
                  ? const Icon(Icons.check, color: Color(0xFF1565C0), size: 16)
                  : Text(
                      '${step + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? const Color(0xFF1565C0) : Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(int afterStep) {
    final isComplete = _currentStep > afterStep;
    return Container(
      width: 20,
      height: 2,
      color: isComplete ? Colors.white : Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildMethodSelection();
      case 1:
        // Step 1: Role selection for QR, Guardian Auth for NFC
        if (_selectedMethod == 'qr') {
          return _buildRoleSelection();
        } else {
          return _buildGuardianAuth();
        }
      case 2:
        // Step 2: QR display/scan for QR, Senior tap for NFC
        if (_selectedMethod == 'qr') {
          if (_selectedRole == 'senior') {
            return _buildQRCodeDisplay();
          } else {
            return _buildQRScanner();
          }
        } else {
          return _buildSeniorTap();
        }
      case 3:
        return _buildNicknameEntry();
      case 4:
        return _buildSuccess();
      default:
        return const SizedBox();
    }
  }

  // ============================================================================
  // STEP 0: Method Selection
  // ============================================================================
  Widget _buildMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Binding Method',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How would you like to bind a new dependent?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),

        // NFC Option
        _buildMethodCard(
          icon: Icons.contactless,
          title: 'NFC Binding',
          subtitle: 'Tap both cards to bind locally',
          description: 'Quick and secure. Both you and the senior need to tap your Smart ID cards.',
          method: 'nfc',
          color: const Color(0xFF1565C0),
        ),
        const SizedBox(height: 16),

        // QR Option
        _buildMethodCard(
          icon: Icons.qr_code_scanner,
          title: 'QR Code Binding',
          subtitle: 'Scan to bind remotely',
          description: 'For when you\'re not physically together. Senior generates a code for you to scan.',
          method: 'qr',
          color: const Color(0xFF7B1FA2),
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String method,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _selectedMethod = method;
              _currentStep = 1;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 40, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // STEP 1 (QR): Role Selection - Are you Guardian or Senior?
  // ============================================================================
  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who are you?',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF7B1FA2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your role in this binding process',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),

        // Guardian Option
        _buildRoleCard(
          icon: Icons.shield_outlined,
          title: 'I am a Guardian',
          subtitle: 'I want to help a senior',
          description: 'Scan the QR code shown on the senior\'s phone to bind them.',
          role: 'guardian',
          color: const Color(0xFF1565C0),
        ),
        const SizedBox(height: 16),

        // Senior Option
        _buildRoleCard(
          icon: Icons.elderly,
          title: 'I am a Senior',
          subtitle: 'I need a guardian to help me',
          description: 'Generate a QR code for your guardian to scan and bind.',
          role: 'senior',
          color: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String role,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _selectedRole = role;
              _currentStep = 2;
              if (role == 'senior') {
                _generateQRCode();
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 40, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _generateQRCode() {
    // Generate QR code data
    _qrCodeData = _bindingService.generateBindingQRCode(
      seniorIC: '650515-08-1234', // Mock data
      seniorName: 'Demo Senior',
    );
    
    // Start countdown timer
    _qrCountdownSeconds = 300;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_qrCountdownSeconds > 0) {
        setState(() {
          _qrCountdownSeconds--;
        });
      } else {
        timer.cancel();
        // QR expired, regenerate
        _generateQRCode();
      }
    });
  }

  // ============================================================================
  // STEP 2 (QR - Senior): Display QR Code with countdown
  // ============================================================================
  Widget _buildQRCodeDisplay() {
    final minutes = _qrCountdownSeconds ~/ 60;
    final seconds = _qrCountdownSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Show this QR Code',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let your guardian scan this code to bind',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),

        // QR Code Container
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Simulated QR Code (since we can't use qr_flutter without adding package)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFF9800), width: 4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // QR pattern simulation
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 10,
                      ),
                      itemCount: 100,
                      itemBuilder: (context, index) {
                        // Create a pseudo-random pattern based on QR data
                        final hash = (_qrCodeData?.hashCode ?? 0) + index;
                        final isBlack = hash % 3 != 0;
                        return Container(
                          margin: const EdgeInsets.all(1),
                          color: isBlack ? Colors.black : Colors.white,
                        );
                      },
                    ),
                    // Center logo
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Color(0xFFFF9800),
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Countdown Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _qrCountdownSeconds < 60
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: _qrCountdownSeconds < 60
                          ? Colors.red
                          : const Color(0xFFFF9800),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expires in: $timeString',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _qrCountdownSeconds < 60
                            ? Colors.red
                            : const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Waiting for scan message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Waiting for guardian to scan...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Simulate binding button (for demo)
        TextButton(
          onPressed: () {
            _countdownTimer?.cancel();
            setState(() {
              _seniorIC = '650515-08-1234';
              _seniorName = 'Demo Senior';
              _currentStep = 4; // Skip to success for senior
            });
          },
          child: Text(
            'Simulate: Guardian scanned successfully',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // STEP 2 (QR - Guardian): Scan QR Code
  // ============================================================================
  Widget _buildQRScanner() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Scan QR Code',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Point your camera at the QR code on the senior\'s phone',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),

        // Camera viewfinder simulation
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF1565C0),
              width: 3,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera preview placeholder
              if (!_isScanning)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Preview',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              
              // Scanning animation
              if (_isScanning)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Scanning...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

              // Scan frame corners
              Positioned(
                top: 40,
                left: 40,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF1565C0), width: 4),
                      left: BorderSide(color: Color(0xFF1565C0), width: 4),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF1565C0), width: 4),
                      right: BorderSide(color: Color(0xFF1565C0), width: 4),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 40,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1565C0), width: 4),
                      left: BorderSide(color: Color(0xFF1565C0), width: 4),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                right: 40,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1565C0), width: 4),
                      right: BorderSide(color: Color(0xFF1565C0), width: 4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Start scanning button
        if (!_isScanning)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _startScanning,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(
                'Start Scanning',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

        if (_isScanning)
          Text(
            'Position QR code within the frame',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Future<void> _startScanning() async {
    HapticFeedback.mediumImpact();
    setState(() => _isScanning = true);

    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      HapticFeedback.heavyImpact();
      // Simulate successful scan
      setState(() {
        _isScanning = false;
        _seniorIC = '650515-08-1234';
        _seniorName = 'Lin Mei Hua';
        _currentStep = 3; // Go to nickname entry
      });
    }
  }

  // ============================================================================
  // STEP 1 (NFC): Guardian Authentication
  // ============================================================================
  Widget _buildGuardianAuth() {
    return GestureDetector(
      onTap: _isProcessing ? null : _simulateGuardianTap,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Authenticate Yourself',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isProcessing 
                ? 'Reading card...'
                : 'Tap anywhere to simulate card tap',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _isProcessing ? const Color(0xFF1565C0) : Colors.grey[600],
              fontWeight: _isProcessing ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 48),

          // NFC Tap Animation - Tappable
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1565C0).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1565C0),
                  ),
                  child: _isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.contactless,
                          size: 60,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Hint text
          if (!_isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFF1565C0), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tap anywhere',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _simulateGuardianTap() async {
    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = true);

    final cardData = await _bindingService.simulateNFCRead(isGuardian: true);

    if (cardData != null && mounted) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isProcessing = false;
        _currentStep = 2;
      });
    }
  }

  // ============================================================================
  // STEP 2: Senior Card Tap (NFC Tap Simulation)
  // ============================================================================
  Widget _buildSeniorTap() {
    return GestureDetector(
      onTap: _isProcessing ? null : _simulateSeniorTap,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Success badge for guardian
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4CAF50)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Your identity verified',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            "Now Tap Senior's Card",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isProcessing
                ? "Reading senior's card..."
                : 'Tap anywhere to simulate card tap',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _isProcessing ? const Color(0xFFFF9800) : Colors.grey[600],
              fontWeight: _isProcessing ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 48),

          // NFC Tap Animation (different color for senior) - Tappable
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF9800).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFFFF9800).withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF9800),
                  ),
                  child: _isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.elderly,
                          size: 60,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Hint text
          if (!_isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFFFF9800), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tap anywhere',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _simulateSeniorTap() async {
    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = true);

    final cardData = await _bindingService.simulateNFCRead(isGuardian: false);

    if (cardData != null && mounted) {
      HapticFeedback.mediumImpact();
      setState(() {
        _seniorIC = cardData['ic_number'];
        _seniorName = cardData['full_name'];
        _isProcessing = false;
        _currentStep = 3;
      });
    }
  }

  // ============================================================================
  // STEP 3: Nickname Entry
  // ============================================================================
  Widget _buildNicknameEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Senior info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1565C0).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _seniorName ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    Text(
                      'IC: ${_seniorIC ?? 'Unknown'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Give a Nickname',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps you identify them quickly (e.g., "Grandma Lin", "Uncle Ahmad")',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        // Nickname input
        TextField(
          controller: _nicknameController,
          style: GoogleFonts.poppins(fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Enter nickname...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
            prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF1565C0)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
        const SizedBox(height: 24),

        // Quick suggestions
        Text(
          'Suggestions:',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSuggestionChip('Grandma'),
            _buildSuggestionChip('Grandpa'),
            _buildSuggestionChip('Mum'),
            _buildSuggestionChip('Dad'),
            _buildSuggestionChip('Uncle'),
            _buildSuggestionChip('Auntie'),
          ],
        ),
        const SizedBox(height: 32),

        // Complete button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _completeBinding,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: Text(
              _isProcessing ? 'Saving...' : 'Complete Binding',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        _nicknameController.text = text;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Future<void> _completeBinding() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a nickname',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    await _bindingService.bindViaNFC(
      seniorIC: _seniorIC!,
      seniorName: _seniorName!,
      nickname: _nicknameController.text.trim(),
    );

    if (mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isProcessing = false;
        _currentStep = 4;
      });
    }
  }

  // ============================================================================
  // STEP 4: Success
  // ============================================================================
  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 48),

        // Success animation
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4CAF50).withOpacity(0.1),
          ),
          child: const Icon(
            Icons.check_circle,
            size: 80,
            color: Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Binding Successful!',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can now act on behalf of',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        // Bound dependent card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.elderly,
                  size: 32,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nicknameController.text,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _seniorName ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Done button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true to indicate success
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Done',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleBack() {
    if (_currentStep == 0 || _currentStep == 4) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _currentStep--;
        _isProcessing = false;
      });
    }
  }
}
