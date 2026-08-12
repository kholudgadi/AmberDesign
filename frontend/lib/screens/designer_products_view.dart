import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/designer_service.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class DesignerProductsView extends StatefulWidget {
  const DesignerProductsView({super.key});
  @override
  State<DesignerProductsView> createState() => _DesignerProductsViewState();
}

class _DesignerProductsViewState extends State<DesignerProductsView> {
  late Future<List<Map<String, dynamic>>> _items;
  @override
  void initState() { super.initState(); _reload(); }
  void _reload() => _items = DesignerService.instance.myItems();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('منتجاتي وخدماتي'), centerTitle: true, actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))]),
    body: DesignerAppBackground(child: SafeArea(child: FutureBuilder<List<Map<String, dynamic>>>(future: _items, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: OutlinedButton(onPressed: () => setState(_reload), child: const Text('تعذر التحميل — إعادة المحاولة')));
      final items = snapshot.data!;
      return RefreshIndicator(onRefresh: () async => setState(_reload), child: ListView(padding: const EdgeInsets.fromLTRB(24, 18, 24, 100), children: [
        if (items.isEmpty) Padding(padding: const EdgeInsets.all(40), child: Column(children: [const Icon(Icons.inventory_2_outlined, size: 50), const SizedBox(height: 12), const Text('لا توجد منتجات حقيقية بعد'), const SizedBox(height: 12), FilledButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('إضافة منتج أو خدمة'))])),
        ...items.map((item) { final images = item['images'] as List<dynamic>? ?? const []; return Padding(padding: const EdgeInsets.only(bottom: 14), child: DesignerGlassCard(padding: const EdgeInsets.all(14), borderRadius: 22, child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: images.isEmpty ? Container(width: 76, height: 76, color: Colors.black12, child: const Icon(Icons.image_outlined)) : Image.network(images.first.toString(), width: 76, height: 76, fit: BoxFit.cover)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['titleAr']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('${item['price']} ${item['currency']}', style: const TextStyle(fontWeight: FontWeight.bold)), Text(item['moderationStatus'] == 'approved' && item['active'] == true ? 'منشور' : 'بانتظار المراجعة', style: TextStyle(color: item['moderationStatus'] == 'approved' ? Colors.green : Colors.orange))]))]))); }),
      ]));
    }))),
  );

  Future<void> _addItem() async {
    final categories = await DesignerService.instance.categories();
    if (!mounted || categories.isEmpty) return;
    final title = TextEditingController(), description = TextEditingController(), price = TextEditingController(), image = TextEditingController();
    String categoryId = categories.first['id'].toString();
    String type = 'service';
    final saved = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(title: const Text('إضافة منتج أو خدمة'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField(value: type, items: const [DropdownMenuItem(value: 'service', child: Text('خدمة')), DropdownMenuItem(value: 'product', child: Text('منتج'))], onChanged: (value) => setDialogState(() => type = value!)),
      DropdownButtonFormField(value: categoryId, items: categories.map((row) => DropdownMenuItem(value: row['id'].toString(), child: Text(row['nameAr'].toString()))).toList(), onChanged: (value) => setDialogState(() => categoryId = value!)),
      TextField(controller: title, decoration: const InputDecoration(labelText: 'العنوان')), TextField(controller: description, decoration: const InputDecoration(labelText: 'الوصف')), TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر')), TextField(controller: image, decoration: const InputDecoration(labelText: 'رابط الصورة HTTPS')),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حفظ'))])));
    if (saved != true) return;
    try {
      await DesignerService.instance.createItem({'type': type, 'titleAr': title.text.trim(), 'titleEn': title.text.trim(), 'descriptionAr': description.text.trim(), 'descriptionEn': description.text.trim(), 'categoryId': categoryId, 'price': double.parse(price.text), 'currency': 'SAR', 'images': [image.text.trim()], 'tags': <String>[], 'colors': <String>[], 'styles': <String>[]});
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ وإرساله للمراجعة'))); setState(_reload); }
    } on Object catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error is ApiException ? error.message : 'تحقق من البيانات المدخلة'))); }
  }
}
