import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';
import 'payment_screen.dart';

/// Reviews a request and its fees before the user continues to payment.
class OrderReviewScreen extends StatelessWidget {
  // These values make the screen work for both fashion and interior-design requests.
  final List<Map<String, String>> orderDetails; 
  final double serviceFee;
  final double platformFee;

  const OrderReviewScreen({
    super.key,
    required this.orderDetails,
    required this.serviceFee,
    required this.platformFee,
  });

  @override
  Widget build(BuildContext context) {
    // Calculates the final amount once from the service and platform fees.
    final double totalAmount = serviceFee + platformFee;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('مراجعة الطلب', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20), 

                  // Lists only the request details collected on the previous screen.
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderDetails.length,
                      separatorBuilder: (context, index) => const Divider(height: 24, color: Colors.black12),
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(orderDetails[index]['title']!, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                            Text(orderDetails[index]['value']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Shows a transparent breakdown of fees and the final amount.
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('رسوم الخدمة', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                            Text('$serviceFee ر.س', style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                          ],
                        ),
                        const Divider(height: 24, color: Colors.black12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('رسوم المنصة', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                            Text('$platformFee ر.س', style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                          ],
                        ),
                        const Divider(height: 24, color: Colors.black26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الإجمالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            Text('$totalAmount ر.س', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),

                  // Passes the calculated total to the payment screen.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Keeps the total consistent between review and payment.
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PaymentScreen(totalAmount: totalAmount)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text('المتابعة للدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
}
