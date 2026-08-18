import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _qtyCtrl;
  
  bool _isButtonEnabled = true; 

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product['name']);
    _priceCtrl = TextEditingController(text: widget.product['price']);
    _qtyCtrl = TextEditingController(text: '٥'); 
    
    _nameCtrl.addListener(_checkValidation);
    _priceCtrl.addListener(_checkValidation);
    _qtyCtrl.addListener(_checkValidation);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _checkValidation() {
    final isValid = _nameCtrl.text.trim().isNotEmpty && 
                    _priceCtrl.text.trim().isNotEmpty && 
                    _qtyCtrl.text.trim().isNotEmpty;
    if (_isButtonEnabled != isValid) {
      setState(() => _isButtonEnabled = isValid);
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
          title: const Text('تعديل منتج', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
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
                  const Text('صور المنتج', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: NetworkImage(widget.product['image']), fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: 0, left: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.textMuted.withOpacity(0.5)),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(Icons.add, color: AppColors.textMuted, size: 28),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('اسم المنتج'),
                  _buildGlassTextField(controller: _nameCtrl),
                  
                  _buildSectionTitle('السعر (ر.س)'),
                  _buildGlassTextField(controller: _priceCtrl, isNumber: true),
                  
                  _buildSectionTitle('الكمية'),
                  _buildGlassTextField(controller: _qtyCtrl, isNumber: true),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعديل المنتج بنجاح!')));
                        Navigator.pop(context); 
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonEnabled ? const Color(0xFF2E1B3D) : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
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
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGlassTextField({required TextEditingController controller, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: DesignerGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: TextField(
          controller: controller, 
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: AppColors.textDark),
          decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
        ),
      ),
    );
  }
}