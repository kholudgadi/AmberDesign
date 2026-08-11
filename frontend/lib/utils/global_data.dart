import 'package:flutter/material.dart';

class GlobalData {
  static List<Map<String, dynamic>> myNotifications = [
    {'title': 'نوف الأحمدي قبلت طلبك', 'sub': 'فستان سهرة ذهبي', 'time': 'منذ ٥ د', 'icon': 0xe5fc, 'iconColor': 0xFF000000, 'isRead': false},
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

  static Map<String, dynamic> designerProfile = {
    'name': 'نوف الأحمدي',
    'role': 'مصممة أزياء',
    'city': 'الرياض',
    'bio': 'تخصصي في فساتين السهرة والمناسبات الراقية.',
    'rating': 4.8,
    'reviewCount': 42,
    'newOrders': 6,
    'pendingPurchases': 1,
    'portfolioImages': [
      'https://images.unsplash.com/photo-1542295669297-4d352b042bca?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fGRyZXNzZXN8ZW58MHx8MHx8fDA%3D',
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=200',
      'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?q=80&w=200',
      'https://images.unsplash.com/photo-1733209484732-6b094322a89f?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTJ8fGRyZXNzZXN8ZW58MHx8MHx8fDA%3D',
    ]
  };

  static List<Map<String, dynamic>> designerActivities = [
    {
      'title': 'طلب خاص جديد من منى القحطاني',
      'sub': 'فستان سهرة احترافي',
      'time': 'منذ ٥ د',
      'icon': Icons.assignment_outlined, // assignment icon
      'color': 0xFF6A5AE0,
    },
    {
      'title': 'طلب شراء من ليلى الخالدي',
      'sub': 'فستان سهرة ذهبي',
      'time': 'منذ ٢٠ د',
      'icon': Icons.inventory_2_outlined, // inventory_2 icon
      'color': 0xFFE08E36,
    },
    {
      'title': 'رسالة من ليلى الخالدي',
      'sub': 'متى يصل الطلب؟',
      'time': 'منذ ١ س',
      'icon': Icons.chat_bubble_outline, // chat_bubble icon
      'color': 0xFF757575,
    },
    {
      'title': 'تقييم من سارة الحربي',
      'sub': 'ممتازة',
      'time': 'أمس',
      'icon': Icons.star_outline, // star icon
      'color': 0xFFFFB300,
    },
  ];

  static List<Map<String, dynamic>> designerManagementOrders = [
    {
      'id': '#101',
      'title': 'فستان سهرة احترافي',
      'clientName': 'منى القحطاني',
      'price': '٤٠٠٠ ر.س',
      'status': 'قيد التنفيذ',
      'image': 'https://images.unsplash.com/photo-1733731402869-57e0cce24aea?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzN8fGRyZXNzZXN8ZW58MHx8MHx8fDA%3D',
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
      'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=200',
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
      'image': 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?q=80&w=200',
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
      'image': 'https://images.unsplash.com/photo-1623609163841-5e69d8c62cc7?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTd8fGRyZXNzZXN8ZW58MHx8MHx8fDA%3D',
      'clientAvatar': 'https://randomuser.me/api/portraits/women/90.jpg',
      'date': '٢٠ يونيو ٢٠٢٥',
      'currentStep': 0,
    },
  ];
}