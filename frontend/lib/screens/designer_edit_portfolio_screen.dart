import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class DesignerEditPortfolioScreen extends StatefulWidget {
  const DesignerEditPortfolioScreen({super.key});

  @override
  State<DesignerEditPortfolioScreen> createState() => _DesignerEditPortfolioScreenState();
}

class _DesignerEditPortfolioScreenState extends State<DesignerEditPortfolioScreen> {
  final List<String> _initialImages = [
    'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1595958564246-88b17b62fb91?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1566160983226-e17ee96c21a4?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1515347619252-1d54fb3a0c5c?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?q=80&w=200&auto=format&fit=crop',
  ];
  final String _initialBio = 'تخصصي في فساتين السهرة.';
  final String _initialExp = 'أكثر من ١٠ سنوات';

  late List<String> _currentImages;
  late TextEditingController _bioCtrl;
  late String _currentExp;

  final List<String> _expOptions = ['أقل من ٢ سنوات', '٢-٥ سنوات', '٥-١٠ سنوات', 'أكثر من ١٠ سنوات'];

  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    _currentImages = List.from(_initialImages);
    _bioCtrl = TextEditingController(text: _initialBio);
    _currentExp = _initialExp;

    _bioCtrl.addListener(_checkModifications);
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  void _checkModifications() {
    bool hasChanges = _bioCtrl.text != _initialBio ||
                      _currentExp != _initialExp ||
                      _currentImages.length != _initialImages.length; 

    if (_isModified != hasChanges) {
      setState(() => _isModified = hasChanges);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('إضافة صورة للمحفظة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.photo_library_outlined, color: Color(0xFF2E1B3D)),
                  ),
                  title: const Text('اختيار من المعرض', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _simulateImageUpload();
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF388E3C)),
                  ),
                  title: const Text('التقاط بالكاميرا', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _simulateImageUpload();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _simulateImageUpload() {
    setState(() {
      _currentImages.add('https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=200&auto=format&fit=crop');
    });
    _checkModifications();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemSize = (screenWidth - 48 - 32) / 3;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('تعديل المحفظة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
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
                  const Text('صور الأعمال', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ..._currentImages.map((img) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: itemSize,
                              height: itemSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _currentImages.remove(img));
                                  _checkModifications();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Container(
                          width: itemSize,
                          height: itemSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(color: AppColors.textMuted.withOpacity(0.5), width: 1.5), 
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_outlined, color: AppColors.textMuted, size: 24),
                              const SizedBox(height: 4),
                              Text('رفع', style: TextStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.8))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text('النبذة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  DesignerGlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 20,
                    child: TextField(
                      controller: _bioCtrl,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        hintText: 'اكتبي نبذة عن أعمالك...',
                        hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.6)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text('سنوات الخبرة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _expOptions.map((exp) {
                      final isSelected = _currentExp == exp;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _currentExp = exp);
                          _checkModifications();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2E1B3D) : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.transparent : AppColors.textMuted.withOpacity(0.2)),
                          ),
                          child: Text(
                            exp,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textDark,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isModified ? () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث المحفظة بنجاح!')));
                        Navigator.pop(context); 
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isModified 
                            ? const Color(0xFF4A3B52) 
                            : const Color.fromARGB(255, 175, 165, 175).withOpacity(0.5), 
                        disabledBackgroundColor: const Color.fromARGB(255, 175, 165, 175).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: _isModified ? 4 : 0,
                      ),
                      child: Text(
                        'حفظ المحفظة', 
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
}