import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'success_screen.dart';

class ElderlyScreen extends StatelessWidget {
  const ElderlyScreen({super.key});

  // Mock Data
  static const String userName = "Uncle Tan";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Very light cream/off-white
      body: SafeArea(
        child: Column(
          children: [
            // TOP 35% - Identity Area
            Expanded(
              flex: 35,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 3D-style Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9800).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFFF9800),
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Speech Bubble
                    _buildSpeechBubble(context),
                  ],
                ),
              ),
            ),

            // BOTTOM 65% - Action Stream
            Expanded(
              flex: 65,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildActionCard(
                      context: context,
                      icon: Icons.account_balance_wallet,
                      title: 'Check Aid',
                      description: 'See your STR money',
                    ),
                    const SizedBox(height: 20),
                    _buildActionCard(
                      context: context,
                      icon: Icons.medical_services,
                      title: 'Health Info',
                      description: 'View medical records',
                    ),
                    const SizedBox(height: 20),
                    _buildActionCard(
                      context: context,
                      icon: Icons.phone_in_talk,
                      title: 'Call Guardian',
                      description: 'Contact your family',
                    ),
                    const SizedBox(height: 20),
                    _buildActionCard(
                      context: context,
                      icon: Icons.emergency,
                      title: 'Emergency',
                      description: 'Get help now',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$userName,',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Want to check STR money?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SuccessScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                // Huge Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    size: 60,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 24),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Massive YES Button
                _buildYesButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYesButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF9800),
            Color(0xFFFFB74D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SuccessScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 20,
            ),
            child: Text(
              'YES',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

