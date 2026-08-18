import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'add_product_screen.dart';
import 'designer_product_details_screen.dart';

class DesignerProductsView extends StatefulWidget {
  final VoidCallback? onBack; 
  const DesignerProductsView({super.key, this.onBack});

  @override
  State<DesignerProductsView> createState() => _DesignerProductsViewState();
}

class _DesignerProductsViewState extends State<DesignerProductsView> {
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'فستان سهرة ذهبي',
      'price': '٢٤٠٠',
      'category': 'سهرة',
      'status': 'متاح',
      'image': 'https://images.unsplash.com/photo-1566160983226-e17ee96c21a4?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': '2',
      'name': 'فستان زفاف ملكي',
      'price': '٧٥٠٠',
      'category': 'زواج',
      'status': 'متاح',
      'image': 'https://images.unsplash.com/photo-1595958564246-88b17b62fb91?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': '3',
      'name': 'فستان حفل أزرق',
      'price': '١٨٠٠',
      'category': 'حفلات',
      'status': 'متاح',
      'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': '4',
      'name': 'فستان كاجوال بيج',
      'price': '٩٥٠',
      'category': 'كاجوال',
      'status': 'نفد',
      'image': 'https://images.unsplash.com/photo-1515347619252-1d54fb3a0c5c?q=80&w=400&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'منتجاتي',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark), 
            onPressed: widget.onBack ?? () => Navigator.pop(context),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductScreen()),
            );
          },
          backgroundColor: const Color(0xFF2E1B3D),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100), 
              physics: const BouncingScrollPhysics(),
              itemCount: _products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildProductCard(_products[index]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final bool isAvailable = product['status'] == 'متاح';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesignerProductDetailsScreen(product: product),
          ),
        );
      },
      child: DesignerGlassCard(
        padding: EdgeInsets.zero,
        height: 150, 
        borderRadius: 24,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.network(
                  product['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product['category'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAvailable ? const Color(0xFF388E3C) : const Color(0xFFD32F2F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product['price']} ر.س',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_back_ios_new,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}