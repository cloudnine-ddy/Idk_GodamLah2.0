import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/elderly_screen.dart';
import 'screens/guardian_screen.dart';
import 'models/user_profile.dart';

void main() {
  runApp(const JagaIDApp());
}

class JagaIDApp extends StatelessWidget {
  const JagaIDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JagaID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  // Current User Profile
  UserProfile currentProfile = UserProfile.mockProfiles[0];

  @override
  void initState() {
    super.initState();

    // Pulse animation for the shield icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Wave animation for radio waves
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _navigateToElderlyPath() {
    HapticFeedback.mediumImpact(); // Haptic feedback for "card tap"
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ElderlyScreen(profile: currentProfile),
      ),
    );
  }

  void _loadProfile(int index) {
    setState(() {
      currentProfile = UserProfile.mockProfiles[index];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.person,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              'Profile Loaded: ${currentProfile.name}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToGuardianPath() {
    HapticFeedback.mediumImpact(); // Haptic feedback for "card tap"
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GuardianScreen(profile: currentProfile),
      ),
    );
  }

  Future<void> _handleMyDigitalIDLogin() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Connecting to MyDigital ID App...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate 2-second handshake delay
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    if (mounted) {
      Navigator.of(context).pop();

      // Navigate to Elderly Screen (Path A) with current profile
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ElderlyScreen(profile: currentProfile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final halfHeight = size.height / 2;

    return Scaffold(
      body: Stack(
        children: [
          // Professional Blue Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D47A1), // Deep navy blue
                  Color(0xFF1565C0), // Official blue
                  Color(0xFF1976D2), // Lighter blue
                ],
              ),
            ),
          ),

          // Subtle pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: CircuitPatternPainter(),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Header Section
                          const SizedBox(height: 40),
                          _buildHeader(),

                          // Central Scanning Area
                          Expanded(
                            child: Center(
                              child: _buildScanningArea(),
                            ),
                          ),

                          // Instruction & Footer
                          _buildFooter(),
                          const SizedBox(height: 20),

                          // MyDigital ID Button
                          _buildMyDigitalIDButton(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // INVISIBLE TOP HALF - Elderly Path
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: halfHeight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _navigateToElderlyPath,
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          // INVISIBLE BOTTOM HALF - Guardian Path
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: halfHeight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _navigateToGuardianPath,
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          // Profile Switcher (ON TOP - Last child in Stack)
          SafeArea(
            child: Positioned(
              top: 8,
              right: 8,
              child: _buildProfileSwitcher(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo/Shield Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.verified_user,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Official Title
        Text(
          'JagaID',
          style: GoogleFonts.poppins(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Malaysia Digital Identity Access',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildScanningArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Radio Wave Animation with Shield
        SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated Radio Waves (3 layers)
              AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildWave(1 - _waveAnimation.value, 0.0),
                      _buildWave(1 - _waveAnimation.value, 0.33),
                      _buildWave(1 - _waveAnimation.value, 0.66),
                    ],
                  );
                },
              ),

              // Center Shield with Pulse
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue[300]!.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        size: 80,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Scanning Text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4CAF50),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Secure Verification Terminal',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWave(double opacity, double delay) {
    final adjustedOpacity = (opacity - delay).clamp(0.0, 1.0);
    final scale = 1.0 + (1.0 - adjustedOpacity) * 2;

    if (adjustedOpacity <= 0) return const SizedBox.shrink();

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue[200]!.withOpacity(adjustedOpacity * 0.5),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Main Instruction
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Tap JagaID card on the back of this device to begin.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Footer Note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Official Government Initiative (Mock Pilot)',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyDigitalIDButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: OutlinedButton.icon(
        onPressed: _handleMyDigitalIDLogin,
        icon: const Icon(
          Icons.fingerprint,
          size: 24,
          color: Colors.white,
        ),
        label: Text(
          'Log in with MyDigital ID',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildProfileSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: PopupMenuButton<int>(
        icon: const Icon(
          Icons.person_pin,
          color: Colors.white,
          size: 28,
        ),
        tooltip: 'Switch Profile (Demo)',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 0,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentProfile.name == 'Uncle Tan'
                        ? const Color(0xFF4CAF50)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Load Uncle Tan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Default • English',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentProfile.name == 'Grandma Lin'
                        ? const Color(0xFF4CAF50)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Load Grandma Lin',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 14, color: Color(0xFFFFD700)),
                      ],
                    ),
                    Text(
                      'Chinese • Big Text',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentProfile.name == 'Uncle Muthu'
                        ? const Color(0xFF4CAF50)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Load Uncle Muthu',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'High Contrast Mode',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        onSelected: _loadProfile,
      ),
    );
  }
}

// Custom Painter for Circuit Pattern
class CircuitPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw some circuit-like lines
    for (int i = 0; i < 20; i++) {
      final y = (size.height / 20) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    for (int i = 0; i < 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




