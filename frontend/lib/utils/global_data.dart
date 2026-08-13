import 'package:flutter/material.dart';
class GlobalData {
  
  static List<Map<String, dynamic>> myNotifications = [
    {
      'title': 'نوف الأحمدي قبلت طلبك',
      'sub': 'فستان سهرة ذهبي',
      'time': 'منذ ٥ د',
      'icon': 0xe5fc,
      'iconColor': 0xFF000000,
      'isRead': false,
    },
  ];

  static List<Map<String, dynamic>> myOrders = [
    {
      'id': '#12345',
      'title': 'فستان سهرة',
      'service': 'تصميم أزياء',
      'designer': 'مها ديزاين',
      'date': '13 يوليو 2025',
      'price': '٤٨٠ ر.س',
      'status': 'قيد التنفيذ',
      'statusColor': const Color(0xFF1976D2),
      'image': 'assets/images/evening.png',
    },
    {
      'id': '#12346',
      'title': 'فستان زواج',
      'service': 'تصميم أزياء',
      'designer': 'نوف ديزاين',
      'date': '10 يوليو 2025',
      'price': '٨٥٠ ر.س',
      'status': 'مكتمل',
      'statusColor': const Color(0xFF388E3C),
      'image': 'assets/images/wedding.png',
    },
    {
      'id': '#12347',
      'title': 'فستان حفل',
      'service': 'تصميم أزياء',
      'designer': 'خلود ديزاين',
      'date': '5 يوليو 2025',
      'price': '٣٢٠ ر.س',
      'status': 'قيد المراجعة',
      'statusColor': const Color(0xFFF57C00),
      'image': 'assets/images/party.png',
    },
    {
      'id': '#12348',
      'title': 'فستان غريب',
      'service': 'تصميم أزياء',
      'designer': 'أمل ديزاين',
      'date': '1 يوليو 2025',
      'price': '٦٠٠ ر.س',
      'status': 'تم التقديم',
      'statusColor': const Color(0xFF616161),
      'image': 'assets/images/unique.png',
    },
  ];

  static List<Map<String, dynamic>> designerNewRequests = [
    {
      'id': 'REQ001',
      'title': 'فستان زفاف مميز',
      'clientName': 'سارة الحربي',
      'clientAvatar': 'https://randomuser.me/api/portraits/women/12.jpg',
      'date': '١٥ يوليو ٢٠٢٥',
      'category': 'زواج',
      'description':
          'أبحث عن فستان زفاف بتفاصيل دانتيل فرنسي وذيل طويل، اللون أبيض مع لمسات فضية.',
      'budget': '٨٠٠٠ - ١٢٠٠٠ ر.س',
      'city': 'الرياض',
      'colors': 'أبيض، فضي',
      'fabric': 'دانتيل، ساتان',
      'deadline': '١ سبتمبر ٢٠٢٥',
      'type': 'عام',
      'images': [
        'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?q=80&w=400',
        'https://images.unsplash.com/photo-1566160983802-124b89bd2999?q=80&w=200',
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=200',
      ],
    },
    {
      'id': 'REQ002',
      'title': 'فستان فريد وجريء',
      'clientName': 'هدى السبيعي',
      'clientAvatar': 'https://randomuser.me/api/portraits/women/33.jpg',
      'date': '١١ يوليو ٢٠٢٥',
      'category': 'غريب',
      'description':
          'تصميم إبداعي بطابع فني يعكس شخصيتي القوية، ألوان جريئة وقصة غير معتادة.',
      'budget': '٤٠٠٠ - ١٦٠٠٠ ر.س',
      'city': 'الرياض',
      'colors': 'أحمر، أسود، ذهبي',
      'fabric': 'مخمل، تل',
      'deadline': '٢٠ أغسطس ٢٠٢٥',
      'type': 'عام',
      'images': [
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=400',
        'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?q=80&w=200',
        'https://images.unsplash.com/photo-1568252542512-9fe8ef1cb9db?q=80&w=200',
      ],
    },
    {
      'id': 'REQ003',
      'title': 'فستان تخرج أنيق',
      'clientName': 'نورة العبدالله',
      'clientAvatar': 'https://randomuser.me/api/portraits/women/45.jpg',
      'date': '٢٢ يوليو ٢٠٢٥',
      'category': 'حفلات',
      'description':
          'أرغب بتصميم فستان تخرج يجمع بين الرقي والبساطة، مع إضافة لمسات كريستال خفيفة على الأكتاف ليعطي طابع رسمي وفخم.',
      'budget': '٢٠٠٠ - ٣٥٠٠ ر.س',
      'city': 'جدة',
      'colors': 'أسود، فضي',
      'fabric': 'كريب، شيفون',
      'deadline': '١٥ أغسطس ٢٠٢٥',
      'type': 'خاص',
      'images': [
        'https://images.unsplash.com/photo-1566160983802-124b89bd2999?q=80&w=400',
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=200',
        'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?q=80&w=200',
      ],
    },
    {
      'id': 'REQ004',
      'title': 'تصميم فستان سهرة كلاسيكي',
      'clientName': 'شهد المطيري',
      'clientAvatar': 'https://randomuser.me/api/portraits/women/22.jpg',
      'date': '٢٥ يوليو ٢٠٢٥',
      'category': 'سهرة',
      'description':
          'محتاجة فستان سهرة بتطريز يدوي دقيق على الأكمام، ويكون مناسب لزواج أختي، أبغى قصة تبرز الخصر وتكون مريحة بالحركة.',
      'budget': '٣٠٠٠ - ٥٠٠٠ ر.س',
      'city': 'الدمام',
      'colors': 'كحلي، ذهبي',
      'fabric': 'حرير مغسول، دانتيل',
      'deadline': '١٠ سبتمبر ٢٠٢٥',
      'type': 'خاص',
      'images': [
        'https://images.unsplash.com/photo-1568252542512-9fe8ef1cb9db?q=80&w=400',
        'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?q=80&w=200',
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=200',
      ],
    },
  ];

  static List<Map<String, dynamic>> designerManagementOrders = [
    {
      'id': '#101',
      'title': 'فستان سهرة احترافي',
      'clientName': 'منى القحطاني',
      'price': '٤٠٠٠ ر.س',
      'status': 'قيد التنفيذ',
      'image':
          'https://images.unsplash.com/photo-1733731402869-57e0cce24aea?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzN8fGRyZXNzZXN8ZW58MHx8MHx8fDA%3D',
      'clientAvatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      'date': '٥ يوليو ٢٠٢٥',
      'currentStep': 3,
    },
    {
      'id': '#102',
      'title': 'فستان حفل عصري',
      'clientName': 'لمياء العتيبي',
      'price': '٢٥٠٠ ر.س',
      'status': 'بانتظار رد العميل',
      'image':
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=200',
      'clientAvatar': 'https://randomuser.me/api/portraits/women/68.jpg',
      'date': '٤ يوليو ٢٠٢٥',
      'currentStep': 1,
    },
    {
      'id': '#103',
      'title': 'فستان زفاف مميز',
      'clientName': 'سارة الحربي',
      'price': '١٠٠٠٠ ر.س',
      'status': 'مكتمل',
      'image':
          'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?q=80&w=200',
      'clientAvatar': 'https://randomuser.me/api/portraits/women/12.jpg',
      'date': '١ يوليو ٢٠٢٥',
      'currentStep': 4,
    },
    {
      'id': '#104',
      'title': 'تصميم فستان سهرة',
      'clientName': 'نورة السالم',
      'price': '٣٥٠٠ ر.س',
      'status': 'قيد الانتظار',
      'image':
          'https://images.unsplash.com/photo-1623609163841-5e69d8c62cc7?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTd8fGRyZXNzZXN8ZW58MHx8MHx8fDA%3D',
      'clientAvatar': 'https://randomuser.me/api/portraits/women/90.jpg',
      'date': '٢٠ يونيو ٢٠٢٥',
      'currentStep': 0,
    },
  ];

  static Map<String, dynamic> designerProfile = {
    'name': 'نوف الأحمدي',
    'role': 'مصممة أزياء',
    'city': 'الرياض',
    'bio': 'تخصصي في فساتين السهرة والمناسبات الراقية.',
    'rating': 4.8,
    'reviewCount': 42,
    'newOrders': designerNewRequests.length,
    'pendingPurchases': designerManagementOrders
        .where((order) => order['status'] == 'قيد الانتظار')
        .length,
    'portfolioImages': [
      'https://images.unsplash.com/photo-1566160983802-124b89bd2999?q=80&w=200',
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=200',
      'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?q=80&w=200',
      'https://images.unsplash.com/photo-1568252542512-9fe8ef1cb9db?q=80&w=200',
    ],
  };

  static List<Map<String, dynamic>> designerActivities = [
    {
      'title': 'طلب خاص جديد من منى القحطاني',
      'sub': 'فستان سهرة احترافي',
      'time': 'منذ ٥ د',
      'icon': Icons.assignment_outlined,
      'color': 0xFF6A5AE0,
    },
    {
      'title': 'طلب شراء من ليلى الخالدي',
      'sub': 'فستان سهرة ذهبي',
      'time': 'منذ ٢٠ د',
      'icon': Icons.inventory_2_outlined,
      'color': 0xFFE08E36,
    },
    {
      'title': 'رسالة من ليلى الخالدي',
      'sub': 'متى يصل الطلب؟',
      'time': 'منذ ١ س',
      'icon': Icons.chat_bubble_outline,
      'color': 0xFF757575,
    },
    {
      'title': 'تقييم من سارة الحربي',
      'sub': 'ممتازة',
      'time': 'أمس',
      'icon': Icons.star_outline,
      'color': 0xFFFFB300,
    },
  ];
}
