import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import 'request_sent_success_screen.dart';

class OrderReviewScreen extends StatefulWidget {
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
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  bool _submitting = false;

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final specifications = <String, String>{
        for (final detail in widget.orderDetails)
          if (detail['title'] != null && detail['value'] != null)
            detail['title']!: detail['value']!,
      };
      final values = widget.orderDetails.map((item) => item['value'] ?? '').join(' ');
      final category = values.contains('أزياء') || values.contains('فستان') ? 'fashion' : 'interior';
      final title = widget.orderDetails.length > 1
          ? widget.orderDetails[1]['value'] ?? 'طلب تصميم مخصص'
          : 'طلب تصميم مخصص';
      final request = await OrdersService.instance.createDesignRequest(
        category: category,
        title: title,
        specifications: specifications,
        serviceFee: widget.serviceFee,
        platformFee: widget.platformFee,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RequestSentSuccessScreen(orderId: request['id'].toString())),
      );
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.serviceFee + widget.platformFee;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مراجعة الطلب')),
        body: AppBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: widget.orderDetails.map((detail) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(detail['title'] ?? '', style: const TextStyle(color: AppColors.textMuted)),
                        Flexible(child: Text(detail['value'] ?? '', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark))),
                      ]),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    _price('رسوم الخدمة', widget.serviceFee),
                    const Divider(height: 24),
                    _price('رسوم المنصة', widget.platformFee),
                    const Divider(height: 24),
                    _price('الإجمالي', total, bold: true),
                  ]),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.textDark, padding: const EdgeInsets.symmetric(vertical: 17)),
                  child: _submitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('إرسال الطلب للمصممة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _price(String label, double value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      Text('$value ر.س', style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    ],
  );
}
