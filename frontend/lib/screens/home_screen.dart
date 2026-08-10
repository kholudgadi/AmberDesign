import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/user_bottom_nav_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/category_card.dart';
import '../widgets/designer_card.dart';
import '../widgets/mini_designer_card.dart';
import '../screens/request_design_view.dart';
import '../screens/my_orders_view.dart';
import '../screens/profile_view.dart';
import '../widgets/app_drawer.dart';
import 'notifications_dialog.dart';

/// Main signed-in experience that hosts home content and user navigation tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Determines which content area is rendered by the bottom navigation bar.
  int _currentIndex = 0;
  // Owns the query so the search field and result view stay synchronized.
  final TextEditingController _searchController = TextEditingController();

  void _openSearch([String query = '']) {
    setState(() {
      _searchController.text = query;
      _currentIndex = 1;
    });
  }

  void _openRequest() => setState(() => _currentIndex = 2);

  // mock data for categories and designers
  final List<Map<String, String>> dressCategories = [
    {'title': 'سهرة', 'image': 'assets/images/evening.png'},
    {'title': 'زواج', 'image': 'assets/images/wedding.png'},
    {'title': 'حفل', 'image': 'assets/images/party.png'},
    {'title': 'غريب', 'image': 'assets/images/unique.png'},
    {'title': 'كاجوال', 'image': 'assets/images/casual.png'},
    {'title': 'سواريه', 'image': 'assets/images/bridal.png'},
    {'title': 'أحمر', 'image': 'assets/images/red.png'},
    {'title': 'أسود', 'image': 'assets/images/black.png'},
  ];

  // mock data for fashion designers
  final List<Map<String, String>> fashionDesigners = [
    {
      'name': 'مها ديزاين',
      'rating': '4.9',
      'category': 'فساتين سهرة',
      'coverImage': 'assets/images/evening.png',
      'avatarImage': 'assets/images/evening dress designer.png',
    },
    {
      'name': 'نوف ديزاين',
      'rating': '4.8',
      'category': 'فساتين زواج',
      'coverImage': 'assets/images/wedding.png',
      'avatarImage': 'assets/images/wedding dress designer.png',
    },
    {
      'name': 'خلود ديزاين',
      'rating': '4.7',
      'category': 'فساتين حفلات',
      'coverImage': 'assets/images/party.png',
      'avatarImage': 'assets/images/party dress designer.png',
    },
  ];

  // mock data for interior designers
  final List<Map<String, String>> interiorDesigners = [
    {
      'name': 'ليلى الزهراني',
      'rating': '4.9',
      'category': 'تصميم داخلي فاخر',
      'coverImage': 'assets/images/interiorDesign.jpg',
      'avatarImage': 'assets/images/wedding dress designer.png',
    },
    {
      'name': 'سارة المنصور',
      'rating': '4.8',
      'category': 'ديكور غرف النوم',
      'coverImage': 'assets/images/interiorDesign(1).jpg',
      'avatarImage': 'assets/images/interiorDesigner.png',
    },
    {
      'name': 'رنا العتيبي',
      'rating': '4.7',
      'category': 'تصميم مطابخ',
      'coverImage': 'assets/images/interiorDesign(2).jpg',
      'avatarImage': 'assets/images/wedding dress designer.png',
    },
    {
      'name': 'دانة الحربي',
      'rating': '4.6',
      'category': 'ديكور حدائق',
      'coverImage': 'assets/images/interiorDesign(3).jpg',
      'avatarImage': 'assets/images/interiorDesigner.png',
    },
  ];

  @override
  void dispose() {
    // Releases the controller when this screen is removed from the widget tree.
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Switches the main body based on the active navigation tab.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        drawer: AppDrawer(
          onTabSelected: (index) {
            // Drawer selections reuse the existing tab layout, including the bottom navigation.
            setState(() => _currentIndex = index);
          },
        ),
        body: AppBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: _currentIndex == 1
                        ? _buildSearchTab()
                        : _currentIndex == 2
                        ? const RequestDesignView()
                        : _currentIndex == 3
                        ? const MyOrdersView()
                        : _currentIndex == 4
                        ? const ProfileView()
                        : _currentIndex == 0
                        ? _buildHomeTab()
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Text(
                                'صفحة قيد الإنشاء',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 18,
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
        bottomNavigationBar: UserBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Changes tabs without adding a new route to the navigation stack.
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    // Combines the fashion and interior-design discovery sections.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionDivider('تصميم أزياء'),
        const SizedBox(height: 16),
        _buildSectionHeader('أنواع الفساتين', 'عرض الكل', () => _openSearch()),
        const SizedBox(height: 12),
        _buildCategoriesList(),
        const SizedBox(height: 24),
        _buildSectionHeader('أبرز المصممين', 'عرض الكل', () => _openSearch()),
        const SizedBox(height: 12),
        _buildDesignersList(fashionDesigners),
        const SizedBox(height: 32),
        _buildSectionDivider('تصميم ديكور'),
        const SizedBox(height: 16),
        _buildSectionHeader('أبرز مصممي الديكور', 'عرض الكل', () => _openSearch()),
        const SizedBox(height: 12),
        _buildDesignersList(interiorDesigners),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSearchTab() {
    // Shows either search guidance or live results based on the current query.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSearchBar(
          controller: _searchController,
          onChanged: () => setState(() {}),
          onClear: () {
            setState(() {
              _searchController.clear();
            });
          },
        ),
        const SizedBox(height: 24),

        if (_searchController.text.isNotEmpty)
          _buildSearchResultsView()
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: Text(
                'ابدأ البحث عن مصممتك المفضلة...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAppBar() {
    // Sub-pages use a back action that returns the user to the home tab.
    bool isSubPage = _currentIndex != 0;

    String pageTitle = 'Amber design'; 
    if (_currentIndex == 1) pageTitle = 'البحث';
    if (_currentIndex == 2) pageTitle = 'طلب تصميم';
    if (_currentIndex == 3) pageTitle = 'طلباتي';
    if (_currentIndex == 4) pageTitle = 'حسابي';

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textMuted.withOpacity(0.15), 
            width: 1.0, 
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(
                  isSubPage ? Icons.arrow_back : Icons.menu,
                  color: AppColors.textDark,
                  size: 28
                ),
                onPressed: () {
                  if (isSubPage) {
                    setState(() => _currentIndex = 0);
                  } else {
                    // 👇 3. أمر فتح القائمة الجانبية
                    Scaffold.of(context).openDrawer();
                  }
                },
              );
            }
          ),
          
          Text(
            pageTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              letterSpacing: isSubPage ? 0 : 1.2,
            ),
          ),
          
          isSubPage
              ? const SizedBox(width: 48) 
              : IconButton(
                  icon: const Icon(Icons.notifications_none, color: AppColors.textDark, size: 28),
                  // Opens the same notification dialog as the drawer menu item.
                  onPressed: () => showNotificationsDialog(context),
                ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.textMuted.withOpacity(0.8),
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),

        Container(
          width: 80,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.textMuted.withOpacity(0.8),
                Colors.transparent,
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String actionText, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList([List<Map<String, String>>? categories]) {
    final displayedCategories = categories ?? dressCategories;
    // Horizontal scrolling keeps the category strip compact on narrow screens.
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: displayedCategories.length,
        itemBuilder: (context, index) {
          final category = displayedCategories[index];
          return CategoryCard(
            title: category['title']!,
            image: category['image']!,
            onTap: () => _openSearch(category['title']!),
          );
        },
      ),
    );
  }

  Widget _buildDesignersList(List<Map<String, String>> designers) {
    // Disables nested scrolling because the parent page already scrolls.
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: designers.length,
      itemBuilder: (context, index) {
        final designer = designers[index];
        return DesignerCard(
          name: designer['name']!,
          rating: designer['rating']!,
          category: designer['category']!,
          coverImage: designer['coverImage']!,
          avatarImage: designer['avatarImage']!,
          onTap: _openRequest,
        );
      },
    );
  }

  Widget _buildSearchResultsView() {
    // Reads the latest query once so every result label uses the same value.
    final query = _searchController.text.trim().toLowerCase();
    final matchingCategories = dressCategories.where((category) {
      return category['title']!.toLowerCase().contains(query);
    }).toList();
    final matchingDesigners = [...fashionDesigners, ...interiorDesigners]
        .where((designer) =>
            designer['name']!.toLowerCase().contains(query) ||
            designer['category']!.toLowerCase().contains(query))
        .toList();

    if (matchingCategories.isEmpty && matchingDesigners.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Text(
            'لا توجد نتائج مطابقة لـ "$query"',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                title: Text(
                  matchingCategories.isNotEmpty
                      ? matchingCategories.first['title']!
                      : matchingDesigners.first['name']!,
                  style: const TextStyle(color: AppColors.textDark),
                ),
                visualDensity: VisualDensity.compact,
              ),
              Divider(color: Colors.white.withOpacity(0.5), height: 1),
              ListTile(
                leading: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                title: Text(
                  matchingDesigners.isNotEmpty
                      ? matchingDesigners.first['name']!
                      : matchingCategories.first['title']!,
                  style: const TextStyle(color: AppColors.textDark),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        Text(
          'نتائج البحث عن "$query"',
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),

        if (matchingCategories.isNotEmpty) const Text(
          'الفساتين',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        if (matchingCategories.isNotEmpty) const SizedBox(height: 12),
        if (matchingCategories.isNotEmpty) _buildCategoriesList(matchingCategories),

        const SizedBox(height: 24),

        if (matchingDesigners.isNotEmpty) const Text(
          'المصممون',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        if (matchingDesigners.isNotEmpty) const SizedBox(height: 12),
        ...matchingDesigners.map((designer) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MiniDesignerCard(
            name: designer['name']!,
            rating: designer['rating']!,
            category: designer['category']!,
            avatarImage: designer['avatarImage']!,
            onRequest: _openRequest,
          ),
        )),
      ],
    );
  }
}
