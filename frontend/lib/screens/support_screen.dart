import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';

/// Provides customer support contact options and expandable FAQ answers.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wraps content in a scroll view so support resources remain accessible on small screens.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('المساعدة والدعم', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick contact options displayed at the top of the support page.
                  Row(
                    children: [
                      Expanded(child: _buildContactCard(Icons.email_outlined, 'راسلنا', 'support@amber.sa', Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildContactCard(Icons.phone_outlined, 'اتصل بنا', '+966 xxxx xxx xx', Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildContactCard(Icons.help_outline, 'مركز المساعدة', 'أسئلة شائعة', AppColors.textDark)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildContactCard(Icons.chat_bubble_outline, 'واتساب', 'دعم فوري', Colors.teal)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('الأسئلة الشائعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 16),

                  // FAQ section styled with the shared glass-effect container.
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Hides the default expansion-tile dividers.
                      child: Column(
                        children: [
                          _buildFAQ('كيف أطلب تصميم فستان؟', 'من الرئيسية اضغطي على \'طلب تصميم\'، حددي النوع والمواصفات، ثم أرسلي الطلب.'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildFAQ('كم مدة التسليم؟', 'عادةً بين ٣ و٧ أيام عمل حسب نوع الفستان وتفاصيله.'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildFAQ('هل يمكنني إلغاء الطلب؟', 'يمكن إلغاء الطلب خلال ٢٤ ساعة. بعد ذلك تُطبَّق سياسة الاسترداد.'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildFAQ('كيف أتواصل مع المصممة؟', 'بعد قبول الطلب يمكنك التواصل عبر نظام المحادثة الداخلي.'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildFAQ('ما طرق الدفع المتاحة؟', 'نقبل بطاقات الائتمان، مدى، Apple Pay، وSTC Pay.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text('وقت الدعم: الأحد - الخميس ٩ ص - ٦ م', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, Color iconColor) {
    // Reuses the same visual treatment for each communication channel.
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    // Keeps answers collapsed until the user expands the relevant question.
    return ExpansionTile(
      iconColor: AppColors.textDark,
      collapsedIconColor: AppColors.textMuted,
      title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Text(answer, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
        ),
      ],
    );
  }
}
