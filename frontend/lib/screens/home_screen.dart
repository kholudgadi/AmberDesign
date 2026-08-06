import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/catalog_service.dart';
import '../utils/app_colors.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeScreen({super.key, required this.user});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<({List<dynamic> categories, List<dynamic> items})> _content;
  final _searchController = TextEditingController();
  String? _selectedCategoryId;
  @override
  void initState() {
    super.initState();
    _content = CatalogService.instance.loadHome();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _content = CatalogService.instance.loadHome(
    query: _searchController.text,
    categoryId: _selectedCategoryId,
  ));

  void _selectCategory(String id) {
    setState(() {
      _selectedCategoryId = _selectedCategoryId == id ? null : id;
      _content = CatalogService.instance.loadHome(query: _searchController.text, categoryId: _selectedCategoryId);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _reload();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset('assets/images/Amber_Design_Logo.png', height: 54),
        actions: [
          IconButton(
            tooltip: 'حسابي',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccountScreen(initialUser: widget.user))),
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.textDark, size: 30),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text('مرحباً، ${widget.user['displayName'] ?? ''}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 4),
            const Text('اكتشف أحدث التصاميم والخدمات', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _reload(),
              decoration: InputDecoration(
                hintText: 'ابحث عن تصميم أو منتج',
                prefixIcon: IconButton(tooltip: 'بحث', onPressed: _reload, icon: const Icon(Icons.search)),
                suffixIcon: IconButton(tooltip: 'مسح البحث', onPressed: _clearSearch, icon: const Icon(Icons.close)),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 28),
            FutureBuilder<({List<dynamic> categories, List<dynamic> items})>(
              future: _content,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) return const Padding(padding: EdgeInsets.all(60), child: Center(child: CircularProgressIndicator()));
                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'تعذر تحميل الصفحة الرئيسية';
                  return Center(child: Column(children: [Text(message), const SizedBox(height: 12), OutlinedButton(onPressed: _reload, child: const Text('إعادة المحاولة'))]));
                }
                final data = snapshot.data!;
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('التصنيفات', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  SizedBox(height: 104, child: data.categories.isEmpty
                    ? const Center(child: Text('لا توجد تصنيفات بعد'))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, index) {
                          final category = data.categories[index] as Map<String, dynamic>;
                          final id = category['id'].toString();
                          final selected = _selectedCategoryId == id;
                          return InkWell(
                            onTap: () => _selectCategory(id),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 125, padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.textDark : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: selected ? AppColors.textDark : Colors.transparent, width: 2),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.auto_awesome_outlined, color: selected ? Colors.white : AppColors.textDark),
                                const SizedBox(height: 8),
                                Text(category['nameAr']?.toString() ?? category['nameEn']?.toString() ?? '', textAlign: TextAlign.center, maxLines: 2, style: TextStyle(color: selected ? Colors.white : AppColors.textDark)),
                              ]),
                            ),
                          );
                        },
                      )),
                  const SizedBox(height: 28),
                  const Text('أحدث التصاميم', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  if (data.items.isEmpty)
                    Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Column(children: [Icon(Icons.inventory_2_outlined, size: 42, color: AppColors.textMuted), SizedBox(height: 10), Text('لا توجد منتجات معتمدة بعد'), Text('ستظهر هنا بعد إضافتها واعتمادها من الإدارة', style: TextStyle(color: AppColors.textMuted))]))
                  else
                    LayoutBuilder(builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 600 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .78),
                        itemBuilder: (_, index) {
                          final item = data.items[index] as Map<String, dynamic>;
                          final images = item['images'] as List<dynamic>? ?? const [];
                          return Card(clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            Expanded(child: images.isEmpty ? const ColoredBox(color: Color(0xFFEDE7DD), child: Icon(Icons.image_outlined)) : Image.network(images.first.toString(), fit: BoxFit.cover)),
                            Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['titleAr']?.toString() ?? item['titleEn']?.toString() ?? '', maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${item['price'] ?? 0} ر.س', style: const TextStyle(color: AppColors.textMuted))])),
                          ]));
                        },
                      );
                    }),
                ]);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
