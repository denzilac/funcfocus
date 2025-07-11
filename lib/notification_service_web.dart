// lib/notification_service_web.dart

// This is a "stub" implementation that does nothing.
// It is used when the app is compiled for the web.
class NotificationService {
  Future<void> init() async {
    // No-op for web
  }

  Future<void> showPersistentNotification(String title, String body, String category) async {
    // No-op for web
  }

  Future<void> cancelNotification() async {
    // No-op for web
  }
}