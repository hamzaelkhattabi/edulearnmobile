// lib/models/notification_model.dart
import 'package:flutter/material.dart'; // Pour IconData
import '../../utils/app_colors.dart'; // Pour les couleurs (ou les passer en paramètre)

enum NotificationType { courseUpdate, quizReminder, promotion, certificateEarned, forumReply, unknown }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  final int? relatedEntityId; // ex: courseId, quizId, certificateId

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationType.unknown,
    this.relatedEntityId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType parsedType;
    switch(json['type_notification']?.toLowerCase()) {
        case 'course_update': parsedType = NotificationType.courseUpdate; break;
        case 'quiz_reminder': parsedType = NotificationType.quizReminder; break;
        // etc.
        default: parsedType = NotificationType.unknown;
    }

    return NotificationModel(
      id: json['id'].toString(), // L'ID de la notif dans la BDD
      title: json['titre'],
      message: json['message'],
      createdAt: DateTime.parse(json['date_creation']),
      isRead: json['est_lu'] ?? false,
      type: parsedType,
      relatedEntityId: json['entite_liee_id'],
    );
  }

  // Logique pour obtenir l'icône et la couleur basée sur le type (peut être dans l'UI)
  IconData get iconData {
    switch (type) {
      case NotificationType.courseUpdate: return Icons.school_outlined;
      case NotificationType.quizReminder: return Icons.quiz_outlined;
      case NotificationType.promotion: return Icons.sell_outlined;
      case NotificationType.certificateEarned: return Icons.workspace_premium_outlined;
      case NotificationType.forumReply: return Icons.chat_bubble_outline_rounded;
      default: return Icons.notifications_none_outlined;
    }
  }

  Color get iconBgColor {
     switch (type) {
      case NotificationType.courseUpdate: return Colors.blue.shade100;
      case NotificationType.quizReminder: return eduLearnPrimary.withOpacity(0.2);
      case NotificationType.promotion: return Colors.green.shade100;
      case NotificationType.certificateEarned: return Colors.amber.shade100;
      case NotificationType.forumReply: return Colors.purple.shade100;
      default: return Colors.grey.shade200;
    }
  }

  String get timeAgo { // Simplifié, utiliser `timeago` package pour une meilleure implémentation
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 1) return '${difference.inDays} jours';
    if (difference.inHours > 1) return '${difference.inHours} h';
    if (difference.inMinutes > 1) return '${difference.inMinutes} min';
    return 'maintenant';
  }
}