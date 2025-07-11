import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// This helper function is fine, no changes needed.
Color _getCategoryNotificationColor(String category) {
  switch (category.toLowerCase()) {
    case 'home': return Color(0xFF42A5F5); // Blue
    case 'work': return Color(0xFF8D6E63); // Brown
    case 'focus': return Color(0xFFAB47BC); // Purple
    case 'health': return Color(0xFF66BB6A); // Green
    // New Categories
    case 'game': return Color(0xFFFFa726);   // Orange
    case 'chores': return Color(0xFF26A69A);  // Teal
    case 'data': return Color(0xFF5C6BC0);   // Indigo
    default: return Color(0xFFBDBDBD);       // Grey
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // --- FIX #1: Define the Notification Channel ---
  // We define the channel here so we can use it both for creation and for showing notifications.
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'functional_focus_ongoing_channel', // id
    'Functional Focus Ongoing Task', // title
    description: 'Notification for the currently focused task.', // description
    importance: Importance.low, // Use low importance for persistent, non-intrusive notifications
    showBadge: false,
  );

  Future<void> init() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // --- FIX #1 (continued): Create the Notification Channel ---
    // This tells the Android system to register our channel.
    // It's safe to call this every time the app starts.
    await androidImplementation?.createNotificationChannel(channel);

    // This part is good, it requests permission at runtime.
    await androidImplementation?.requestNotificationsPermission();

    // Use the standard launcher icon for initialization. This is correct.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
        
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showPersistentNotification(String title, String body, String category) async {
    final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        summaryText: '',
        htmlFormatSummaryText: true);
    
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id, // Use the channel ID from our defined channel object
      channel.name, // Use the channel name
      channelDescription: channel.description,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      styleInformation: bigTextStyleInformation,
      
      // --- FIX #2: Use a Valid Icon Resource ---
      // We will use the app's launcher icon for now, which is guaranteed to exist.
      // If you want a custom icon, you must add it to the 'drawable' folder first.
      icon: '@mipmap/ic_launcher', // Changed from 'ic_stat_fiber_manual_record'

      color: _getCategoryNotificationColor(category),
      colorized: true, // Makes the color more prominent
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    
    // Using ID 0 for the single persistent notification. This is correct.
    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }

  Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }
}