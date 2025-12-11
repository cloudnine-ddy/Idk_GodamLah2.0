import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'success_screen.dart';
import 'guardian_screen.dart';
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
    if (AppGlobals.hasPendingAuth) {
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
    );
  }

  Future<void> _showExitDialog() async {
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
                  color: Colors.orange.withOpacity(0.1),
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
                  _getText(
                    'Stop Transaction?',
                    'Hentikan Transaksi?',
                    '停止交易？',
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
                'Are you sure you want to go back? Your progress will be lost.',
                'Adakah anda pasti mahu kembali? Kemajuan anda akan hilang.',
                '您确定要返回吗？您的进度将丢失。',
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
                backgroundColor: const Color(0xFFFF9800),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _getText('Yes, Go Back', 'Ya, Kembali', '是的，返回'),
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

  String _getGreeting() {
    if (_currentLanguage == 'ms') {
      return widget.profile.name.contains('Lin') ? 'Nenek' : 'Pakcik';
    } else if (_currentLanguage == 'zh') {
      return widget.profile.name.contains('Lin') ? '奶奶' : '叔叔';
    }
    return widget.profile.name.contains('Lin') ? 'Auntie' : 'Uncle';
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1,
                  size: 40,
                  color: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getText(
                  'Select Guardian to Authorize',
                  'Pilih Penjaga untuk Kebenaran',
                  '选择授权监护人',
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: _fontSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: [
            _buildGuardianOption(
              context,
              name: 'Son: Ali',
              nameMs: 'Anak: Ali',
              nameZh: '儿子：Ali',
              icon: Icons.man,
            ),
            _buildGuardianOption(
              context,
              name: 'Daughter: Mei',
              nameMs: 'Anak: Mei',
              nameZh: '女儿：Mei',
              icon: Icons.woman,
            ),
            _buildGuardianOption(
              context,
              name: 'Nephew: Muthu',
              nameMs: 'Anak Saudara: Muthu',
              nameZh: '侄子：Muthu',
              icon: Icons.person,
            ),
          ],
        );
      },
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
            // PART 1: AI Header (Fixed - Not scrollable)
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.28,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFF9800).withOpacity(0.9),
                    const Color(0xFFFFB74D).withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Inclusivity Toolbar + Home Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Home/Exit Button (Left)
                        Tooltip(
                          message: _getText('Exit', 'Keluar', '退出'),
                          child: Material(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: _showExitDialog,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 52,
                                height: 52,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.home_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Accessibility Toolbar + Delegate Button (Right)
                        Row(
                          children: [
                            _buildToolbarButton(
                              icon: 'Aa',
                              isActive: _isLargeFontMode,
                              onTap: _toggleFontSize,
                              tooltip: 'Large Font',
                            ),
                            const SizedBox(width: 8),
                            _buildToolbarButton(
                              icon: '👁️',
                              isActive: _isHighContrastMode,
                              onTap: _toggleContrast,
                              tooltip: 'High Contrast',
                            ),
                            const SizedBox(width: 8),
                            _buildToolbarButton(
                              icon: '🌐',
                              isActive: _currentLanguage != 'en',
                              onTap: _toggleLanguage,
                              tooltip: 'Language',
                            ),
                            const SizedBox(width: 12),
                            // Notification Bell Button
                            Tooltip(
                              message: _getText('Notifications', 'Pemberitahuan', '通知'),
                              child: Material(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: _handleNotificationTap,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        const Icon(
                                          Icons.notifications_outlined,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                        // Red Badge if there are notifications
                                        if (widget.profile.notificationMsg != null)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delegate Access Button
                            Tooltip(
                              message: _getText('Request Help', 'Minta Bantuan', '请求帮助'),
                              child: Material(
                                color: AppGlobals.hasPendingAuth
                                    ? const Color(0xFF4CAF50).withOpacity(0.9)
                                    : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                elevation: AppGlobals.hasPendingAuth ? 4 : 0,
                                child: InkWell(
                                  onTap: _showDelegateAccessDialog,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.person_add_alt_1,
                                      size: 24,
                                      color: AppGlobals.hasPendingAuth
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Avatar & Chat Bubble
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 3D Avatar with Processing Indicator
                          ScaleTransition(
                            scale: _isFilling
                                ? _avatarBounceAnimation
                                : const AlwaysStoppedAnimation(1.0),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.smart_toy,
                                      size: 60,
                                      color: const Color(0xFFFF9800),
                                    ),
                                  ),
                                ),
                                if (_isProcessing)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Dynamic Chat Bubble
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                _getAIMessage(),
                                style: GoogleFonts.poppins(
                                  fontSize: _fontSize(16),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PART 2: Interactive Content Area (Scrollable)
            Expanded(
              child: Container(
                color: _isHighContrastMode ? Colors.black : Colors.white,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _isComplete
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
                backgroundColor: const Color(0xFFFF9800),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_isListening || _isProcessing)
          // Listening/Processing State
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        curve: Curves.easeInOut,
                        width: 8,
                        height: 20 + (index % 2 == 0 ? 40 : 20),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _getText(
                    'Understood, checking STR...',
                    'Faham, menyemak STR...',
                    '明白了，检查STR...',
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: _fontSize(24),
                    fontWeight: FontWeight.bold,
                    color: _isHighContrastMode ? Colors.yellow : const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ),
          if (!_isListening && !_isProcessing) ...[
          // Voice Input Section
          const SizedBox(height: 20),
          Text(
            _getText('Voice Input', 'Input Suara', '语音输入'),
            style: GoogleFonts.poppins(
              fontSize: _fontSize(20),
              fontWeight: FontWeight.bold,
              color: _isHighContrastMode ? Colors.yellow : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: AnimatedBuilder(
              animation: _micPulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _micPulseAnimation.value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF9800),
                          Color(0xFFFFB74D),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _startAIFilling,
                        customBorder: const CircleBorder(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.mic,
                              size: 60,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getText('Speak', 'Cakap', '说话'),
                              style: GoogleFonts.poppins(
                                fontSize: _fontSize(14),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),

          // Manual Selection Section
          Text(
            _getText('Or Choose Service', 'Atau Pilih Perkhidmatan', '或选择服务'),
            style: GoogleFonts.poppins(
              fontSize: _fontSize(20),
              fontWeight: FontWeight.bold,
              color: _isHighContrastMode ? Colors.yellow : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Service Cards
          _buildServiceCard(
            icon: Icons.account_balance_wallet,
            title: _getText('Check STR Aid', 'Semak Bantuan STR', '检查STR援助'),
            description: _getText(
              'View your financial assistance',
              'Lihat bantuan kewangan anda',
              '查看您的经济援助',
            ),
            onTap: _startAIFilling,
          ),
          const SizedBox(height: 16),

          _buildServiceCard(
            icon: Icons.badge,
            title: _getText('Renew MyKad', 'Perbaharui MyKad', '更新身份证'),
            description: _getText(
              'Check renewal status',
              'Semak status pembaharuan',
              '检查更新状态',
            ),
            onTap: _startAIFilling,
          ),
          const SizedBox(height: 16),

          _buildServiceCard(
            icon: Icons.local_hospital,
            title: _getText('Madani Medical', 'Perubatan Madani', 'Madani医疗'),
            description: _getText(
              'Access health services',
              'Akses perkhidmatan kesihatan',
              '获取健康服务',
            ),
            onTap: _startAIFilling,
          ),
          const SizedBox(height: 20),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isHighContrastMode
              ? Colors.yellow.withOpacity(0.3)
              : const Color(0xFFFF9800).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 20),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: _fontSize(22),
                          fontWeight: FontWeight.bold,
                          color: _isHighContrastMode ? Colors.yellow : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: _fontSize(14),
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
                  Icons.arrow_forward_ios,
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
        Text(
          _getText('AI-Filled Form', 'Borang Diisi AI', 'AI填写的表格'),
          style: GoogleFonts.poppins(
            fontSize: _fontSize(24),
            fontWeight: FontWeight.bold,
            color: _isHighContrastMode ? Colors.yellow : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getText(
            'Review and edit if needed',
            'Semak dan ubah jika perlu',
            '检查并根据需要编辑',
          ),
          style: GoogleFonts.poppins(
            fontSize: _fontSize(14),
            color: _isHighContrastMode
                ? Colors.yellow.withOpacity(0.8)
                : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        _buildFormField(
          label: _getText('Full Name', 'Nama Penuh', '全名'),
          controller: _nameController,
          index: 0,
        ),
        const SizedBox(height: 16),

        _buildFormField(
          label: _getText('IC Number', 'No. KP', '身份证号码'),
          controller: _icController,
          index: 1,
        ),
        const SizedBox(height: 16),

        _buildFormField(
          label: _getText('Phone Number', 'No. Telefon', '电话号码'),
          controller: _phoneController,
          index: 2,
        ),
        const SizedBox(height: 16),

        _buildFormField(
          label: _getText('Bank Account', 'Akaun Bank', '银行账户'),
          controller: _bankController,
          index: 3,
        ),
        const SizedBox(height: 16),

        _buildFormField(
          label: _getText('Aid Type', 'Jenis Bantuan', '援助类型'),
          controller: _aidController,
          index: 4,
        ),
        const SizedBox(height: 100), // Space for floating button
        ],
      ),
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
                      color: isActive ? const Color(0xFFFF9800) : Colors.white,
                    ),
                  )
                : Text(
                    icon,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFFFF9800) : Colors.white,
                    ),
                  ),
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
            color: _isHighContrastMode ? Colors.yellow : const Color(0xFFFF9800),
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
                      color: const Color(0xFFFFD700).withOpacity(0.6),
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
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFFFD700),
                  width: isHighlighted ? 3 : 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isHighlighted
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFFFD700),
                  width: isHighlighted ? 3 : 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFF9800),
                  width: 3,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.auto_awesome,
                color: _isHighContrastMode ? Colors.yellow : const Color(0xFFFFD700),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
