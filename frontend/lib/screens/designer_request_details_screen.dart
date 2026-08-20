import 'dart:ui';
import 'package:flutter/material.dart';
// import '../services/api_client.dart';
// import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'send_offer_screen.dart';
// import 'track_order_screen.dart';


class DesignerRequestDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  const DesignerRequestDetailsScreen({super.key, required this.request});

  @override
  State<DesignerRequestDetailsScreen> createState() => _DesignerRequestDetailsScreenState();
}

class _DesignerRequestDetailsScreenState extends State<DesignerRequestDetailsScreen> {
  // bool _claiming = false;

  // Future<void> _claim() async {
  //   setState(() => _claiming = true);
  //   try {
  //     final claimed = await OrdersService.instance.claimDesignRequest(widget.request['id'].toString());
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استلام الطلب وفتح المحادثة مع العميل')));
  //     await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: claimed['id'].toString(), kind: 'design_request')));
  //   } on ApiException catch (error) {
  //     if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
  //   } finally {
  //     if (mounted) setState(() => _claiming = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final customer = request['customer'] as Map<String, dynamic>?;
    final referenceUrls = ((request['referenceUrls'] as List<dynamic>?) ?? const []).map((e) => e.toString()).toList();
    final specifications = (request['specifications'] as Map<String, dynamic>?) ?? const {};
    
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
            'تفاصيل الطلب',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    child: referenceUrls.isEmpty
                        ? Container(
                            decoration: BoxDecoration(color: AppColors.textMuted.withOpacity(0.12), borderRadius: BorderRadius.circular(24)),
                            alignment: Alignment.center,
                            child: const Text('لا توجد صور مرفقة'),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: referenceUrls.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(referenceUrls[index], width: 240, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 240, color: AppColors.textMuted.withOpacity(0.12), child: const Icon(Icons.broken_image_outlined))),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: (customer?['avatarUrl']?.toString().isNotEmpty ?? false) ? NetworkImage(customer!['avatarUrl'].toString()) : null,
                        child: (customer?['avatarUrl']?.toString().isNotEmpty ?? false) ? null : const Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer?['displayName']?.toString() ?? 'عميل',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            request['createdAt']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  DesignerGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['title'] ?? 'طلب تصميم',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          request['details']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildDetailRow('الفئة', request['category'] == 'interior' ? 'تصميم داخلي' : 'أزياء'),
                        ...specifications.entries.map((entry) => _buildDetailRow(entry.key, entry.value?.toString() ?? '')),
                        _buildDetailRow('المدينة', customer?['city']?.toString() ?? ''),
                        _buildDetailRow(
                          'الموعد',
                          request['status']?.toString() ?? '',
                          isLast: true,
                        ),
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
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10.0,
                                sigmaY: 10.0,
                              ),
                              child: ElevatedButton(
                                onPressed: () => _showRejectBottomSheet(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    200,
                                    200,
                                    200,
                                  ).withOpacity(0.28),
                                  foregroundColor: AppColors.textDark,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text(
                                  'رفض',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SendOfferScreen(request: request),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textDark.withOpacity(0.9),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Text(
                            'قبول وإرسال عرض',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(color: AppColors.textMuted.withOpacity(0.1), height: 1),
      ],
    );
  }

  void _showRejectBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl, 
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
              top: 32,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تأكيد الرفض',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'هل أنتِ متأكدة؟',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                
                TextField(
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'سبب الرفض...',
                    hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.6)),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 200, 200, 200).withOpacity(0.28), 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم رفض الطلب بنجاح')),
                          );
                          Navigator.pop(context); 
                          Navigator.pop(context); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935), 
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'تأكيد',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 200, 200, 200).withOpacity(0.28), 
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
