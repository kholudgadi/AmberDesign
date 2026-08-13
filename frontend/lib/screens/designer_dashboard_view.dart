import 'dart:ui'; 
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/global_data.dart';
import '../widgets/designer_app_background.dart'; 
import '../widgets/designer_glass_card.dart'; 

class DesignerDashboardView extends StatelessWidget {
  final Function(int) onTabChange;

  const DesignerDashboardView({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final profile = GlobalData.designerProfile;
    final activities = GlobalData.designerActivities;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textDark, size: 28),
          onPressed: () {
            debugPrint("تم الضغط على البرقر منيو");
          },
        ),
        title: const Text('الرئيسية', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
            onPressed: () {}, 
          ),
        ],
      ),
      body: DesignerAppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabChange(3),
                        child: DesignerGlassCard( 
                          padding: const EdgeInsets.all(20),
                          borderRadius: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(color: Color(0xFFFDECDA), shape: BoxShape.circle),
                                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFFE08E36)),
                              ),
                              const SizedBox(height: 12),
                              Text('${profile['pendingPurchases']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              const Text('طلب شراء قيد الانتظار', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabChange(2),
                        child: DesignerGlassCard( 
                          padding: const EdgeInsets.all(20),
                          borderRadius: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(color: Color(0xFFEFE9F5), shape: BoxShape.circle),
                                child: const Icon(Icons.assignment_outlined, color: Color(0xFF6A5AE0)),
                              ),
                              const SizedBox(height: 12),
                              Text('${profile['newOrders']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              const Text('طلب جديد بانتظارك', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {},
                  child: DesignerGlassCard( 
                    padding: const EdgeInsets.all(20),
                    borderRadius: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: Color(0xFFFFF4D9), shape: BoxShape.circle),
                              child: const Icon(Icons.star, color: Color(0xFFFFB300)),
                            ),
                            const SizedBox(width: 16),
                            Text('${profile['rating']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            const SizedBox(width: 8),
                            _buildStarRating(profile['rating']),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Row(
                              children: [
                                Text('تقييمي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                Icon(Icons.chevron_right, color: AppColors.textMuted),
                              ],
                            ),
                            Text('${profile['reviewCount']} تقييم', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                DesignerGlassCard( 
                  padding: EdgeInsets.zero, 
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 140,
                        child: Stack(
                          children: [
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                image: DecorationImage(image: AssetImage('assets/images/evening.png'), fit: BoxFit.cover),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                    child: const CircleAvatar(radius: 28, backgroundColor: Colors.transparent, child: Icon(Icons.person_outline, color: Colors.white, size: 30)),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(profile['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text('${profile['role']} • ${profile['city']}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile['bio'], style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('معرض الأعمال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text('تعديل المحفظة ←', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark, decoration: TextDecoration.underline)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: (profile['portfolioImages'] as List).map((url) {
                                return CircleAvatar(radius: 35, backgroundImage: NetworkImage(url));
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                const Text('آخر النشاطات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    
                    bool isOdd = index % 2 == 0;
                    Color cardColor = isOdd 
                        ? const Color(0xFFEFF6FF).withOpacity(0.6) 
                        : const Color(0xFFFFF7ED).withOpacity(0.6);
                    
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            spreadRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor, 
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), 
                                  child: Icon(activity['icon'] as IconData, color: AppColors.textDark, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(activity['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                      Text(activity['sub'], style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Text(activity['time'], style: TextStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.8))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Color(0xFFFFB300), size: 16);
        } else if (index == fullStars && rating % 1 != 0) {
          return const Icon(Icons.star_half, color: Color(0xFFFFB300), size: 16);
        } else {
          return Icon(Icons.star_border, color: AppColors.textMuted.withOpacity(0.3), size: 16);
        }
      }),
    );
  }
}