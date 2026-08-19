import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class DesignerEditProfileScreen extends StatefulWidget {
  const DesignerEditProfileScreen({super.key});

  @override
  State<DesignerEditProfileScreen> createState() => _DesignerEditProfileScreenState();
}

class _DesignerEditProfileScreenState extends State<DesignerEditProfileScreen> {
  final String _initName = 'نوف الأحمدي';
  final String _initEmail = 'nouf@design.sa';
  final String _initPhone = '+966 xxxx xxx x5';
  final String _initCity = 'الرياض';
  final String _initBio = 'تخصصي في فساتين السهرة.';

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _bioCtrl;

  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _initName);
    _emailCtrl = TextEditingController(text: _initEmail);
    _phoneCtrl = TextEditingController(text: _initPhone);
    _cityCtrl = TextEditingController(text: _initCity);
    _bioCtrl = TextEditingController(text: _initBio);

    _nameCtrl.addListener(_checkModifications);
    _emailCtrl.addListener(_checkModifications);
    _phoneCtrl.addListener(_checkModifications);
    _cityCtrl.addListener(_checkModifications);
    _bioCtrl.addListener(_checkModifications);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _checkModifications() {
    final bool hasChanges = _nameCtrl.text != _initName ||
                            _emailCtrl.text != _initEmail ||
                            _phoneCtrl.text != _initPhone ||
                            _cityCtrl.text != _initCity ||
                            _bioCtrl.text != _initBio;
    
    if (_isModified != hasChanges) {
      setState(() => _isModified = hasChanges);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'تعديل الملف الشخصي',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark), 
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.3),
                            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.5), 
                          ),
                          child: const Icon(Icons.person_outline, size: 50, color: AppColors.textDark),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0, 
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _isModified = true); 
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E1B3D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.upload_outlined, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('الاسم'),
                  _buildGlassTextField(controller: _nameCtrl),

                  _buildSectionTitle('البريد الإلكتروني'),
                  _buildGlassTextField(controller: _emailCtrl, isEmail: true),

                  _buildSectionTitle('رقم الجوال'),
                  _buildGlassTextField(controller: _phoneCtrl, isPhone: true, textDirection: TextDirection.ltr), 

                  _buildSectionTitle('المدينة'),
                  _buildGlassTextField(controller: _cityCtrl),

                  _buildSectionTitle('النبذة'),
                  _buildGlassTextField(controller: _bioCtrl, maxLines: 3),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isModified ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حفظ التغييرات بنجاح!')),
                        );
                        Navigator.pop(context); 
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isModified 
                            ? const Color(0xFF4A3B52) 
                            : const Color.fromARGB(255, 175, 165, 175).withOpacity(0.4), 
                        disabledBackgroundColor: const Color.fromARGB(255, 175, 165, 175).withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: _isModified ? 4 : 0,
                      ),
                      child: Text(
                        'حفظ التغييرات', 
                        style: TextStyle(
                          color: _isModified ? Colors.white : Colors.white.withOpacity(0.7), 
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 12),
      child: Text(
        title, 
        style: const TextStyle(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller, 
    bool isEmail = false, 
    bool isPhone = false, 
    int maxLines = 1,
    TextDirection? textDirection,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: DesignerGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: TextField(
          controller: controller, 
          keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
          maxLines: maxLines,
          textDirection: textDirection, 
          textAlign: textDirection == TextDirection.ltr ? TextAlign.right : TextAlign.start,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }
}