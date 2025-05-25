import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // Utiliser les couleurs centralisées

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final IconData iconData;
  final Color iconBgColor;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.iconData,
    this.iconBgColor = eduLearnPrimary,
    this.isRead = false,
  });
}