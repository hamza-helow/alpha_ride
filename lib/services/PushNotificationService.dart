import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {


  static var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();


  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future initialise() async {

    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    String token = await _fcm.getToken();
    print("FirebaseMessaging token: $token");

    _fcm.configure(

      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,

      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        String title = message["notification"]["title"].toString();

        String body = message["notification"]["body"].toString();

        print("onMessage...: $title  $body");

        displayNotification(title, body);

      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

 static Future displayNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channelid', 'flutterfcm', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      body,
      platformChannelSpecifics,
      payload: 'hello',
    );
  }

 static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
    print("myBackgroundMessageHandler message: $message");

    String title = message["notification"]["title"].toString();

    String body = message["notification"]["body"].toString();

    print("onMessage...: $title  $body");

    displayNotification(title, body);

    return Future<void>.value();
  }

}