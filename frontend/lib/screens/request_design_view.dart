import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class RequestDesignView extends StatefulWidget {
  const RequestDesignView({super.key});

  @override
  State<RequestDesignView> createState() => _RequestDesignViewState();
}

class _RequestDesignViewState extends State<RequestDesignView> {
  // 1. جعلناه Nullable (يعني في البداية لا أزياء ولا ديكور محدد)
  bool? isFashion;

  // --- متغيرات حفظ التحديد (أزياء) - كلها تبدأ بـ null ---
  String? selectedDressType;
  String? selectedSize;
  String? selectedColor;
  String? selectedFabric;
  String? selectedLength;

  // --- متغيرات حفظ التحديد (ديكور) - كلها تبدأ بـ null ---
  String? selectedProjectType;
  String? selectedStyle;
  String? selectedBudget;
  String? selectedArea;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // أزرار التبديل الأساسية (أزياء / ديكور)
        _buildToggleButtons(),
        const SizedBox(height: 32),

        // 2. إخفاء باقي الشاشة حتى يتم اختيار قسم
        if (isFashion != null) ...[
          // عرض الخيارات بناءً على التحديد
          if (isFashion == true)
            _buildFashionOptions()
          else
            _buildInteriorOptions(),

          const SizedBox(height: 24),

          // حقل التفاصيل الإضافية
          const Text(
            'تفاصيل إضافية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailsField(),
          const SizedBox(height: 24),

          // رفع الملفات المرجعية
          const Text(
            'رفع ملفات مرجعية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildUploadBox(),
          const SizedBox(height: 32),

          // زر التالي
          _buildNextButton(),
          const SizedBox(height: 40),
        ] else ...[
          // رسالة ترحيبية تظهر قبل اختيار القسم
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Text(
                'الرجاء اختيار القسم للبدء في طلب التصميم',
                style: TextStyle(
                  color: AppColors.textMuted.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---- الويدجتس الفرعية ----

  Widget _buildToggleButtons() {
    return Row(
      children: [
        // زر ديكور
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isFashion = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), // حركة ناعمة
              height: 50,
              decoration: BoxDecoration(
                color: isFashion == false
                    ? AppColors.textDark
                    // لون الخلفية اللي اخترته للوضع غير المحدد
                    : const Color.fromRGBO(217, 217, 217, 1).withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isFashion == false
                      ? AppColors.textDark
                      // لون الحدود اللي اخترته للوضع غير المحدد
                      : AppColors.textDark.withOpacity(0.15),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'ديكور',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFashion == false
                      ? Colors.white
                      : AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16), // 💡 المسافة المطلوبة بين الزرين
        
        // زر أزياء
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isFashion = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), // حركة ناعمة
              height: 50,
              decoration: BoxDecoration(
                color: isFashion == true
                    ? AppColors.textDark
                    // لون الخلفية اللي اخترته للوضع غير المحدد
                    : const Color.fromRGBO(217, 217, 217, 1).withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isFashion == true
                      ? AppColors.textDark
                      // لون الحدود اللي اخترته للوضع غير المحدد
                      : AppColors.textDark.withOpacity(0.15),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'أزياء',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFashion == true
                      ? Colors.white
                      : AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- خيارات الأزياء ---
  Widget _buildFashionOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectionGroup(
          'نوع الفستان',
          [
            'فستان سهرة',
            'فستان زواج',
            'فستان حفل',
            'فستان كاجوال',
            'بدلة رسمية',
            'عباءة',
            'تنورة',
            'سواريه',
          ],
          selectedDressType,
          (val) => setState(() => selectedDressType = val),
        ),
        const SizedBox(height: 24),
        const Text(
          'المحددات',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        _buildSelectionGroup(
          'المقاس',
          ['XS', 'S', 'M', 'L', 'XL', 'حسب الطلب'],
          selectedSize,
          (val) => setState(() => selectedSize = val),
        ),
        _buildSelectionGroup(
          'اللون',
          ['أبيض', 'أسود', 'أحمر', 'ذهبي', 'بيج', 'حسب الطلب'],
          selectedColor,
          (val) => setState(() => selectedColor = val),
        ),
        _buildSelectionGroup(
          'القماش',
          ['حرير', 'ساتان', 'دانتيل', 'شيفون', 'حسب الطلب'],
          selectedFabric,
          (val) => setState(() => selectedFabric = val),
        ),
        _buildSelectionGroup(
          'الطول',
          ['طويل', 'متوسط', 'قصير'],
          selectedLength,
          (val) => setState(() => selectedLength = val),
        ),
      ],
    );
  }

  // --- خيارات الديكور ---
  Widget _buildInteriorOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectionGroup(
          'نوع المشروع',
          [
            'غرفة نوم',
            'غرفة معيشة',
            'مطبخ',
            'مكتب',
            'حمام',
            'فيلا كاملة',
            'شقة كاملة',
            'تصميم خارجي',
          ],
          selectedProjectType,
          (val) => setState(() => selectedProjectType = val),
        ),
        const SizedBox(height: 24),
        const Text(
          'تفاصيل المشروع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        _buildSelectionGroup(
          'الأسلوب',
          ['عصري', 'كلاسيكي', 'بوهيمي', 'مينيمالستي', 'فاخر', 'عربي أصيل'],
          selectedStyle,
          (val) => setState(() => selectedStyle = val),
        ),
        _buildSelectionGroup(
          'الميزانية',
          ['أقل من 10000', '10000-30000', '30000-60000', 'أكثر من 60000'],
          selectedBudget,
          (val) => setState(() => selectedBudget = val),
        ),
        _buildSelectionGroup(
          'المساحة',
          ['أقل من 20 م²', '20-50 م²', '50-100 م²', 'أكثر من 100 م²'],
          selectedArea,
          (val) => setState(() => selectedArea = val),
        ),
      ],
    );
  }

  // --- 3. تعديل الدالة لقبول القيم الفارغة (String?) ---
  Widget _buildSelectionGroup(
    String title,
    List<String> options,
    String? selectedValue,
    Function(String) onSelect,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: options.map((option) {
              final isSelected =
                  option == selectedValue; // إذا كان null ماراح يساوي أي خيار
              return GestureDetector(
                onTap: () => onSelect(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.textDark
                        : const Color.fromRGBO(
                            217,
                            217,
                            217,
                            1,
                          ).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.textDark
                          : AppColors.textDark.withOpacity(0.12),
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: TextField(
            maxLines: 4,
            style: const TextStyle(color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: isFashion == true
                  ? 'صفي طلبك — المناسبة، اللون المفضل، أي تفاصيل خاصة...'
                  : 'صفي المساحة والأسلوب المطلوب وأي تفاصيل مهمة...',
              hintStyle: TextStyle(
                color: AppColors.textMuted.withOpacity(0.7),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textMuted.withOpacity(0.5),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.upload_file, color: AppColors.textDark, size: 32),
          const SizedBox(height: 8),
          const Text(
            'اضغطي لرفع الملفات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            'PDF, PNG, JPG',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // سيتم برمجة الانتقال لصفحة الدفع لاحقاً
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: const Text(
          'التالي',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}