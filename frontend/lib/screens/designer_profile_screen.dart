import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/notification_bell.dart';
import 'request_design_view.dart';

class DesignerProfileScreen extends StatefulWidget {
  final Map<String, String> designer;

  const DesignerProfileScreen({super.key, required this.designer});

  @override
  State<DesignerProfileScreen> createState() => _DesignerProfileScreenState();
}

class _DesignerProfileScreenState extends State<DesignerProfileScreen> {
  // Currently selected tab index for the profile screen.
  int _selectedTab = 0;

  // Dummy portfolio image URLs from Unsplash for the designer showcase.
  final List<String> dummyPortfolioImages = [
    'https://images.unsplash.com/photo-1559034750-cdab70a66b8e?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGRyZXNzZXN8ZW58MHx8MHx8fDA%3D',
    'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?q=80&w=500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1633077705107-8f53a004218f?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NjJ8fGRyZXNzZXN8ZW58MHx8MHx8fDA%3D',
    'https://images.unsplash.com/photo-1612336307429-8a898d10e223?q=80&w=500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?q=80&w=500&auto=format&fit=crop',
  ];

  // Dummy review data for the designer profile.
  final List<Map<String, String>> dummyReviews = [
    {
      'name': 'سارة م.',
      'date': 'يوليو ٢٠٢٥',
      'review':
          'تصميم راقٍ جداً، التسليم كان في الوقت المحدد ومواصفاتي كلها اتحققت!',
    },
    {
      'name': 'منى ع.',
      'date': 'يونيو ٢٠٢٥',
      'review': 'أجمل فستان طلبته في حياتي، الخامة ممتازة والتفصيل دقيق.',
    },
    {
      'name': 'هدى ب.',
      'date': 'مايو ٢٠٢٥',
      'review': 'المصممة محترفة والتواصل معها سهل. سأطلب مرة أخرى.',
    },
  ];

  // Builds a glassmorphism-style container used throughout the profile screen.
  Widget _buildGlassBox({
    required Widget child,
    required BorderRadius borderRadius,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            color: color ?? Colors.white.withOpacity(0.4),
            child: child,
          ),
        ),
      ),
    );
  }

  // Builds the main profile screen layout with a custom app bar, tabs, and bottom action.
  @override
  Widget build(BuildContext context) {
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
          actions: [
            // Link notification button to the dialog and keep only the notification action.
            const NotificationBell(),
          ],
        ),
        body: AppBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildTabs(),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomButton(),
      ),
    );
  }

  // Builds the designer profile header section with avatar, name, category, and location.
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(widget.designer['avatarImage']!),
        ),
        const SizedBox(height: 12),
        Text(
          widget.designer['name']!,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          widget.designer['category']!,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              'الرياض، المملكة العربية السعودية',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Builds the row of tab buttons for navigating between request, reviews, and experience sections.
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildTabButton('خبراتي', 2),
          const SizedBox(width: 8),
          _buildTabButton('التقييمات', 1),
          const SizedBox(width: 8),
          _buildTabButton('طلب تصميم', 0),
        ],
      ),
    );
  }

  // Builds a single tab button and updates the selected tab when tapped.
  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: _buildGlassBox(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppColors.textDark.withOpacity(0.8)
              : Colors.white.withOpacity(0.4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 0) return _buildPortfolioTab();
    if (_selectedTab == 1) return _buildReviewsTab();
    return _buildExperienceTab();
  }

  Widget _buildPortfolioTab() {
    return Column(
      children: [
        _buildGlassBox(
          borderRadius: BorderRadius.circular(25),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: AppColors.textMuted),
                hintText: 'ابحث عن مشاريع...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dummyPortfolioImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                dummyPortfolioImages[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.white.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('(84)', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(width: 8),
            Row(
              children: List.generate(
                5,
                (index) =>
                    const Icon(Icons.star, color: Colors.orange, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '4.9',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('84 تقييم', style: TextStyle(color: AppColors.textMuted)),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dummyReviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final review = dummyReviews[index];
            return _buildGlassBox(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              review['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(
                                5,
                                (i) => const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          review['date']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review['review']!,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildExperienceTab() {
    return Column(
      children: [
        _buildGlassBox(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '128 طلب مكتمل',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'منذ انضمامها للمنصة',
                      style: TextStyle(
                        color: AppColors.textMuted.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildTimelineItem(
          '2020 - الآن',
          'مصممة مستقلة',
          'تصميم وخياطة فساتين السهرة والمناسبات الخاصة لعميلات VIP.',
        ),
        _buildTimelineItem(
          '2017 - 2020',
          'مصممة في دار أزياء',
          'تطوير مجموعات الفساتين السنوية والإشراف على الخياطة الدقيقة.',
        ),
        _buildTimelineItem(
          '2015 - 2017',
          'بكالوريوس تصميم أزياء',
          'تخرجت بمرتبة الشرف من كلية التصميم، متخصصة في الملبس السعودي الحديث.',
          isLast: true,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildTimelineItem(
    String year,
    String title,
    String desc, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.textDark,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 70,
                color: AppColors.textMuted.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                year,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE3DD).withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (innerContext) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: Scaffold(
                    extendBodyBehindAppBar: true,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.textDark,
                        ),
                        onPressed: () => Navigator.pop(innerContext),
                      ),
                      title: const Text(
                        'طلب تصميم',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: true,
                    ),
                    body: const AppBackground(
                      child: SafeArea(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          physics: BouncingScrollPhysics(),
                          child: RequestDesignView(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            // Update button background to 80% opacity and remove the default elevation shadow.
            backgroundColor: AppColors.textDark.withOpacity(0.8),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            'طلب تصميم من ${widget.designer['name']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
