import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  
  // Data untuk setiap navigation item
  List<NavItem> get navItems => [
    NavItem(
      index: 0,
      inactiveIcon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItem(
      index: 1,
      inactiveIcon: Icons.sell_outlined,
      activeIcon: Icons.sell_rounded,
      label: 'Jual Barang',
    ),
    NavItem(
      index: 2,
      inactiveIcon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Beli Barang',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated sliding pill indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _getPillPosition(),
            top: 8,
            child: Container(
              width: _getPillWidth(),
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // Navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navItems.map((item) => _buildNavItem(item)).toList(),
          ),
        ],
      ),
    );
  }

  // Hitung posisi pill berdasarkan currentIndex
  double _getPillPosition() {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth - 40; // Total margin 40 (20 kiri + 20 kanan)
    double itemWidth = containerWidth / navItems.length; // Width per item
    double pillWidth = _getPillWidth();
    
    // Posisi tengah setiap item minus setengah lebar pill
    return (widget.currentIndex * itemWidth) + (itemWidth - pillWidth) / 2;
  }

  double _getPillWidth() {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth - 40;
    double itemWidth = containerWidth / navItems.length;
    return itemWidth * 0.85; // 85% dari lebar item untuk padding yang pas
  }

  Widget _buildNavItem(NavItem item) {
    bool isActive = widget.currentIndex == item.index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onTap(item.index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon dengan transisi sederhana
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? item.activeIcon : item.inactiveIcon,
                  color: Colors.white,
                  size: isActive ? 26 : 22,
                ),
              ),
              const SizedBox(height: 4),
              // Label dengan style yang berubah
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Class helper untuk data navigation item
class NavItem {
  final int index;
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String label;

  NavItem({
    required this.index,
    required this.inactiveIcon,
    required this.activeIcon,
    required this.label,
  });
}