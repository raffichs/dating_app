import 'package:final_tpm/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> showMatchNotification(String name) async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'match_channel',
    'Match Notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'It\'s a Match!',
    'You and $name have matched! 🎉',
    platformDetails,
  );
}
