import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'track_order_screen.dart';

class DesignerManagementView extends StatefulWidget {
  final VoidCallback? onBack;

  const DesignerManagementView({super.key, this.onBack});

  @override
  State<DesignerManagementView> createState() => _DesignerManagementViewState();
}

class _DesignerManagementViewState extends State<DesignerManagementView> {
  String _selectedFilter = 'الكل';
  late Future<List<Map<String, dynamic>>> _orders;

  // 💡 فلاتر الباك اند مترجمة وتطابق أزرار تصميمك
  static const _statuses = <String, String>{
    'all': 'الكل', 
    'assigned': 'مستلم', 
    'in_progress': 'قيد التنفيذ', 
    'ready': 'جاهز', 
    'completed': 'مكتمل'
  };

  final List<String> _filters = ['الكل', 'مستلم', 'قيد التنفيذ', 'جاهز', 'مكتمل'];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _orders = OrdersService.instance.list();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textDark), // 💡 سهم مناسب للغة العربية
                  onPressed: widget.onBack,
                )
              : null,
          title: const Text('إدارة الطلبات', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            // 💡 ربط تصميمك بالباك اند (FutureBuilder)
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _orders,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.textDark));
                }
                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'تعذر تحميل الطلبات';
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message, style: const TextStyle(color: AppColors.textDark)),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: () => setState(_reload), child: const Text('إعادة المحاولة'))
                      ],
                    ),
                  );
                }

                // 💡 الفلترة الذكية
                final all = snapshot.data!.where((row) => row['kind'] == 'design_request').toList();
                final filteredOrders = _selectedFilter == 'الكل'
                    ? all
                    : all.where((row) => (_statuses[row['status']] ?? row['status']) == _selectedFilter).toList();

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // 💡 كودك: شريط الفلاتر الأفقي الزجاجي
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filters.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = _selectedFilter == filter;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = filter),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), 
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? AppColors.textDark.withOpacity(0.9) 
                                        : const Color.fromARGB(255, 200, 200, 200).withOpacity(0.28),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      filter,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.white : AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 💡 كودك: قائمة بطاقات الطلبات
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => setState(_reload),
                        color: AppColors.textDark,
                        child: filteredOrders.isEmpty 
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text('لا توجد طلبات في هذا القسم', style: TextStyle(color: AppColors.textMuted)))
                            ]
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: filteredOrders.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              return _buildOrderCard(order);
                            },
                          ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  // 💡 كودك: بطاقة الطلب الأصلية مع التعديلات الطفيفة لبيانات السيرفر
  Widget _buildOrderCard(Map<String, dynamic> order) {
    // جلب الحالة وترجمتها للعربي لضبط الألوان
    final String statusEn = order['status']?.toString() ?? '';
    final String statusAr = _statuses[statusEn] ?? statusEn;

    Color statusColor;
    Color statusBgColor;

    switch (statusAr) {
      case 'قيد التنفيذ':
        statusColor = const Color(0xFF1976D2);
        statusBgColor = const Color(0xFFE3F2FD);
        break;
      case 'مستلم':
        statusColor = const Color(0xFFF57C00);
        statusBgColor = const Color(0xFFFFF3E0);
        break;
      case 'مكتمل':
      case 'جاهز':
        statusColor = const Color(0xFF388E3C);
        statusBgColor = const Color(0xFFE8F5E9);
        break;
      default:
        statusColor = AppColors.textMuted;
        statusBgColor = Colors.grey.withOpacity(0.2);
    }

    // 💡 حماية للبيانات لو السيرفر ما أرسل صورة أو اسم أو سعر
    final String imageUrl = (order['images'] != null && order['images'].isNotEmpty) 
        ? order['images'][0] 
        : order['image'] ?? 'https://via.placeholder.com/150';
    final String clientName = (order['customer'] as Map<String, dynamic>?)?['displayName']?.toString() ?? 'العميل';
    final String price = order['price']?.toString() ?? order['totalAmount']?.toString() ?? 'غير محدد';

    return GestureDetector(
      onTap: () {
        // 💡 التوجيه لصفحة TrackOrderScreen بناءً على طلب الباك اند
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: order['id'].toString(), kind: 'design_request')),
        );
      },
      child: DesignerGlassCard(
        padding: EdgeInsets.zero,
        height: 140,
        borderRadius: 24,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            order['title']?.toString() ?? 'طلب تصميم',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            statusAr,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    Text(clientName, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                    Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 120,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}