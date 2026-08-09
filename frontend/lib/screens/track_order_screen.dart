import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';

/// Visualizes a selected order's current status as a unified 7-step timeline.
class TrackOrderScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Maps the order status to the corresponding index in the unified 7-step timeline.
    int currentStepIndex = 0;
    switch (order['status']) {
      case 'تم التقديم':
      case 'تم إرسال طلبك':
        currentStepIndex = 0;
        break;
      case 'المصممة تراجع طلبك':
        currentStepIndex = 1;
        break;
      case 'عرض السعر من المصممة':
        currentStepIndex = 2;
        break;
      case 'موافقتك والدفع':
        currentStepIndex = 3;
        break;
      case 'قيد التنفيذ':
      case 'بدء التصميم':
        currentStepIndex = 4;
        break;
      case 'قيد المراجعة':
      case 'المراجعة':
        currentStepIndex = 5;
        break;
      case 'مكتمل':
        currentStepIndex = 6;
        break;
      default:
        currentStepIndex = 0;
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
          title: const Text(
            'تتبع الطلب',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Order summary section.
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طلب ${order['id']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order['service'] ?? order['title']} • ${order['designer']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (order['statusColor'] as Color? ??
                                        AppColors.textDark)
                                    .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            order['status'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: order['statusColor'] ?? AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Unified timeline rendered inside a glass card.
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التقدم',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildTimelineStep(
                          title: 'تم إرسال طلبك',
                          subtitle: currentStepIndex == 0
                              ? 'بانتظار استلام المصممة للطلب'
                              : null,
                          isCompleted: currentStepIndex >= 0,
                          isLastCompleted: currentStepIndex == 0,
                        ),
                        _buildTimelineStep(
                          title: 'المصممة تراجع طلبك',
                          subtitle: currentStepIndex == 1
                              ? 'جاري دراسة المتطلبات والمواصفات'
                              : null,
                          isCompleted: currentStepIndex >= 1,
                          isLastCompleted: currentStepIndex == 1,
                        ),
                        _buildTimelineStep(
                          title: 'عرض السعر من المصممة',
                          subtitle: currentStepIndex == 2
                              ? 'المصممة حددت السعر، بانتظار قرارك'
                              : null,
                          isCompleted: currentStepIndex >= 2,
                          isLastCompleted: currentStepIndex == 2,
                        ),
                        _buildTimelineStep(
                          title: 'موافقتك والدفع',
                          subtitle: currentStepIndex == 3
                              ? 'تم الدفع بنجاح واعتماد الطلب'
                              : null,
                          isCompleted: currentStepIndex >= 3,
                          isLastCompleted: currentStepIndex == 3,
                        ),
                        _buildTimelineStep(
                          title: 'بدء التصميم',
                          subtitle: currentStepIndex == 4
                              ? 'المصممة تعمل على تصميمك الآن'
                              : null,
                          isCompleted: currentStepIndex >= 4,
                          isLastCompleted: currentStepIndex == 4,
                        ),
                        _buildTimelineStep(
                          title: 'المراجعة',
                          subtitle: currentStepIndex == 5
                              ? 'التصميم المبدئي جاهز لمراجعتك'
                              : null,
                          isCompleted: currentStepIndex >= 5,
                          isLastCompleted: currentStepIndex == 5,
                        ),
                        _buildTimelineStep(
                          title: 'مكتمل',
                          subtitle: currentStepIndex == 6
                              ? 'تم تسليم التصميم النهائي بنجاح'
                              : null,
                          isCompleted: currentStepIndex >= 6,
                          isLastCompleted: currentStepIndex == 6,
                          isLastStep: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Designer contact details.
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: order['image'] != null
                              ? (order['image'].toString().startsWith('http')
                                    ? NetworkImage(order['image'])
                                    : AssetImage(order['image'])
                                          as ImageProvider)
                              : null,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order['designer'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Text(
                                'تواصل مع المصممة لأي استفسار',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
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

  Widget _buildTimelineStep({
    required String title,
    String? subtitle,
    required bool isCompleted,
    required bool isLastCompleted,
    bool isLastStep = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.textDark : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.textDark
                      : AppColors.textMuted.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isCompleted && !isLastCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : (isLastCompleted
                        ? Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null),
            ),
            if (!isLastStep)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? AppColors.textDark
                    : AppColors.textMuted.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? AppColors.textDark : AppColors.textMuted,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
              if (!isLastStep) const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
