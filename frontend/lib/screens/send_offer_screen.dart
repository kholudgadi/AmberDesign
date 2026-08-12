import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/global_data.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

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
                    onPressed: _isButtonEnabled ? () {
                      GlobalData.addNotification(
                        'عرض جديد من ${GlobalData.designerProfile['name']}', 
                        'تم إرسال عرض لطلب ${widget.request['title']}', 
                        Icons.local_offer_outlined, 
                        0xFF6A5AE0
                      );
                      Navigator.pop(context); 
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled 
                          ? const Color.fromRGBO(38, 23, 50, 0.8) 
                          : AppColors.textMuted.withOpacity(0.5),
                      disabledBackgroundColor: AppColors.textMuted.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: _isButtonEnabled ? 8 : 0,
                    ),
                    child: const Text('إرسال العرض', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                  widget.request['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.request['clientName']} · ${widget.request['city']}', 
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
            child: Image.network(
              widget.request['images'][0],
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
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