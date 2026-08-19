import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class DesignerSupportScreen extends StatelessWidget {
  const DesignerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': 'كيف أستلم أرباحي من التطبيق؟',
        'answer': 'يتم تحويل الأرباح أسبوعياً إلى حسابك البنكي المسجل لدينا بمجرد اكتمال الطلب واستلام العميل له.'
      },
      {
        'question': 'ماذا أفعل إذا تأخر العميل في الاستلام؟',
        'answer': 'يمكنك رفع تذكرة عبر زر "تواصل" في تفاصيل الطلب، وسيقوم فريقنا بمتابعة العميل نيابة عنك.'
      },
      {
        'question': 'هل يمكنني تغيير سياسة الاسترجاع الخاصة بي؟',
        'answer': 'نعم، يمكنك تعديل سياسة الاسترجاع من خلال إعدادات الملف الشخصي وتطبيقها على الطلبات الجديدة.'
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'الدعم الفني',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5),
                    ),
                    child: const Icon(Icons.support_agent, size: 60, color: Color(0xFF2E1B3D)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'كيف يمكننا مساعدتك اليوم؟',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'نحن هنا للإجابة على استفساراتك وحل أي مشكلة تواجهك.',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: _buildContactCard(
                          icon: Icons.chat_outlined,
                          title: 'واتساب',
                          subtitle: 'رد سريع',
                          color: const Color(0xFF388E3C), 
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم فتح الواتساب')));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildContactCard(
                          icon: Icons.email_outlined,
                          title: 'البريد الإلكتروني',
                          subtitle: 'للاستفسارات الرسمية',
                          color: const Color(0xFF1976D2),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم فتح الإيميل')));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الأسئلة الشائعة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DesignerGlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 24,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: faqs.length,
                      separatorBuilder: (context, index) => Divider(color: AppColors.textMuted.withOpacity(0.2), height: 1),
                      itemBuilder: (context, index) {
                        return Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            iconColor: const Color(0xFF2E1B3D),
                            collapsedIconColor: AppColors.textMuted,
                            title: Text(
                              faqs[index]['question']!,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                child: Text(
                                  faqs[index]['answer']!,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم فتح نموذج رفع التذكرة')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E1B3D), 
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 4,
                      ),
                      child: const Text('لم تجد ما تبحث عنه؟ ارفع تذكرة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildContactCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: DesignerGlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}