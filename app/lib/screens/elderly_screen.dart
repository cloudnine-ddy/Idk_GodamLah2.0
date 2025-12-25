import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'success_screen.dart';
import 'guardian_screen.dart';
import 'dashboard_screen.dart';
import '../models/user_profile.dart';
import '../utils/app_globals.dart';

class ElderlyScreen extends StatefulWidget {
  final UserProfile profile;

  const ElderlyScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ElderlyScreen> createState() => _ElderlyScreenState();
}

class _ElderlyScreenState extends State<ElderlyScreen>
    with TickerProviderStateMixin {
  // Accessibility Toggles - Initialize from profile
  late bool _isLargeFontMode;
  late bool _isHighContrastMode;
  late String _currentLanguage;

  // AI State Machine
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isFilling = false;
  bool _isComplete = false;

  // Animation Controllers
  late AnimationController _micPulseController;
  late AnimationController _avatarBounceController;
  late Animation<double> _micPulseAnimation;
  late Animation<double> _avatarBounceAnimation;

  // Text Controllers - Start empty
  late TextEditingController _nameController;
  late TextEditingController _icController;
  late TextEditingController _phoneController;
  late TextEditingController _bankController;
  late TextEditingController _aidController;

  // Field highlights
  final List<bool> _fieldHighlights = [false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    // Initialize from profile
    _isLargeFontMode = widget.profile.needsBigText;
    _isHighContrastMode = widget.profile.highContrast;
    _currentLanguage = widget.profile.languageCode;

    // Initialize controllers with EMPTY values
    _nameController = TextEditingController();
    _icController = TextEditingController();
    _phoneController = TextEditingController();
    _bankController = TextEditingController();
    _aidController = TextEditingController();

    // Microphone pulse animation
    _micPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _micPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _micPulseController,
      curve: Curves.easeInOut,
    ));

    // Avatar bounce animation
    _avatarBounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _avatarBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _avatarBounceController,
      curve: Curves.elasticOut,
    ));

    // Check for pending proxy authorization (Receiver Flow)
    _checkPendingAuth();
  }

  void _checkPendingAuth() {
    // Only show proxy request if there's a pending auth AND the current user is "Ali" (the guardian)
    if (AppGlobals.hasPendingAuth && widget.profile.name == 'Ali') {
      // Wait for screen to load, then show the proxy request dialog
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showProxyRequestDialog();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _phoneController.dispose();
    _bankController.dispose();
    _aidController.dispose();
    _micPulseController.dispose();
    _avatarBounceController.dispose();
    super.dispose();
  }

  void _toggleFontSize() {
    setState(() {
      _isLargeFontMode = !_isLargeFontMode;
    });
  }

  void _toggleContrast() {
    setState(() {
      _isHighContrastMode = !_isHighContrastMode;
    });
  }

  void _toggleLanguage() {
    setState(() {
      // Cycle through languages: en -> ms -> zh -> en
      if (_currentLanguage == 'en') {
        _currentLanguage = 'ms';
      } else if (_currentLanguage == 'ms') {
        _currentLanguage = 'zh';
      } else {
        _currentLanguage = 'en';
      }
    });
  }

  void _submitForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SuccessScreen(),
      ),
    ).then((_) {
      // Reset form state when returning from success screen
      setState(() {
        _isComplete = false;
        _isFilling = false;
        _isListening = false;
        _isProcessing = false;
        _nameController.clear();
        _icController.clear();
        _phoneController.clear();
        _bankController.clear();
        _aidController.clear();
        _fieldHighlights.fillRange(0, 5, false);
      });
    });
  }

  Future<void> _showExitDialog() async {
    // If form is being filled or complete, just reset to service selection
    if (_isFilling || _isComplete) {
      setState(() {
        _isComplete = false;
        _isFilling = false;
        _isListening = false;
        _isProcessing = false;
        _nameController.clear();
        _icController.clear();
        _phoneController.clear();
        _bankController.clear();
        _aidController.clear();
        _fieldHighlights.fillRange(0, 5, false);
      });
      return; // Don't show dialog, just reset
    }

    // Only show exit dialog if at initial service selection view
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF1565C0),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _getText(
                    'Exit to Home?',
                    'Keluar ke Utama?',
                    '退出到主页？',
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: _fontSize(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _getText(
                'Return to the home screen?',
                'Kembali ke skrin utama?',
                '返回主屏幕？',
              ),
              style: GoogleFonts.poppins(
                fontSize: _fontSize(14),
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                _getText('Cancel', 'Batal', '取消'),
                style: GoogleFonts.poppins(
                  fontSize: _fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _getText('Yes, Exit', 'Ya, Keluar', '是的，退出'),
                style: GoogleFonts.poppins(
                  fontSize: _fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.all(16),
        );
      },
    );

    if (shouldExit == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showProxyRequestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF1976D2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.vpn_key_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  '🔑 Proxy Request Received',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: _fontSize(22),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2196F3).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF2196F3),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppGlobals.pendingAuthName,
                          style: GoogleFonts.poppins(
                            fontSize: _fontSize(18),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _getText(
                    '${AppGlobals.pendingAuthName} has authorized you to manage their account.',
                    '${AppGlobals.pendingAuthName} telah memberikan anda kebenaran untuk mengurus akaun mereka.',
                    '${AppGlobals.pendingAuthName} 已授权您管理他们的账户。',
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: _fontSize(15),
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      _getText('Ignore', 'Abaikan', '忽略'),
                      style: GoogleFonts.poppins(
                        fontSize: _fontSize(16),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      _acceptProxyRequest();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getText('ACCEPT & SWITCH', 'TERIMA & TUKAR', '接受并切换'),
                          style: GoogleFonts.poppins(
                            fontSize: _fontSize(14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }

  void _acceptProxyRequest() {
    // Switch to Guardian Screen using pushReplacement
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GuardianScreen(
          profile: widget.profile,
        ),
      ),
    );
  }

  void _handleNotificationTap() {
    if (widget.profile.notificationMsg == null) {
      // No notifications
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getText(
              'No new notifications',
              'Tiada pemberitahuan baru',
              '没有新通知',
            ),
            style: GoogleFonts.poppins(
              fontSize: _fontSize(14),
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show notification dialog
      _showNotificationDialog();
    }
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.2),
                  Colors.red.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF9800),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _getText('Important', 'Penting', '重要通知'),
                    style: GoogleFonts.poppins(
                      fontSize: _fontSize(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF9800).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: Color(0xFFFF9800),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.profile.notificationMsg!,
                          style: GoogleFonts.poppins(
                            fontSize: _fontSize(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _getText('Later', 'Kemudian', '稍后'),
                      style: GoogleFonts.poppins(
                        fontSize: _fontSize(16),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      _handleRenewNow();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getText('RENEW NOW', 'PERBAHARUI SEKARANG', '立即更新'),
                          style: GoogleFonts.poppins(
                            fontSize: _fontSize(14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }

  void _handleRenewNow() {
    // Trigger the AI Ghost Typing animation for renewal
    // This simulates clicking the "Renew MyKad" service card
    _startAIFilling();
  }

  double _fontSize(double baseSize) {
    return _isLargeFontMode ? baseSize * 1.5 : baseSize;
  }

  String _getText(String english, String malay, [String? chinese]) {
    if (_currentLanguage == 'ms') return malay;
    if (_currentLanguage == 'zh' && chinese != null) return chinese;
    return english;
  }

  Future<void> _startAIFilling() async {
    // Step 1: Listening
    setState(() {
      _isListening = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));

    // Step 2: Processing
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 3: Sequential Filling
    setState(() {
      _isProcessing = false;
      _isFilling = true;
    });

    // Fill fields one by one
    await _fillField(0, _nameController, widget.profile.fullName);
    await _fillField(1, _icController, widget.profile.icNumber);
    await _fillField(2, _phoneController, widget.profile.phoneNumber);
    await _fillField(3, _bankController, widget.profile.bankAccount);
    await _fillField(4, _aidController, widget.profile.aidType);

    // Complete
    setState(() {
      _isFilling = false;
      _isComplete = true;
    });
  }

  Future<void> _fillField(
    int index,
    TextEditingController controller,
    String value,
  ) async {
    // Highlight the field
    setState(() {
      _fieldHighlights[index] = true;
    });

    // Bounce avatar
    _avatarBounceController.forward(from: 0);

    // Ghost typing effect
    for (int i = 0; i <= value.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      controller.text = value.substring(0, i);
    }

    await Future.delayed(const Duration(milliseconds: 300));

    // Remove highlight
    setState(() {
      _fieldHighlights[index] = false;
    });

    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _showDelegateAccessDialog() {
    // Navigate to Dashboard (Delegate Mode) for binding and managing dependents
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DashboardScreen(profile: widget.profile),
      ),
    );
  }

  Widget _buildGuardianOption(
    BuildContext context, {
    required String name,
    required String nameMs,
    required String nameZh,
    required IconData icon,
  }) {
    final displayName = _currentLanguage == 'ms'
        ? nameMs
        : _currentLanguage == 'zh'
            ? nameZh
            : name;

    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context);
        _authorizeGuardian(displayName);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFF9800),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                displayName,
                style: GoogleFonts.poppins(
                  fontSize: _fontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _authorizeGuardian(String guardianName) {
    // Set global state
    AppGlobals.hasPendingAuth = true;
    AppGlobals.selectedGuardianName = guardianName;
    AppGlobals.pendingAuthName = widget.profile.name; // Set the elderly person's name

    // Show success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getText(
                  'Access Key Sent!',
                  'Kunci Akses Dihantar!',
                  '访问密钥已发送！',
                ),
                style: GoogleFonts.poppins(
                  fontSize: _fontSize(22),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getText(
                  '$guardianName can now manage your account.',
                  '$guardianName kini boleh mengurus akaun anda.',
                  '$guardianName 现在可以管理您的账户。',
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: _fontSize(14),
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getText('OK', 'OK', '好的'),
                  style: GoogleFonts.poppins(
                    fontSize: _fontSize(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isHighContrastMode ? Colors.black : const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Column(
          children: [
            // PART 1: Compact Professional Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1565C0),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Bar: Branding + Accessibility Toolbar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: JagaID Branding + Home
                      Row(
                        children: [
                          // Home/Exit Button
                          Material(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: _showExitDialog,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // JagaID Branding
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.verified_user,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'JagaID',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Right: Pill-shaped Accessibility Toolbar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCompactToolbarButton(
                              icon: Icons.text_fields,
                              isActive: _isLargeFontMode,
                              onTap: _toggleFontSize,
                            ),
                            _buildCompactToolbarButton(
                              icon: Icons.contrast,
                              isActive: _isHighContrastMode,
                              onTap: _toggleContrast,
                            ),
                            _buildCompactToolbarButton(
                              icon: Icons.language,
                              isActive: _currentLanguage != 'en',
                              onTap: _toggleLanguage,
                              label: _currentLanguage == 'ms' ? 'BM' : _currentLanguage == 'zh' ? '中' : null,
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: Colors.white.withOpacity(0.3),
                            ),
                            // Notification
                            _buildCompactToolbarButton(
                              icon: Icons.notifications_outlined,
                              isActive: false,
                              onTap: _handleNotificationTap,
                              hasBadge: widget.profile.notificationMsg != null,
                            ),
                            // Delegate
                            _buildCompactToolbarButton(
                              icon: Icons.person_add_alt_1,
                              isActive: AppGlobals.hasPendingAuth,
                              onTap: _showDelegateAccessDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Assistant Message Card (Below header, on white background)
            Container(
              width: double.infinity,
              color: _isHighContrastMode ? Colors.black : Colors.white,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isHighContrastMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHighContrastMode 
                        ? Colors.yellow.withOpacity(0.3)
                        : const Color(0xFF1565C0).withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: _isHighContrastMode ? [] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Small icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ScaleTransition(
                        scale: _isFilling
                            ? _avatarBounceAnimation
                            : const AlwaysStoppedAnimation(1.0),
                        child: Stack(
                          children: [
                            Icon(
                              Icons.support_agent,
                              size: 28,
                              color: _isHighContrastMode ? Colors.yellow : const Color(0xFF1565C0),
                            ),
                            if (_isProcessing)
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Message text
                    Expanded(
                      child: Text(
                        _getAIMessage(),
                        style: GoogleFonts.poppins(
                          fontSize: _fontSize(14),
                          fontWeight: FontWeight.w500,
                          color: _isHighContrastMode ? Colors.yellow : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PART 2: Interactive Content Area (Scrollable)
            Expanded(
              child: Container(
                color: _isHighContrastMode ? Colors.black : Colors.white,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: (_isFilling || _isComplete)
                      ? _buildFilledForm()
                      : _buildMicrophoneArea(),
                ),
              ),
            ),
          ],
        ),
      ),

      // PART 3: Floating Confirm Button (Only when complete)
      floatingActionButton: _isComplete
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FloatingActionButton.extended(
                onPressed: _submitForm,
                backgroundColor: const Color(0xFF1565C0),
                elevation: 8,
                icon: const Icon(
                  Icons.check_circle,
                  size: 32,
                  color: Colors.white,
                ),
                label: Text(
                  _getText('CONFIRM & SUBMIT', 'SAHKAN & HANTAR', '确认并提交'),
                  style: GoogleFonts.poppins(
                    fontSize: _fontSize(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getAIMessage() {
    if (_isListening) {
      return _getText(
        'Understood, checking STR...',
        'Faham, menyemak STR...',
        '明白了，检查STR...',
      );
    } else if (_isProcessing) {
      return _getText(
        'Processing your details...',
        'Memproses maklumat anda...',
        '处理您的详细信息...',
      );
    } else if (_isFilling) {
      return _getText(
        'Filling in your form...',
        'Mengisi borang anda...',
        '填写您的表格...',
      );
    } else if (_isComplete) {
      return _getText(
        'All done! Please check and press Confirm.',
        'Siap! Sila semak dan tekan Sahkan.',
        '完成！请检查并按确认。',
      );
    } else {
      return _getText(
        'Hello! Tap a button below OR press the Mic to speak.',
        'Hello! Tekan butang di bawah ATAU tekan Mic untuk bercakap.',
        '你好！点击下面的按钮或按麦克风说话。',
      );
    }
  }

  Widget _buildMicrophoneArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (_isListening || _isProcessing)
            // Listening/Processing State
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeInOut,
                          width: 6,
                          height: 16 + (index % 2 == 0 ? 32 : 16),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getText(
                      'Processing...',
                      'Memproses...',
                      '处理中...',
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: _fontSize(16),
                      fontWeight: FontWeight.w600,
                      color: _isHighContrastMode ? Colors.yellow : const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          if (!_isListening && !_isProcessing) ...[
            // Microphone Section - Clean centered design
            const SizedBox(height: 32),
            Center(
              child: AnimatedBuilder(
                animation: _micPulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulse ring
                      Container(
                        width: 120 * _micPulseAnimation.value,
                        height: 120 * _micPulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1565C0).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      // Main mic button
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1565C0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1565C0).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _startAIFilling,
                            customBorder: const CircleBorder(),
                            child: const Icon(
                              Icons.mic,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getText('Tap to speak', 'Ketuk untuk bercakap', '点击说话'),
              style: GoogleFonts.poppins(
                fontSize: _fontSize(14),
                fontWeight: FontWeight.w500,
                color: _isHighContrastMode ? Colors.yellow.withOpacity(0.7) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // OR Divider
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: _isHighContrastMode ? Colors.yellow.withOpacity(0.3) : Colors.grey[300],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _getText('OR', 'ATAU', '或'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isHighContrastMode ? Colors.yellow.withOpacity(0.7) : Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: _isHighContrastMode ? Colors.yellow.withOpacity(0.3) : Colors.grey[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Service Cards - Clean list style
            _buildServiceCard(
              icon: Icons.account_balance_wallet_outlined,
              title: _getText('Check STR Aid', 'Semak Bantuan STR', '检查STR援助'),
              description: _getText(
                'View your financial assistance',
                'Lihat bantuan kewangan anda',
                '查看您的经济援助',
              ),
              onTap: _startAIFilling,
            ),
            const SizedBox(height: 12),

            _buildServiceCard(
              icon: Icons.badge_outlined,
              title: _getText('Renew MyKad', 'Perbaharui MyKad', '更新身份证'),
              description: _getText(
                'Check renewal status',
                'Semak status pembaharuan',
                '检查更新状态',
              ),
              onTap: _startAIFilling,
            ),
            const SizedBox(height: 12),

            _buildServiceCard(
              icon: Icons.local_hospital_outlined,
              title: _getText('Madani Medical', 'Perubatan Madani', 'Madani医疗'),
              description: _getText(
                'Access health services',
                'Akses perkhidmatan kesihatan',
                '获取健康服务',
              ),
              onTap: _startAIFilling,
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _isHighContrastMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: _isHighContrastMode ? Colors.yellow : const Color(0xFF1565C0),
            width: 4,
          ),
        ),
        boxShadow: _isHighContrastMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF1565C0).withOpacity(0.1),
          highlightColor: const Color(0xFF1565C0).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon
                Icon(
                  icon,
                  size: 28,
                  color: _isHighContrastMode ? Colors.yellow : const Color(0xFF1565C0),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: _fontSize(15),
                          fontWeight: FontWeight.w600,
                          color: _isHighContrastMode ? Colors.yellow : Colors.black87,
                        ),
                      ),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: _fontSize(12),
                          color: _isHighContrastMode
                              ? Colors.yellow.withOpacity(0.7)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: _isHighContrastMode
                      ? Colors.yellow.withOpacity(0.5)
                      : Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilledForm() {
    return Column(
      children: [
        // Blue Tab Header (like Pemohon/Pasangan/etc)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isHighContrastMode ? Colors.grey[900] : const Color(0xFFE3F2FD),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF1565C0).withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFormTab('Pemohon', isActive: true),
                _buildFormTab('Pasangan'),
                _buildFormTab('Tanggungan'),
                _buildFormTab('Dokumen'),
              ],
            ),
          ),
        ),

        // Form Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner (Blue light background with bullet points)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isHighContrastMode 
                      ? Colors.blue.withOpacity(0.2) 
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF1565C0).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoBullet(
                      _getText(
                        'Your STR aid application details',
                        'Butiran permohonan bantuan STR anda',
                        '您的STR援助申请详情',
                      ),
                      isHeader: true,
                    ),
                    const SizedBox(height: 4),
                    _buildInfoBullet(
                      _isFilling 
                          ? _getText('AI is filling your form...', 'AI sedang mengisi borang...', 'AI正在填写表格...')
                          : _getText('Please verify all information', 'Sila sahkan semua maklumat', '请核实所有信息'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Section: Personal Info
              _buildSectionTitle(_getText('Personal Information', 'Maklumat Peribadi', '个人信息')),
              const SizedBox(height: 12),

              // MyKad Number (Full width)
              _buildGovFormField(
                label: _getText('* No. MyKad', '* No. MyKad', '* 身份证号码'),
                controller: _icController,
                index: 1,
              ),
              const SizedBox(height: 12),

              // Name (Full width)
              _buildGovFormField(
                label: _getText('* Nama / Name', '* Nama', '* 姓名'),
                controller: _nameController,
                index: 0,
              ),
              const SizedBox(height: 12),

              // Phone Number
              _buildGovFormField(
                label: _getText('* No. Telefon Bimbit', '* No. Telefon Bimbit', '* 手机号码'),
                controller: _phoneController,
                index: 2,
              ),
              const SizedBox(height: 20),

              // Form Section: Bank Info
              _buildSectionTitle(_getText('Bank Information', 'Maklumat Bank', '银行信息')),
              const SizedBox(height: 12),

              // Bank Name
              _buildGovFormField(
                label: _getText('* Nama Bank', '* Nama Bank', '* 银行名称'),
                controller: _bankController,
                index: 3,
                isDropdown: true,
              ),
              const SizedBox(height: 12),

              // Aid Type
              _buildGovFormField(
                label: _getText('* Jenis Bantuan / Aid Type', '* Jenis Bantuan', '* 援助类型'),
                controller: _aidController,
                index: 4,
              ),

              const SizedBox(height: 100), // Space for floating button
            ],
          ),
        ),
      ],
    );
  }

  // Government-style form tab
  Widget _buildFormTab(String title, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF1565C0) 
            : Colors.transparent,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: _fontSize(12),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive 
              ? Colors.white 
              : (_isHighContrastMode ? Colors.yellow : const Color(0xFF1565C0)),
        ),
      ),
    );
  }

  // Info bullet point
  Widget _buildInfoBullet(String text, {bool isHeader = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            color: _isHighContrastMode ? Colors.yellow : const Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: _fontSize(isHeader ? 13 : 12),
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
              color: _isHighContrastMode ? Colors.yellow : const Color(0xFF1565C0),
            ),
          ),
        ),
      ],
    );
  }

  // Section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: _fontSize(14),
        fontWeight: FontWeight.bold,
        color: _isHighContrastMode ? Colors.yellow : const Color(0xFF1565C0),
      ),
    );
  }

  // Government-style form field
  Widget _buildGovFormField({
    required String label,
    required TextEditingController controller,
    required int index,
    bool isDropdown = false,
  }) {
    final isHighlighted = _fieldHighlights[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above field
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: _fontSize(12),
            fontWeight: FontWeight.w500,
            color: _isHighContrastMode ? Colors.yellow : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        // Input field
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.poppins(
              fontSize: _fontSize(14),
              color: _isHighContrastMode ? Colors.yellow : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: _isHighContrastMode
                  ? Colors.grey[900]
                  : const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: isHighlighted
                      ? const Color(0xFF1565C0)
                      : Colors.grey[300]!,
                  width: isHighlighted ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: isHighlighted
                      ? const Color(0xFF1565C0)
                      : Colors.grey[300]!,
                  width: isHighlighted ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: Color(0xFF1565C0),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: isDropdown 
                  ? Icon(
                      Icons.arrow_drop_down,
                      color: _isHighContrastMode ? Colors.yellow : Colors.grey[600],
                    )
                  : (isHighlighted 
                      ? const Icon(Icons.auto_awesome, color: Color(0xFF1565C0), size: 18)
                      : null),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarButton({
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        elevation: isActive ? 4 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: icon == '🌐' && _currentLanguage != 'en'
                ? Text(
                    _currentLanguage == 'ms' ? 'BM' : '中',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF1565C0) : Colors.white,
                    ),
                  )
                : Text(
                    icon,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF1565C0) : Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // New compact toolbar button for pill-shaped accessibility bar
  Widget _buildCompactToolbarButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    String? label,
    bool hasBadge = false,
  }) {
    return Material(
      color: isActive ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (label != null)
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF1565C0) : Colors.white,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? const Color(0xFF1565C0) : Colors.white,
                ),
              if (hasBadge)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required int index,
  }) {
    final isHighlighted = _fieldHighlights[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: _fontSize(14),
            fontWeight: FontWeight.w600,
            color: _isHighContrastMode ? Colors.yellow : const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.poppins(
              fontSize: _fontSize(16),
              color: _isHighContrastMode ? Colors.yellow : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: _isHighContrastMode
                  ? Colors.grey[900]
                  : const Color(0xFFFFF8F0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isHighlighted
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF1976D2),
                  width: isHighlighted ? 3 : 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isHighlighted
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF1976D2),
                  width: isHighlighted ? 3 : 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF1565C0),
                  width: 3,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.auto_awesome,
                color: _isHighContrastMode ? Colors.yellow : const Color(0xFF1976D2),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
