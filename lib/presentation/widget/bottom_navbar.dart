import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

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
          color: Color(0xFF6D8D6F),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pill-shaped indicator
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
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
            
            // Navigation items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildBottomNavItem(
                  icon: Icons.sell_outlined,
                  activeIcon: Icons.sell,
                  label: 'Jual Barang',
                  index: 1,
                ),
                _buildBottomNavItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag,
                  label: 'Beli Barang',
                  index: 2,
                ),
                _buildBottomNavItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  label: 'Edukasi',
                  index: 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getPillPosition() {
    double screenWidth = MediaQuery.of(context).size.width;
    double navBarWidth = screenWidth - 40; // 20px padding on each side
    double itemWidth = navBarWidth / 4;
    
    // Calculate the center position for each tab
    switch (widget.currentIndex) {
      case 0:
        return itemWidth * 0 + (itemWidth - _getPillWidth()) / 2;
      case 1:
        return itemWidth * 1 + (itemWidth - _getPillWidth()) / 2;
      case 2:
        return itemWidth * 2 + (itemWidth - _getPillWidth()) / 2;
      case 3:
        return itemWidth * 3 + (itemWidth - _getPillWidth()) / 2;
      default:
        return 0;
    }
  }

  double _getPillWidth() {
    double screenWidth = MediaQuery.of(context).size.width;
    double navBarWidth = screenWidth - 40;
    return navBarWidth / 4 * 0.8; // 80% of the item width
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    bool isActive = widget.currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onTap(index);
          _animationController.forward().then((_) {
            _animationController.reset();
          });
        },
        child: Container(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(isActive ? 2 : 0),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: Colors.white,
                  size: isActive ? 26 : 22,
                ),
              ),
              SizedBox(height: 4),
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
      ),
    );
  }
}