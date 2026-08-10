import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'track_order_screen.dart'; 
import '../widgets/glass_card.dart';
import '../utils/global_data.dart'; 

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allOrders = GlobalData.myOrders;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100), 
      itemCount: allOrders.length,
      itemBuilder: (context, index) {
        final order = allOrders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackOrderScreen(order: order), 
            ),
          );
        },
        child: GlassCard(
          height: 140,
          borderRadius: 20,
          padding: EdgeInsets.zero, 
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
                        children: [
                          Expanded(
                            child: Text(
                              order['title'] ?? order['service'] ?? 'طلب تصميم',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (order['statusColor'] as Color? ?? AppColors.textDark).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order['status'] ?? '',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: order['statusColor'] ?? AppColors.textDark),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        order['designer'] ?? 'بانتظار المصممة',
                        style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order['date'] ?? 'اليوم',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.8)),
                          ),
                          Text(
                            order['price'] ?? 'بانتظار التسعير', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                height: double.infinity,
                child: order['image'] != null
                    ? (order['image'].toString().startsWith('http') 
                        ? Image.network( 
                            order['image'],
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          )
                        : Image.asset( 
                            order['image'],
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ))
                    : Container(color: Colors.grey.withOpacity(0.2)), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}