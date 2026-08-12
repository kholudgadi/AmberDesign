import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/global_data.dart';
import '../screens/order_review_screen.dart';

/// Adaptive request form for fashion and interior-design services.
class RequestDesignView extends StatefulWidget {
  const RequestDesignView({super.key});

  @override
  State<RequestDesignView> createState() => _RequestDesignViewState();
}

class _RequestDesignViewState extends State<RequestDesignView> {
  // `null` means no category is selected; `true` selects fashion and `false` selects interior design.
  bool? isFashion;

  // Stores the options selected for a fashion design request.
  String? selectedDressType;
  String? selectedSize;
  String? selectedColor;
  String? selectedFabric;
  String? selectedLength;

  // Stores the options selected for an interior design request.
  String? selectedProjectType;
  String? selectedStyle;
  String? selectedArea;
  // Budget input was removed based on the current requirement.

  @override
  Widget build(BuildContext context) {
    // Reveals only the fields that apply to the selected design category.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleButtons(),
        const SizedBox(height: 32),

        if (isFashion != null) ...[
          if (isFashion == true)
            _buildFashionOptions()
          else
            _buildInteriorOptions(),

          const SizedBox(height: 24),

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

          _buildNextButton(), // Renders the action button that proceeds to review.
          const SizedBox(height: 40),
        ] else ...[
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

  Widget _buildToggleButtons() {
    // Updates the category state and animates the active option.
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            // Selects the interior-design form and rebuilds the visible fields.
            onTap: () => setState(() => isFashion = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              decoration: BoxDecoration(
                color: isFashion == false
                    ? AppColors.textDark
                    : const Color.fromRGBO(217, 217, 217, 1).withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isFashion == false
                      ? AppColors.textDark
                      : AppColors.textDark.withOpacity(0.15),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'ديكور',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFashion == false ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: GestureDetector(
            // Selects the fashion-design form and rebuilds the visible fields.
            onTap: () => setState(() => isFashion = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              decoration: BoxDecoration(
                color: isFashion == true
                    ? AppColors.textDark
                    : const Color.fromRGBO(217, 217, 217, 1).withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isFashion == true
                      ? AppColors.textDark
                      : AppColors.textDark.withOpacity(0.15),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'أزياء',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFashion == true ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFashionOptions() {
    // Collects specifications that are unique to a fashion design request.
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

  Widget _buildInteriorOptions() {
    // Collects specifications that are unique to an interior design request.
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
          'المساحة',
          ['أقل من 20 م²', '20-50 م²', '50-100 م²', 'أكثر من 100 م²'],
          selectedArea,
          (val) => setState(() => selectedArea = val),
        ),
        // Budget input is intentionally omitted for this flow.
      ],
    );
  }

  Widget _buildSelectionGroup(
    String title,
    List<String> options,
    String? selectedValue,
    Function(String) onSelect,
  ) {
    // Reusable selectable-chip group that reports the choice through its callback.
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
              final isSelected = option == selectedValue;
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
    // Provides free-form context that cannot be captured by the predefined options.
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
    // Placeholder upload affordance for reference images or other files.
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
          List<Map<String, String>> collectedDetails = [];

          if (isFashion == true) {
            collectedDetails.add({
              'title': 'نوع التصميم',
              'value': 'تصميم أزياء',
            });
            if (selectedDressType != null) {
              collectedDetails.add({
                'title': 'نوع الطلب',
                'value': selectedDressType!,
              });
            }
            if (selectedSize != null) {
              collectedDetails.add({'title': 'المقاس', 'value': selectedSize!});
            }
            if (selectedColor != null) {
              collectedDetails.add({'title': 'اللون', 'value': selectedColor!});
            }
            if (selectedFabric != null) {
              collectedDetails.add({
                'title': 'القماش',
                'value': selectedFabric!,
              });
            }
            if (selectedLength != null) {
              collectedDetails.add({
                'title': 'الطول',
                'value': selectedLength!,
              });
            }
          } else if (isFashion == false) {
            collectedDetails.add({
              'title': 'نوع التصميم',
              'value': 'تصميم داخلي (ديكور)',
            });
            if (selectedProjectType != null) {
              collectedDetails.add({
                'title': 'نوع المشروع',
                'value': selectedProjectType!,
              });
            }
            if (selectedStyle != null) {
              collectedDetails.add({
                'title': 'الأسلوب',
                'value': selectedStyle!,
              });
            }
            if (selectedArea != null) {
              collectedDetails.add({
                'title': 'المساحة',
                'value': selectedArea!,
              });
            }
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderReviewScreen(
                orderDetails: collectedDetails,
                serviceFee: 0.0, 
                platformFee: 0.0,
              ),
            ),
          );
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
