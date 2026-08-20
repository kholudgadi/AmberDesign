import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'track_order_screen.dart';

class SendOfferScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  const SendOfferScreen({super.key, required this.request});

  @override
  State<SendOfferScreen> createState() => _SendOfferScreenState();
}

class _SendOfferScreenState extends State<SendOfferScreen> {
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  final _messageCtrl = TextEditingController(); 
  bool _isButtonEnabled = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl.addListener(_checkValidation);
    _durationCtrl.addListener(_checkValidation);
    _deliveryCtrl.addListener(_checkValidation);
  }

  void _checkValidation() {
    bool isValid = _priceCtrl.text.isNotEmpty && 
                   _durationCtrl.text.isNotEmpty && 
                   _deliveryCtrl.text.isNotEmpty;
    if (_isButtonEnabled != isValid) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  double? _parsePrice(String raw) {
    const digits = '٠١٢٣٤٥٦٧٨٩';
    final normalized = raw.split('').map((char) {
      final index = digits.indexOf(char);
      return index < 0 ? char : index.toString();
    }).join().replaceAll(',', '').trim();
    return double.tryParse(normalized);
  }

  Future<void> _submitOffer() async {
    final price = _parsePrice(_priceCtrl.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخلي سعرًا صحيحًا')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final quoted = await OrdersService.instance.sendOffer(
        widget.request['id'].toString(),
        price: price,
        duration: _durationCtrl.text.trim(),
        deliveryDate: _deliveryCtrl.text.trim(),
        message: _messageCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال العرض بنجاح!')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: quoted['id'].toString(), kind: 'design_request')),
        (route) => route.isFirst,
      );
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _deliveryCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            'إرسال عرض', 
            style: TextStyle(
              color: AppColors.textDark, 
              fontWeight: FontWeight.bold,
              fontSize: 24,
            )
          ),
          centerTitle: true,
        ),
        body: DesignerAppBackground( 
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRequestSummaryCard(),
                  const SizedBox(height: 32),

                  _buildGlassInput('السعر المقترح (ر.س)', 'مثال: ٤٥٠٠', _priceCtrl),
                  _buildGlassInput('مدة الإنجاز', 'مثال: ٣ أسابيع', _durationCtrl),
                  _buildGlassInput('تاريخ التسليم', 'مثال: ١ سبتمبر', _deliveryCtrl),
                  _buildGlassInput('رسالتك', 'اشرحي رؤيتك...', _messageCtrl, maxLines: 4),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: (_isButtonEnabled && !_isSubmitting) ? _submitOffer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled 
                          ? const Color.fromRGBO(38, 23, 50, 0.8) 
                          : AppColors.textMuted.withOpacity(0.5),
                      disabledBackgroundColor: AppColors.textMuted.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: _isButtonEnabled ? 8 : 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('إرسال العرض', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildRequestSummaryCard() {
    final customer = widget.request['customer'] as Map<String, dynamic>?;
    final urls = (widget.request['referenceUrls'] as List<dynamic>?) ?? const [];
    final imageUrl = urls.isEmpty ? null : urls.first.toString();
    return DesignerGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // 💡 تفادي الخطأ لو كان العنوان غير موجود
                  widget.request['title'] ?? 'طلب تصميم',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${customer?['displayName'] ?? 'عميل'} · ${customer?['city'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipOval(
            child: imageUrl == null
                ? Container(width: 70, height: 70, color: AppColors.textMuted.withOpacity(0.15), child: const Icon(Icons.image_not_supported_outlined))
                : Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: AppColors.textMuted.withOpacity(0.15), child: const Icon(Icons.broken_image_outlined))),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput(String label, String hint, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
          DesignerGlassCard(
            padding: EdgeInsets.zero, 
            child: TextField(
              controller: ctrl,
              maxLines: maxLines,
              style: const TextStyle(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.6)),
                border: InputBorder.none, 
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
