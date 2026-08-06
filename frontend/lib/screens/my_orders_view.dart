import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'order_details_screen.dart';
import '../widgets/glass_card.dart';
/// Displays the user's current and completed orders from the temporary local data set.
class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key});

  final List<Map<String, dynamic>> mockOrders = const [
    {
      'id': '#12345',
      'service': 'فستان سهرة',
      'designer': 'مها ديزاين',
      'date': '13 يوليو 2025',
      'price': '٤٨٠ ر.س',
      'status': 'قيد التنفيذ',
      'statusColor': Color(0xFF1976D2), 
      'image': 'assets/images/evening.png',
    },
    {
      'id': '#12346',
      'service': 'فستان زواج',
      'designer': 'نوف ديزاين',
      'date': '10 يوليو 2025',
      'price': '٨٥٠ ر.س',
      'status': 'مكتمل',
      'statusColor': Color(0xFF388E3C), 
      'image': 'assets/images/wedding.png',
    },
    {
      'id': '#12347',
      'service': 'فستان حفل',
      'designer': 'خلود ديزاين',
      'date': '5 يوليو 2025',
      'price': '٣٢٠ ر.س',
      'status': 'قيد المراجعة',
      'statusColor': Color(0xFFF57C00), 
      'image': 'assets/images/party.png',
    },
    {
      'id': '#12348',
      'service': 'فستان غريب',
      'designer': 'أمل ديزاين',
      'date': '1 يوليو 2025',
      'price': '٦٠٠ ر.س',
      'status': 'تم التقديم',
      'statusColor': Color(0xFF616161), 
      'image': 'assets/images/unique.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // The parent screen owns scrolling, so this list expands only to its content height.
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      padding: const EdgeInsets.only(
        bottom: 100,
      ), 
      itemCount: mockOrders.length,
      itemBuilder: (context, index) {
        final order = mockOrders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

/// Builds one interactive order summary and opens its details when tapped.
Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          // Passes the entire order record so the details screen renders the selected item.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: order),
            ),
          );
        },
        // Reusable card that keeps every order item visually consistent.
        child: GlassCard(
          height: 140,
          borderRadius: 20,
          padding: EdgeInsets.zero, // Allows the image to reach the card edge.
          child: Row(
            children: [
              // Order text and metadata appear on the leading side in RTL layouts.
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
                          Text(
                            order['service'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (order['statusColor'] as Color).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order['status'],
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: order['statusColor']),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        order['designer'],
                        style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order['date'],
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.8)),
                          ),
                          Text(
                            order['price'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Order image appears on the trailing side in RTL layouts.
              SizedBox(
                width: 100,
                height: double.infinity,
                child: Image.asset(
                  order['image'],
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
