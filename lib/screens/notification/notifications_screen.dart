import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/notification_item.dart'; // Import NotificationItem
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Utiliser le modèle NotificationItem
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: "1",
      title: "Course Update!",
      message: "New chapter 'Advanced Python Async' added to your 'Python Pro' course.",
      timeAgo: "5 mins ago",
      iconData: Icons.school_outlined,
      iconBgColor: Colors.blue.shade100,
    ),
    NotificationItem(
      id: "2",
      title: "Quiz Reminder!",
      message: "Don't forget to complete the quiz for 'Data Science Basics - Module 2'.",
      timeAgo: "30 mins ago",
      iconData: Icons.quiz_outlined,
      iconBgColor: eduLearnPrimary.withOpacity(0.2),
    ),
    NotificationItem(
      id: "3",
      title: "Promotion!",
      message: "Get 50% off on 'Data Science Bootcamp'. Limited time offer!",
      timeAgo: "1 hr ago",
      iconData: Icons.sell_outlined,
      iconBgColor: Colors.green.shade100,
      isRead: true,
    ),
    NotificationItem(
      id: "4",
      title: "Certificate Earned!",
      message: "Congratulations! You've earned a certificate for 'Python Pro'.",
      timeAgo: "2 hrs ago",
      iconData: Icons.workspace_premium_outlined,
      iconBgColor: Colors.amber.shade100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: eduLearnBackground, // Thème global
      appBar: AppBar(
        // backgroundColor: eduLearnBackground, // Thème global
        // elevation: 0, // Thème global
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: eduLearnCardBg,
                shape: BoxShape.circle,
                boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3) ]
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack, size: 20),
            ),
          ),
        ),
        title: Text("Notifications"), // Thème global
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => !n.isRead)) // Afficher seulement s'il y a des non lues
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: eduLearnTextGrey),
              tooltip: "Mark all as read",
              onPressed: () {
                setState(() {
                  for (var notif in _notifications) {
                    notif.isRead = true;
                  }
                });
              },
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("No notifications yet", style: GoogleFonts.poppins(fontSize: 18, color: eduLearnTextGrey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      notification.isRead = true;
                    });
                    // TODO: Action on notification tap (ex: naviguer vers le cours, quiz, certificat)
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notification '${notification.title}' cliquée.")));
                  },
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
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 5)
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: notification.iconBgColor, // Couleur spécifique à la notif
                            shape: BoxShape.circle,
                          ),
                          child: Icon(notification.iconData, color: eduLearnTextBlack.withOpacity(0.7), size: 24),
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
                          notification.timeAgo,
                          style: GoogleFonts.poppins(fontSize: 11, color: eduLearnTextLightGrey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}