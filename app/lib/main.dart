import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/elderly_screen.dart';
import 'screens/guardian_screen.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing animation for the scanner icon
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _navigateToElderlyPath() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ElderlyScreen(),
      ),
    );
  }

  void _navigateToGuardianPath() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GuardianScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final halfHeight = size.height / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content (centered, non-interactive)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Breathing animated icon
                AnimatedBuilder(
                  animation: _breathingAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathingAnimation.value,
                      child: Icon(
                        Icons.sensors,
                        size: 120,
                        color: Colors.grey[300],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Instruction text
                Text(
                  'TAP ID CARD TO VERIFY',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
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
                splashColor: const Color(0xFFFF9800).withOpacity(0.1),
                highlightColor: const Color(0xFFFF9800).withOpacity(0.05),
                child: Container(
                  // Completely transparent
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
                splashColor: const Color(0xFF2196F3).withOpacity(0.1),
                highlightColor: const Color(0xFF2196F3).withOpacity(0.05),
                child: Container(
                  // Completely transparent
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

