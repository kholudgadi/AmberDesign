import 'dart:ui'; 
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/global_data.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'designer_order_details_screen.dart';

class DesignerManagementView extends StatefulWidget {
  final VoidCallback? onBack;

  const DesignerManagementView({super.key, this.onBack});

  @override
  State<DesignerManagementView> createState() => _DesignerManagementViewState();
}

class _DesignerManagementViewState extends State<DesignerManagementView> {
  String _selectedFilter = 'الكل';

  final List<String> _filters = [
    'الكل',
    'قيد الانتظار',
    'بانتظار رد العميل',
    'مقبول',
    'قيد التنفيذ',
    'مكتمل',
    'مرفوض'
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allOrders = GlobalData.designerManagementOrders;
    final filteredOrders = _selectedFilter == 'الكل'
        ? allOrders
        : allOrders.where((order) => order['status'] == _selectedFilter).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('إدارة الطلبات', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: DesignerAppBackground(
        child: SafeArea(
          child: Column(
            children: [
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
                    final isSelected = _selectedFilter == filter;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
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
              
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color statusColor;
    Color statusBgColor;
    switch (order['status']) {
      case 'قيد التنفيذ':
        statusColor = const Color(0xFF1976D2);
        statusBgColor = const Color(0xFFE3F2FD);
        break;
      case 'بانتظار رد العميل':
        statusColor = const Color(0xFFF57C00);
        statusBgColor = const Color(0xFFFFF3E0);
        break;
      case 'مكتمل':
      case 'مقبول':
        statusColor = const Color(0xFF388E3C);
        statusBgColor = const Color(0xFFE8F5E9);
        break;
      case 'مرفوض':
        statusColor = const Color(0xFFD32F2F);
        statusBgColor = const Color(0xFFFFEBEE);
        break;
      case 'قيد الانتظار':
        statusColor = const Color(0xFF757575);
        statusBgColor = const Color(0xFFEEEEEE);
        break;
      default:
        statusColor = AppColors.textMuted;
        statusBgColor = Colors.grey.withOpacity(0.2);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DesignerOrderDetailsScreen(order: order)),
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
                            order['title'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            order['status'],
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    Text(order['clientName'], style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                    Text(order['price'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 120,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                child: Image.network(order['image'], fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}