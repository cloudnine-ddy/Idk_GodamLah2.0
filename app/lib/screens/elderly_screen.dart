import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'success_screen.dart';
import '../models/user_profile.dart';

class ElderlyScreen extends StatefulWidget {
  final UserProfile profile;

  const ElderlyScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ElderlyScreen> createState() => _ElderlyScreenState();
}

class _ElderlyScreenState extends State<ElderlyScreen> {
  // Accessibility Toggles - Initialize from profile
  late bool _isLargeFontMode;
  late bool _isHighContrastMode;
  late String _currentLanguage;

  // Text Controllers
  late TextEditingController _nameController;
  late TextEditingController _icController;
  late TextEditingController _phoneController;
  late TextEditingController _bankController;
  late TextEditingController _aidController;

  @override
  void initState() {
    super.initState();
    // Initialize from profile
    _isLargeFontMode = widget.profile.needsBigText;
    _isHighContrastMode = widget.profile.highContrast;
    _currentLanguage = widget.profile.languageCode;

    // Initialize controllers with profile data
    _nameController = TextEditingController(text: widget.profile.fullName);
    _icController = TextEditingController(text: widget.profile.icNumber);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _bankController = TextEditingController(text: widget.profile.bankAccount);
    _aidController = TextEditingController(text: widget.profile.aidType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _phoneController.dispose();
    _bankController.dispose();
    _aidController.dispose();
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

  double _fontSize(double baseSize) {
    return _isLargeFontMode ? baseSize * 1.5 : baseSize;
  }

  String _getText(String english, String malay, [String? chinese]) {
    if (_currentLanguage == 'ms') return malay;
    if (_currentLanguage == 'zh' && chinese != null) return chinese;
    return english;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isHighContrastMode ? Colors.black : const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Column(
          children: [
            // PART 1: AI Header (Top 30%, Fixed)
            Container(
              height: MediaQuery.of(context).size.height * 0.30,
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
                  // Inclusivity Toolbar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                          // 3D Avatar
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
                          const SizedBox(width: 16),

                          // Chat Bubble
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
                                _getText(
                                  'Uncle, I helped you fill this form. Please check ok?',
                                  'Pakcik, saya dah isi borang ini. Tolong semak ya?',
                                  '叔叔，我帮你填好表格了。请检查好吗？',
                                ),
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

            // PART 2: Smart Form (Bottom 70%, Scrollable)
            Expanded(
              child: Container(
                color: _isHighContrastMode ? Colors.black : Colors.white,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
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
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: _getText('IC Number', 'No. KP', '身份证号码'),
                      controller: _icController,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: _getText('Phone Number', 'No. Telefon', '电话号码'),
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: _getText('Bank Account', 'Akaun Bank', '银行账户'),
                      controller: _bankController,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: _getText('Aid Type', 'Jenis Bantuan', '援助类型'),
                      controller: _aidController,
                    ),
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // PART 3: Floating Action Bar
      floatingActionButton: Container(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
      child:         Material(
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
  }) {
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
        TextFormField(
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
              borderSide: const BorderSide(
                color: Color(0xFFFFD700), // Golden border
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFFFD700), // Golden border
                width: 2,
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
      ],
    );
  }
}
