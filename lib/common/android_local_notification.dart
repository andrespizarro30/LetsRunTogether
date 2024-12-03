


import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/run_together');
  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'tracking_race',
    'tracking_race_channel',
    channelDescription: 'Tracking race',
    importance: Importance.low,
    priority: Priority.high,
    showWhen: false,
    enableVibration: false
);

const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

Future<void> showRunningForegroundNotification(double lat,double lon, double dist, double speed) async {

  String lati = lat.toStringAsFixed(2);
  String longi = lon.toStringAsFixed(2);
  String dista = dist.toStringAsFixed(2);
  String spd = speed.toStringAsFixed(2);

  await flutterLocalNotificationsPlugin.show(
    999,
    'Run together Pereira - $lati,$longi',
    'Distancia: $dista Km - Veloc.:$spd Km/h',
    platformChannelSpecifics,
    payload: 'Tracking Location',
  );
  // await flutterLocalNotificationsPlugin.show(
  //   0,
  //   'Run together Pereira',
  //   'Distancia:',
  //   platformChannelSpecifics,
  //   payload: 'Tracking Location',
  // );
}