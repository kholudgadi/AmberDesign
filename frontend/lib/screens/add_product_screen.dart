import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  
  bool _isButtonEnabled = false;
  final List<String> _images = [];

  String _selectedCategory = 'سهرة';
  final List<String> _categories = ['سهرة', 'زواج', 'حفلات', 'كاجوال', 'غريب', 'سواريه'];
  
  bool _hasSizes = false;
  bool _hasColors = false;
  bool _hasFabric = false;
  bool _hasLengths = false;
  bool _hasCustomSizes = false;
  bool _hasExtraQty = false;

  final Set<String> _selectedSizes = {};
  final List<String> _sizesList = ['XXL', 'XL', 'L', 'M', 'S', 'XS'];
  
  final Set<String> _selectedFabrics = {};
  final List<String> _fabricsList = ['حرير', 'ساتان', 'دانتيل', 'شيفون', 'كريب'];

  @override
  void initState() {
    super.initState();
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
                    _qtyCtrl.text.trim().isNotEmpty && 
                    _images.isNotEmpty; 
    
    if (_isButtonEnabled != isValid) {
      setState(() {
        _isButtonEnabled = isValid;
      });
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
                const Text(
                  'إضافة صورة للمنتج',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
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
      _images.add('https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=200&auto=format&fit=crop');
    });
    _checkValidation();
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
            'إضافة منتج',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.textDark), 
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
                      physics: const BouncingScrollPhysics(),
                      children: [
                        GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: _buildImageCircle(Icons.add, 'إضافة'),
                        ),
                        if (_images.isEmpty) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: _buildImageCircle(Icons.upload_outlined, ''),
                          ),
                        ],
                        ..._images.map((img) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16), 
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _buildImageCircle(Icons.image, '', imageUrl: img),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.remove(img);
                                      });
                                      _checkValidation(); 
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD32F2F),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('اسم المنتج'),
                  _buildGlassTextField('مثال: فستان سهرة ذهبي', controller: _nameCtrl),
                  
                  _buildSectionTitle('السعر (ر.س)'),
                  _buildGlassTextField('مثال: ٢٤٠٠', controller: _priceCtrl, isNumber: true),
                  
                  _buildSectionTitle('الكمية'),
                  _buildGlassTextField('مثال: ٥', controller: _qtyCtrl, isNumber: true),

                  _buildSectionTitle('الفئة'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((cat) => _buildCategoryPill(cat)).toList(),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('الوصف'),
                  _buildGlassTextField('وصف المنتج...', maxLines: 4),
                  const SizedBox(height: 32),

                  const Text('خصائص اختيارية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 16),

                  _buildOptionalToggle('إضافة المقاسات', _hasSizes, (val) => setState(() => _hasSizes = val)),
                  if (_hasSizes) _buildSizesSelector(),

                  _buildOptionalToggle('إضافة الألوان', _hasColors, (val) => setState(() => _hasColors = val)),
                  if (_hasColors) _buildSubGlassTextField('أسود، ذهبي...'),

                  _buildOptionalToggle('إضافة نوع القماش', _hasFabric, (val) => setState(() => _hasFabric = val)),
                  if (_hasFabric) _buildFabricsSelector(),

                  _buildOptionalToggle('إضافة الأطوال', _hasLengths, (val) => setState(() => _hasLengths = val)),
                  if (_hasLengths) _buildSubGlassTextField('أدخلي الأطوال (مثال: 52, 54, 56)'),

                  _buildOptionalToggle('مقاسات مخصصة', _hasCustomSizes, (val) => setState(() => _hasCustomSizes = val)),
                  if (_hasCustomSizes) _buildSubGlassTextField('ملاحظات للعميل (مثال: أرفقي محيط الخصر)'),

                  _buildOptionalToggle('إضافة الكمية', _hasExtraQty, (val) => setState(() => _hasExtraQty = val)),
                  if (_hasExtraQty) _buildSubGlassTextField('تفاصيل الكمية (مثال: 3 لارج، 2 ميديام)'),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إضافة المنتج بنجاح!')),
                        );
                        Navigator.pop(context); 
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonEnabled 
                            ? const Color(0xFF2E1B3D) 
                            : const Color.fromARGB(255, 175, 165, 175).withOpacity(0.5),
                        disabledBackgroundColor: const Color.fromARGB(255, 175, 165, 175).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: _isButtonEnabled ? 4 : 0,
                      ),
                      child: Text(
                        'حفظ المنتج', 
                        style: TextStyle(
                          color: _isButtonEnabled ? Colors.white : Colors.white.withOpacity(0.7), 
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
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGlassTextField(String hint, {TextEditingController? controller, bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: DesignerGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: TextField(
          controller: controller, 
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.6)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildSubGlassTextField(String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          style: const TextStyle(color: AppColors.textDark, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.6), fontSize: 13),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionalToggle(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DesignerGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        borderRadius: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14)),
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF2E1B3D),
              trackColor: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCircle(IconData icon, String label, {String? imageUrl}) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textMuted.withOpacity(0.5), width: 1, style: BorderStyle.solid),
        color: Colors.white.withOpacity(0.2),
        image: imageUrl != null 
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl != null 
          ? null 
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.textMuted, size: 28),
                if (label.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ]
              ],
            ),
    );
  }

  Widget _buildCategoryPill(String title) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E1B3D) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : AppColors.textMuted.withOpacity(0.3)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSizesSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _sizesList.map((size) {
          final isSelected = _selectedSizes.contains(size);
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected ? _selectedSizes.remove(size) : _selectedSizes.add(size);
              });
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF2E1B3D) : Colors.white.withOpacity(0.4),
                border: Border.all(color: isSelected ? Colors.transparent : AppColors.textMuted.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  size,
                  style: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFabricsSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _fabricsList.map((fabric) {
          final isSelected = _selectedFabrics.contains(fabric);
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected ? _selectedFabrics.remove(fabric) : _selectedFabrics.add(fabric);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? const Color(0xFF2E1B3D) : Colors.white.withOpacity(0.4),
                border: Border.all(color: isSelected ? Colors.transparent : AppColors.textMuted.withOpacity(0.2)),
              ),
              child: Text(
                fabric,
                style: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontSize: 13),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}