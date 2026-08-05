import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

/// Visualizes a selected order's current status as a four-step timeline.
class TrackOrderScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Converts the stored status label into the index used by the timeline UI.
    int currentStepIndex = 0;
    switch (order['status']) {
      case 'تم التقديم':
        currentStepIndex = 0;
        break;
      case 'قيد التنفيذ':
        currentStepIndex = 1;
        break;
      case 'قيد المراجعة':
        currentStepIndex = 2;
        break;
      case 'مكتمل':
        currentStepIndex = 3;
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
                  // Summarizes the selected order and its current status.
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
                              '${order['service']} • ${order['designer']}',
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
                            color: (order['statusColor'] as Color).withOpacity(
                              0.15,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            order['status'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: order['statusColor'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Visual timeline of the order's progress through each stage.
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
                          title: 'تم تقديم الطلب',
                          subtitle: currentStepIndex == 0
                              ? 'تم استلام طلبك وبانتظار البدء'
                              : null,
                          isCompleted: currentStepIndex >= 0,
                          isLastCompleted: currentStepIndex == 0,
                        ),
                        _buildTimelineStep(
                          title: 'قيد التنفيذ',
                          subtitle: currentStepIndex == 1
                              ? 'المصممة تعمل على تصميمك الآن'
                              : null,
                          isCompleted: currentStepIndex >= 1,
                          isLastCompleted: currentStepIndex == 1,
                        ),
                        _buildTimelineStep(
                          title: 'المراجعة',
                          subtitle: currentStepIndex == 2
                              ? 'التصميم المبدئي جاهز لمراجعتك'
                              : null,
                          isCompleted: currentStepIndex >= 2,
                          isLastCompleted: currentStepIndex == 2,
                        ),
                        _buildTimelineStep(
                          title: 'مكتمل',
                          subtitle: currentStepIndex == 3
                              ? 'تم تسليم التصميم النهائي بنجاح'
                              : null,
                          isCompleted: currentStepIndex >= 3,
                          isLastCompleted: currentStepIndex == 3,
                          isLastStep: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Provides the assigned designer's details and contact action.
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(order['image']),
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
                                'مصممة أزياء • ★ 4.9',
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
    // Renders the marker, connector, and optional detail for one timeline stage.
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
