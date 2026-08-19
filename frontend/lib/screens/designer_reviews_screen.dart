import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class DesignerReviewsScreen extends StatelessWidget {
  const DesignerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'منى القحطاني',
        'rating': 5,
        'comment': 'فستان السهرة كان أجمل من توقعاتي، التفاصيل رائعة.',
        'date': 'يوليو ٢٠٢٥',
        'product': 'فستان سهرة احترافي',
        'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      },
      {
        'name': 'ليلى الخالدي',
        'rating': 5,
        'comment': 'وصل في الوقت المحدد وبالمواصفات الدقيقة!',
        'date': 'يوليو ٢٠٢٥',
        'product': 'فستان سهرة ذهبي',
        'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
      },
      {
        'name': 'سارة الحربي',
        'rating': 5,
        'comment': 'فستان الزفاف كان حلمي، مصممة موهوبة جداً.',
        'date': 'يونيو ٢٠٢٥',
        'product': 'فستان زفاف مميز',
        'avatar': 'https://randomuser.me/api/portraits/women/17.jpg',
      },
      {
        'name': 'لمياء العتيبي',
        'rating': 4,
        'comment': 'تصميم جميل والتواصل كان ممتازاً.',
        'date': 'مايو ٢٠٢٥',
        'product': 'فستان حفل عصري',
        'avatar': 'https://randomuser.me/api/portraits/women/32.jpg',
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'تقييمات العميلات',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark), 
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  
                  ListView.separated(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: reviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildReviewCard(reviews[index]);
                    },
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

  Widget _buildSummaryCard() {
    return DesignerGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Text(
                  '4.8',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.1),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < 4 ? Icons.star : Icons.star_half, 
                      color: const Color(0xFFFFD700),
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                const Text(
                  '4 تقييم',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(height: 80, width: 1, color: AppColors.textMuted.withOpacity(0.2)),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildRatingBar(5, 0.75, '3'),
                _buildRatingBar(4, 0.25, '1'),
                _buildRatingBar(3, 0.0, '0'),
                _buildRatingBar(2, 0.0, '0'),
                _buildRatingBar(1, 0.0, '0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double percentage, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('★$star', style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(count, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final int rating = review['rating'];

    return DesignerGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review['avatar']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFD700),
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review['comment'],
            style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('👗 ', style: TextStyle(fontSize: 12)), 
                    Text(
                      review['product'],
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                review['date'],
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}