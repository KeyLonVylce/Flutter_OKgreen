import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double? borderRadius;

  const AppIcon({
    Key? key,
    required this.icon,
    this.size = 24.0,
    this.color,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
      ),
      child: Icon(
        icon,
        size: size,
        color: color ?? Colors.grey[600],
      ),
    );
  }
}

// Header icons untuk beranda
class HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final double size;
  final bool isProfileIcon;

  const HeaderIcon({
    Key? key,
    required this.icon,
    this.onTap,
    this.color = Colors.white,
    this.size = 24.0,
    this.isProfileIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isProfileIcon) {
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}

// Custom icons untuk setting menu
class SettingIcons {
  static const IconData user = Icons.person;
  static const IconData privacy = Icons.security;
  static const IconData points = Icons.stars;
  static const IconData contact = Icons.contact_support;
  static const IconData history = Icons.history;
  static const IconData logout = Icons.logout;
}

// Icons untuk header beranda
class HeaderIcons {
  static const IconData notification = Icons.notifications_outlined;
  static const IconData profile = Icons.person;
}