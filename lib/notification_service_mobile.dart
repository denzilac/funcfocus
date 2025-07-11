// File: notification_service_mobile.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/app_colors.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'functional_focus_ongoing_channel', // id
    'Functional Focus Ongoing Task', // title
    description: 'Notification for the currently focused task.', // description
    importance: Importance.low,
    showBadge: false,
  );

  Future<void> init() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(channel);
    await androidImplementation?.requestNotificationsPermission();

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
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      styleInformation: bigTextStyleInformation,
      icon: '@mipmap/ic_launcher',
      color: AppColors.get(category),
      colorized: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }

  Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }
}