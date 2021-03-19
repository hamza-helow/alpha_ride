import 'dart:async';
import 'dart:io';

import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/UI/Common/Login.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/UI/Customers/Home.dart';
import 'package:alpha_ride/UI/Driver/homeDriver.dart';
import 'package:alpha_ride/services/PushNotificationService.dart';
import 'package:alpha_ride/services/location_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'Helper/AppLanguage.dart';
import 'Helper/AppLocalizations.dart';

var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();

  setFirebase();
  await Firebase.initializeApp();

  runApp(EntryPoint(
    appLanguage,
  ));
}

class EntryPoint extends StatefulWidget {
  final AppLanguage appLanguage;

  EntryPoint(this.appLanguage);

  @override
  _EntryPointState createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  //StreamSubscription<ConnectivityResult> subscriptionConnectivity;

  @override
  void initState() {

    super.initState();
  }



  @override
  dispose() {
    super.dispose();
  //  subscriptionConnectivity.cancel();
  }
  @override
  Widget build(BuildContext context) {
    // final pushNotificationService = PushNotificationService(_firebaseMessaging);
    // pushNotificationService.initialise();

    return StreamProvider<UserLocation>(

      create: (context) => LocationService().locationStream,
      child: FutureBuilder<TypeAccount>(
        future: SharedPreferencesHelper().getTypeAccount() ,

        builder: (context, snapshot) => ChangeNotifierProvider<AppLanguage>(
          create: (context) => widget.appLanguage,
          builder: (context, child) => Consumer<AppLanguage>(
              builder: (context, value, child) => MaterialApp(
                locale: value.appLocal,
                supportedLocales: [
                  Locale('en', 'US'),
                  Locale('ar', ''),
                ],
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                debugShowCheckedModeBanner: false,
                home:  () {

                  //return CompleteCreateAccount(null);
                  if (auth.currentUser != null)
                    if (snapshot.data == TypeAccount.driver)
                      return  HomeDriver();
                    else
                      return Home();

                  return Login();
                  SharedPreferencesHelper().getTypeAccount();
                  return Login();
                }(),
              )),
        ),),
    );
  }

  dialogInternetNotConnect() async {
    await showDialog<String>(
        context: context,
        builder: (context) => new AlertDialog(
            content: Text("لا يوجد اتصال بالانترنت") ,
            actions: []));
  }
}

void setFirebase() async {

final initializationSettingsAndroid =
      new AndroidInitializationSettings('@mipmap/ic_launcher' );

  final initializationSettingsIOS = IOSInitializationSettings();

  final initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelect);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  await _firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: false),
  );

  _firebaseMessaging.configure(
    onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
    onMessage: (message) async {
      print("onMessage...: $message");

      String title = message["notification"]["title"].toString();

      String body = message["notification"]["body"].toString();

      print("onMessage...: $title  $body");

      displayNotification(title, body);
    },
    onLaunch: (message) async {
      print("onLaunch: $message");
    },
    onResume: (message) async {
      print("onResume: $message");
    },
  );

  _firebaseMessaging.getToken().then((String token) {
    print("Push Messaging token: $token");

    DataProvider().tokenDevice = token;

  });
}

Future<String> onSelect(String data) async {
  print("onSelectNotification $data");
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print("myBackgroundMessageHandler message: $message");

  String title = message["notification"]["title"].toString();

  String body = message["notification"]["body"].toString();

  print("onMessage...: $title  $body");

  displayNotification(title, body);

  return Future<void>.value();
}

Future displayNotification(String title, String body) async {

  // var androidPlatformChannel = new AndroidNotificationDetails(
  //     "your_channel_id", "name", "desc_channel",
  //     sound: RawResourceAndroidNotificationSound('lawgo_sound_notification'),
  //     playSound: true,
  //     importance: Importance.Max,
  //     priority: Priority.High);


  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channelid', 'flutterfcm', 'your channel description',
      importance: Importance.Max, priority: Priority.High , sound: RawResourceAndroidNotificationSound('call') );
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


