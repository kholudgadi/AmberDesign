import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import 'my_orders_view.dart';
import 'home_screen.dart'; // Imports the home screen for navigation after the success action.

class RequestSentSuccessScreen extends StatelessWidget {
  final String orderId;

  const RequestSentSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const SizedBox(), // Hides the default back button.
        ),
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Success icon displayed inside a circular glass card.
                  GlassCard(
                    borderRadius: 100,
                    padding: const EdgeInsets.all(24),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 60,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'تم إرسال طلبك!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'وصل طلبك للمصممة، وستراجعه وترسل عرضها قريباً',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'رقم الطلب: $orderId',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Unified order progress card.
                  _buildTimelineCard(),
                  const SizedBox(height: 40),

                  // Button to continue to the orders view with a glass effect.
                  GlassCard(
                    borderRadius: 24,
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // 1. Open the orders screen as the main route and clear the previous stack.
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (innerContext) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: Scaffold(
                                  extendBodyBehindAppBar: true,
                                  appBar: AppBar(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    leading: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: AppColors.textDark,
                                      ),
                                      onPressed: () {
                                        // 2. When the back button is pressed, return to the home screen and reset the stack.
                                        Navigator.pushAndRemoveUntil(
                                          innerContext,
                                          MaterialPageRoute(
                                            builder: (_) => const HomeScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                    ),
                                    title: const Text(
                                      'طلباتي',
                                      style: TextStyle(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    centerTitle: true,
                                    bottom: PreferredSize(
                                      preferredSize: const Size.fromHeight(1.0),
                                      child: Container(
                                        color: AppColors.textMuted.withOpacity(
                                          0.15,
                                        ),
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                  body: const AppBackground(
                                    child: SafeArea(
                                      child: SingleChildScrollView(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        physics: BouncingScrollPhysics(),
                                        child: MyOrdersView(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            (route) =>
                                false, // Removes all prior routes from the navigation stack.
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: AppColors.textDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'متابعة طلباتي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildTimelineCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مراحل الطلب',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          _buildTimelineStep(
            title: 'تم إرسال طلبك',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineStep(
            title: 'المصممة تراجع طلبك',
            isCurrent: true,
            isLast: false,
          ),
          _buildTimelineStep(
            title: 'عرض السعر من المصممة',
            isPending: true,
            isLast: false,
          ),
          _buildTimelineStep(
            title: 'موافقتك والدفع',
            isPending: true,
            isLast: false,
          ),
          _buildTimelineStep(
            title: 'بدء التصميم',
            isPending: true,
            isLast: false,
          ),
          _buildTimelineStep(title: 'المراجعة', isPending: true, isLast: false),
          _buildTimelineStep(title: 'مكتمل', isPending: true, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    bool isCompleted = false,
    bool isCurrent = false,
    bool isPending = false,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle
                  : (isCurrent
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked),
              color: isPending
                  ? AppColors.textMuted.withOpacity(0.3)
                  : AppColors.textDark,
              size: 24,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isPending
                    ? AppColors.textMuted.withOpacity(0.2)
                    : AppColors.textDark.withOpacity(0.5),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isPending ? FontWeight.normal : FontWeight.bold,
              color: isPending
                  ? AppColors.textMuted.withOpacity(0.5)
                  : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
