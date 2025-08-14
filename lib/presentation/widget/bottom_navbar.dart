import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
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
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _getPillPosition(),
              top: 8,
              child: Container(
                width: _getPillWidth(),
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _buildBottomNavItem(Icons.sell_outlined, Icons.sell, 'Jual Barang', 1),
                _buildBottomNavItem(Icons.shopping_bag_outlined, Icons.shopping_bag, 'Beli Barang', 2),
                _buildBottomNavItem(Icons.school_outlined, Icons.school, 'Edukasi', 3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getPillPosition() {
    double screenWidth = MediaQuery.of(context).size.width;
    double navBarWidth = screenWidth - 40;
    double itemWidth = navBarWidth / 4;
    return widget.currentIndex * itemWidth + (itemWidth - _getPillWidth()) / 2;
  }

  double _getPillWidth() {
    double screenWidth = MediaQuery.of(context).size.width;
    double navBarWidth = screenWidth - 40;
    return navBarWidth / 4 * 0.8;
  }

  Widget _buildBottomNavItem(IconData icon, IconData activeIcon, String label, int index) {
    bool isActive = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onTap(index);
          _animationController.forward().then((_) => _animationController.reset());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isActive ? 2 : 0),
              child: Icon(isActive ? activeIcon : icon, color: Colors.white, size: isActive ? 26 : 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
