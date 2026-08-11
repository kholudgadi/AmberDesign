import 'package:flutter/material.dart';
import 'designer_dashboard_view.dart';
import '../widgets/designer_bottom_nav_bar.dart'; 
import 'designer_requests_screen.dart';

class DesignerHomeScreen extends StatefulWidget {
  const DesignerHomeScreen({super.key});

  @override
  State<DesignerHomeScreen> createState() => _DesignerHomeScreenState();
}

class _DesignerHomeScreenState extends State<DesignerHomeScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DesignerDashboardView(onTabChange: _changeTab), 
      const Center(child: Text('منتجاتي')), 
      const DesignerRequestsScreen(),
      const Center(child: Text('إدارة المتجر والمبيعات')), 
      const Center(child: Text('الملف الشخصي')), 
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: pages[_currentIndex],
        
        bottomNavigationBar: DesignerBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _changeTab,
        ),
      ),
    );
  }
}
