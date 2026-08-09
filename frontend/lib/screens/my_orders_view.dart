import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'track_order_screen.dart'; // Routes the order card to the tracking screen.
import '../widgets/glass_card.dart';
import '../utils/global_data.dart'; // Imports the temporary in-memory order data.

/// Displays the user's current and completed orders from the temporary local data set.
class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView> {
  // Original mock orders retained as fallback sample data.
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
    // Combines newly created orders with the existing mock orders.
    final List<Map<String, dynamic>> allOrders = [
      ...GlobalData.myOrders, // Newly created orders appear first.
      ...mockOrders, // Older mock orders follow.
    ];

    // The parent screen owns scrolling, so this list expands only to its content height.
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
              builder: (context) => TrackOrderScreen(
                order: order,
              ), // Opens the order tracking screen.
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
                            order['service'] ??
                                order['title'] ??
                                'طلب تصميم', // Falls back to the title if the service field is missing.
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (order['statusColor'] as Color? ??
                                          AppColors.textDark)
                                      .withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order['status'] ?? '',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color:
                                    order['statusColor'] ?? AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        order['designer'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order['date'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            order['price'] ??
                                'بانتظار التسعير', // New orders may not have a price yet.
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
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
                child: order['image'] != null
                    ? (order['image'].toString().startsWith('http')
                          ? Image.network(
                              // Uses a network image for newly created orders.
                              order['image'],
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            )
                          : Image.asset(
                              // Uses a local asset for older mock orders.
                              order['image'],
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ))
                    : Container(
                        color: Colors.grey.withOpacity(0.2),
                      ), // Fallback background when no image is available.
              ),
            ],
          ),
        ),
      ),
    );
  }
}
