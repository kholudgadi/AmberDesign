import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';
import 'payment_success_screen.dart';

/// Lets the user choose a payment method and confirm the final order amount.
class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Stores the selected payment option; credit card is selected by default.
  int _selectedMethod = 1;

  @override
  Widget build(BuildContext context) {
    // Uses the total calculated on the review screen instead of recalculating it here.
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
          title: const Text('الدفع', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Displays the amount that will be charged for this order.
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المبلغ الإجمالي', style: TextStyle(fontSize: 16, color: AppColors.textMuted)),
                        Text('${widget.totalAmount} ر.س', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Padding(
                    padding: EdgeInsets.only(right: 8, bottom: 16),
                    child: Text('اختر طريقة الدفع', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  ),

                  // Renders all available payment methods using the same option widget.
                  _buildPaymentOption(1, 'بطاقة ائتمان / مدى', Icons.credit_card, Colors.blue),
                  const SizedBox(height: 12),
                  _buildPaymentOption(2, 'Apple Pay', Icons.apple, Colors.black),
                  const SizedBox(height: 12),
                  _buildPaymentOption(3, 'STC Pay', Icons.account_balance_wallet, Colors.purple),
                  const SizedBox(height: 12),
                  _buildPaymentOption(4, 'مدى', Icons.credit_score, Colors.green),

                  const Spacer(),

                  // Starts payment confirmation for the selected method.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // A real payment-gateway request should be made here in production.
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
                          (route) => false, // Prevents returning to the payment screen after success.
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text('ادفعي الآن — ${widget.totalAmount} ر.س', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildPaymentOption(int value, String title, IconData icon, Color iconColor) {
    // Reuses one selectable card for every payment method.
    bool isSelected = _selectedMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value), // Updates the active payment method.
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: _selectedMethod,
              onChanged: (val) => setState(() => _selectedMethod = val!),
              activeColor: AppColors.textDark,
            ),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: AppColors.textDark)),
            const Spacer(),
            Icon(icon, color: isSelected ? iconColor : AppColors.textMuted, size: 28),
          ],
        ),
      ),
    );
  }
}
