import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final Function(int) onTap;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUnread = notification['status'] == 'unread';
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnread ? Colors.blue.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isUnread ? Colors.blue : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification['message'] ?? '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _formatDateTime(notification['created_at']),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (isUnread) {
            onTap(notification['notification_id']);
          }
        },
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    
    try {
      final DateTime dt = DateTime.parse(dateTime);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dt);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return dateTime;
    }
  }
}