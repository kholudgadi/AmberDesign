import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';
import 'home_screen.dart'; 
import 'my_orders_view.dart'; 

/// Confirms successful payment and provides a route to the user's orders.
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This page is shown after payment and intentionally has no back navigation to payment.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Visual confirmation that the payment was completed successfully.
                  Center(
                    child: GlassCard(
                      width: 120,
                      height: 120,
                      borderRadius: 60,
                      padding: EdgeInsets.zero,
                      child: const Center(
                        child: Icon(Icons.check_circle_outline, size: 60, color: AppColors.textDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Explains the successful order submission and displays its reference number.
                  const Text('تمت عملية الدفع!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  const Text(
                    'تم تقديم طلبك بنجاح. ستبدأ المصممة العمل قريباً.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  const Text('طلب رقم #12345', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  
                  const Spacer(),

                  // Replaces the payment flow with the orders page after completion.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Clears payment-related routes so the completed payment cannot be submitted again.
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: Scaffold(
                                extendBodyBehindAppBar: true,
                                appBar: AppBar(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  leading: IconButton(
                                    icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                                    onPressed: () {
                                      // Returns to the main home screen from the standalone orders page.
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                                        (route) => false,
                                      );
                                    },
                                  ),
                                  title: const Text('طلباتي', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                                  centerTitle: true,
                                ),
                                body: const AppBackground(
                                  child: SafeArea(
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      physics: BouncingScrollPhysics(),
                                      child: MyOrdersView(), // Reuses the orders list with its standard layout.
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ), 
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text('عرض طلباتي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
