/*
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../models/notification_model.dart'; // Utilise le NotificationModel défini précédemment
import '../../utils/app_colors.dart';
import '../../services/notification_service.dart'; // Importer le service

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  Future<List<NotificationModel>>? _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.getMyNotifications();
    });
  }

  Future<void> _markAllAsRead(List<NotificationModel> notifications) async {
    // TODO: Appeler l'API pour marquer toutes les notifications comme lues
    // await _notificationService.markAllAsRead();
    // Mettre à jour l'UI localement ou recharger
    setState(() {
      for (var notif in notifications) {
        // notif.isRead = true; // Ne pas modifier directement le modèle du FutureBuilder
      }
      _loadNotifications(); // Recharger pour obtenir l'état frais
    });
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marquage multiple à implémenter.")));
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    // TODO: Appeler l'API pour marquer CETTE notification comme lue
    // await _notificationService.markAsRead(notification.id);
    // Mettre à jour l'UI localement ou recharger
     setState(() {
        // notification.isRead = true;
        _loadNotifications();
     });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Marquer '${notification.title}' lu à implémenter.")));
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Marquer comme lu
    if (!notification.isRead) {
        _markAsRead(notification);
    }
    // Logique de navigation basée sur notification.type et notification.relatedEntityId
    switch (notification.type) {
        case NotificationType.courseUpdate:
        case NotificationType.quizReminder: // si lié à un cours
        // Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(courseId: notification.relatedEntityId)));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Naviguer vers entité: ${notification.relatedEntityId} (${notification.type})")));
        break;
        // Gérer d'autres types
        default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notification '${notification.title}' cliquée.")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: eduLearnCardBg, shape: BoxShape.circle,
                boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3) ]
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack, size: 20),
            ),
          ),
        ),
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}", style: GoogleFonts.poppins()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("No notifications yet", style: GoogleFonts.poppins(fontSize: 18, color: eduLearnTextGrey)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;
          bool hasUnread = notifications.any((n) => !n.isRead);

          return Column(
            children: [
              if (hasUnread)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _markAllAsRead(notifications),
                      child: const Text("Mark all as read"),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return InkWell(
                      onTap: () => _handleNotificationTap(notification),
                      borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: notification.isRead ? eduLearnCardBg : eduLearnPrimary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                          border: Border.all(
                            color: notification.isRead ? Colors.grey.shade200 : eduLearnPrimary.withOpacity(0.3),
                            width: 0.8
                          ),
                          boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 5) ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: notification.iconBgColor, // Utilise le getter du modèle
                                shape: BoxShape.circle,
                              ),
                              child: Icon(notification.iconData, color: eduLearnTextBlack.withOpacity(0.7), size: 24), // Utilise le getter
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: eduLearnTextBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.message,
                                    style: GoogleFonts.poppins(fontSize: 13, color: eduLearnTextGrey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              notification.timeAgo, // Utilise le getter
                              style: GoogleFonts.poppins(fontSize: 11, color: eduLearnTextLightGrey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/notification_model.dart';
import '../../utils/app_colors.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  Future<List<NotificationModel>>? _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.getMyNotifications();
    });
  }

  Future<void> _markAllAsRead(List<NotificationModel> notifications) async {
    setState(() {
      _loadNotifications();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Marquage multiple à implémenter.")),
    );
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    setState(() {
      _loadNotifications();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Marquer '${notification.title}' lu à implémenter.")),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      _markAsRead(notification);
    }
    switch (notification.type) {
      case NotificationType.courseUpdate:
      case NotificationType.quizReminder:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Naviguer vers entité: ${notification.relatedEntityId} (${notification.type})")),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notification '${notification.title}' cliquée.")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: eduLearnCardBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack, size: 20),
            ),
          ),
        ),
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}", style: GoogleFonts.poppins()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("No notifications yet", style: GoogleFonts.poppins(fontSize: 18, color: eduLearnTextGrey)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;
          bool hasUnread = notifications.any((n) => !n.isRead);

          return Column(
            children: [
              if (hasUnread)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _markAllAsRead(notifications),
                      child: const Text("Mark all as read"),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      onTap: () => _handleNotificationTap(notification),
                      tileColor: notification.isRead ? eduLearnCardBg : eduLearnPrimary.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                        side: BorderSide(
                          color: notification.isRead
                              ? Colors.grey.shade200
                              : eduLearnPrimary.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: notification.iconBgColor,
                        child: Icon(notification.iconData, color: eduLearnTextBlack.withOpacity(0.7)),
                      ),
                      title: Text(
                        notification.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: eduLearnTextBlack,
                        ),
                      ),
                      subtitle: Text(
                        notification.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(color: eduLearnTextGrey),
                      ),
                      trailing: Text(
                        notification.timeAgo,
                        style: GoogleFonts.poppins(fontSize: 11, color: eduLearnTextLightGrey),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
