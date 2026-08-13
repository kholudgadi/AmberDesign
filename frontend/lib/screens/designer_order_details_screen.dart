import 'dart:ui'; // 💡 ضروري لإضافة فلتر التغبيش (Blur)
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class DesignerOrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const DesignerOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    switch (order['status']) {
      case 'قيد التنفيذ':
        statusColor = const Color(0xFF1976D2);
        statusBgColor = const Color(0xFFE3F2FD);
        break;
      case 'بانتظار رد العميل':
        statusColor = const Color(0xFFF57C00);
        statusBgColor = const Color(0xFFFFF3E0);
        break;
      case 'مكتمل':
      case 'مقبول':
        statusColor = const Color(0xFF388E3C);
        statusBgColor = const Color(0xFFE8F5E9);
        break;
      case 'ملغي':
      case 'مرفوض':
        statusColor = const Color(0xFFD32F2F);
        statusBgColor = const Color(0xFFFFEBEE);
        break;
      case 'قيد الانتظار':
        statusColor = const Color(0xFF757575);
        statusBgColor = const Color(0xFFEEEEEE);
        break;
      default:
        statusColor = AppColors.textMuted;
        statusBgColor = Colors.grey.withOpacity(0.2);
    }

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
          title: const Text('تفاصيل طلب التصميم', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  DesignerGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CircleAvatar(radius: 12, backgroundImage: NetworkImage(order['clientAvatar'])),
                                  const SizedBox(width: 8),
                                  Text(order['clientName'], style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(12)),
                                    child: Text(order['status'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(order['price'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            ],
                          ),
                        ),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(image: NetworkImage(order['image']), fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  DesignerGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('مسار الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 24),
                        _buildTimeline(order['currentStep'] as int, order['date']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08), 
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), 
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.5), 
                                  foregroundColor: AppColors.textDark,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1), 
                                  ),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                                label: const Text('تواصل', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textDark.withOpacity(0.8), 
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('تحديث الحالة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(int currentStep, String date) {
    final List<String> steps = ['تم الطلب', 'أُرسل العرض', 'قُبِل العرض', 'قيد التنفيذ', 'مكتمل'];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        bool isCompleted = index < currentStep;
        bool isCurrent = index == currentStep;
        bool isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent ? AppColors.textDark : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: isCompleted || isCurrent ? AppColors.textDark : AppColors.textMuted.withOpacity(0.3), width: 2),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : (isCurrent ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40, 
                    color: isCompleted ? AppColors.textDark : AppColors.textMuted.withOpacity(0.2),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted || isCurrent ? AppColors.textDark : AppColors.textMuted.withOpacity(0.5),
                      ),
                    ),
                    if (isCurrent)
                      Text(
                        date,
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.8)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}