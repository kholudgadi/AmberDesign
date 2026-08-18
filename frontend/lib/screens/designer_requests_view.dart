import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'designer_request_details_screen.dart';

class DesignerRequestsView extends StatefulWidget {
  final VoidCallback? onBack;

  const DesignerRequestsView({super.key, this.onBack});

  @override
  State<DesignerRequestsView> createState() => _DesignerRequestsViewState();
}

class _DesignerRequestsViewState extends State<DesignerRequestsView> {
  String _selectedType = 'الطلبات العامة'; 
  String _selectedCategory = 'الكل';
  
  final List<String> _filters = ['الكل', 'غريب', 'كاجوال', 'حفلات', 'سهرة', 'زواج']; 
  
  late Future<List<Map<String, dynamic>>> _requests;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _requests = OrdersService.instance.availableDesignRequests();

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
              ? IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: widget.onBack)
              : null,
          title: const Text('تصفح الطلبات', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _requests,
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
                      ]
                    )
                  );
                }

                final allRequests = snapshot.data ?? [];
                
                final filteredRequests = allRequests.where((req) {
                  final currentTypeString = _selectedType == 'الطلبات العامة' ? 'عام' : 'خاص';
                  final matchesType = (req['type'] == currentTypeString) || (req['type'] == null); // لو السيرفر ما أرسل نوع نمشيها
                  
                  final matchesCategory = _selectedCategory == 'الكل' || 
                                          req['style'] == _selectedCategory || 
                                          req['category'] == _selectedCategory;
                  
                  return matchesType && matchesCategory;
                }).toList();

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), 
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 200, 200, 200).withOpacity(0.35),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedType = 'الطلبات الخاصة';
                                      _selectedCategory = 'الكل'; 
                                    }),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _selectedType == 'الطلبات الخاصة' ? AppColors.textDark : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'الطلبات الخاصة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _selectedType == 'الطلبات الخاصة' ? Colors.white : AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedType = 'الطلبات العامة';
                                      _selectedCategory = 'الكل'; 
                                    }),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _selectedType == 'الطلبات العامة' ? AppColors.textDark : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'الطلبات العامة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _selectedType == 'الطلبات العامة' ? Colors.white : AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                          final isSelected = _selectedCategory == filter;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = filter),
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
                                        : const Color.fromARGB(255, 200, 200, 200).withOpacity(0.35),
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
                    
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => setState(_reload),
                        color: AppColors.textDark,
                        child: filteredRequests.isEmpty 
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text('لا توجد طلبات حالياً في هذا القسم', style: TextStyle(color: AppColors.textMuted)))
                            ]
                          )
                        : ListView.separated(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          itemCount: filteredRequests.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 24),
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];
                            return _buildRequestCard(request);
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

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final String imageUrl = (request['images'] != null && request['images'].isNotEmpty) 
        ? request['images'][0] 
        : 'https://via.placeholder.com/400';
    final String clientAvatar = request['clientAvatar'] ?? 'https://via.placeholder.com/150';
    final String clientName = (request['customer'] as Map<String, dynamic>?)?['displayName']?.toString() ?? request['clientName'] ?? 'عميل';
    
    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => DesignerRequestDetailsScreen(request: request)),
        );
        if (changed == true && mounted) setState(_reload);
      },
      child: DesignerGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), 
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(
                        request['type'] ?? 'عام', 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Row(
                      children: [
                        CircleAvatar(radius: 16, backgroundImage: NetworkImage(clientAvatar)),
                        const SizedBox(width: 8),
                        Text(clientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request['title'] ?? 'طلب تصميم', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(request['details'] ?? request['description'] ?? 'لا يوجد تفاصيل', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(request['budget']?.toString() ?? 'غير محدد', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFE08E36)),
                          const SizedBox(width: 4),
                          Text(request['city']?.toString() ?? 'غير محدد', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(width: 12),
                          Text(request['date']?.toString() ?? '', style: TextStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.8))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}