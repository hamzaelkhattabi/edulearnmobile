import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Utiliser les constantes de couleurs
const Color primaryAppColor = Color(0xFFF45B69);
const Color lightBackground = Color(0xFFF9FAFC);
const Color cardBackgroundColor = Colors.white;
const Color textDarkColor = Color(0xFF1F2024);
const Color textGreyColor = Color(0xFF6A737D);
const double kDefaultBorderRadius = 15.0;

class NotificationItem {
  final String title;
  final String message;
  final String timeAgo;
  final IconData icon;
  final Color iconBgColor;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.icon,
    this.iconBgColor = primaryAppColor,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: "Course Update!",
      message: "New lesson 'Advanced Python' added to your course.",
      timeAgo: "5 mins ago",
      icon: Icons.school_outlined,
      iconBgColor: Colors.blue.shade100,
    ),
    NotificationItem(
      title: "Promotion!",
      message: "Get 50% off on 'Data Science Bootcamp'.",
      timeAgo: "1 hr ago",
      icon: Icons.sell_outlined,
      iconBgColor: Colors.green.shade100,
      isRead: true,
    ),
    NotificationItem(
      title: "Reminder",
      message: "Your subscription is ending soon. Renew now!",
      timeAgo: "3 hrs ago",
      icon: Icons.notifications_active_outlined,
      iconBgColor: Colors.orange.shade100,
    ),
     NotificationItem(
      title: "System Maintenance",
      message: "App will be down for maintenance on 25th Dec.",
      timeAgo: "1 day ago",
      icon: Icons.build_circle_outlined,
      iconBgColor: Colors.grey.shade300,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                shape: BoxShape.circle,
                boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3,) ]
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: textDarkColor, size: 20),
            ),
          ),
        ),
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(color: textDarkColor, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: textGreyColor),
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
                  Text("No notifications yet", style: GoogleFonts.poppins(fontSize: 18, color: textGreyColor)),
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
                    // TODO: Action on notification tap
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: notification.isRead ? cardBackgroundColor : primaryAppColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                      border: notification.isRead ? Border.all(color: Colors.grey.shade200, width: 0.8) : Border.all(color: primaryAppColor.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 1,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: notification.iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(notification.icon, color: textDarkColor.withOpacity(0.7), size: 24),
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
                                  color: textDarkColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.message,
                                style: GoogleFonts.poppins(fontSize: 13, color: textGreyColor),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          notification.timeAgo,
                          style: GoogleFonts.poppins(fontSize: 11, color: textGreyColor),
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