import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/data/models/notification_model.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationListItem({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xác định màu nền dựa trên nội dung thông báo
    Color backgroundColor = Colors.white;
    if (notification.content.toLowerCase().contains('tai nạn')) {
      backgroundColor = Color(0xFFFEE2E2); // Màu đỏ nhạt
    } else if (notification.content.toLowerCase().contains('trộm')) {
      backgroundColor = Color(0xFFF1F5F9); // Màu xám nhạt
    }

    // Format thời gian
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(notification.time);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon thông báo
                    Icon(
                      _getNotificationIcon(),
                      color: _getIconColor(),
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    // Tiêu đề thông báo
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: _getIconColor(),
                        ),
                      ),
                    ),
                    // Nút xóa thông báo
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: onDelete,
                      ),
                  ],
                ),
                SizedBox(height: 8),
                // Nội dung thông báo
                Text(
                  notification.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                // Thời gian
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    if (notification.content.toLowerCase().contains('tai nạn')) {
      return Icons.car_crash;
    } else if (notification.content.toLowerCase().contains('trộm')) {
      return Icons.warning_amber;
    } else {
      return Icons.notifications;
    }
  }

  Color _getIconColor() {
    if (notification.content.toLowerCase().contains('tai nạn')) {
      return Colors.red;
    } else if (notification.content.toLowerCase().contains('trộm')) {
      return Colors.orange;
    } else {
      return AppPalette.primaryColor;
    }
  }
}
