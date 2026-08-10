import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DesignerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DesignerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, 
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true, 
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4), 
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent, 
            selectedItemColor: AppColors.textDark,
            unselectedItemColor: AppColors.textMuted.withOpacity(0.5),
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal, 
              fontSize: 10,
            ),
            elevation: 0, 
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), 
                activeIcon: Icon(Icons.home), 
                label: 'الرئيسية'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined), 
                activeIcon: Icon(Icons.shopping_bag), 
                label: 'منتجاتي'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined), 
                activeIcon: Icon(Icons.assignment), 
                label: 'الطلبات'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined), 
                activeIcon: Icon(Icons.inventory_2), 
                label: 'الإدارة'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), 
                activeIcon: Icon(Icons.person), 
                label: 'الملف'
              ),
            ],
          ),
        ),
      ),
    );
  }
}