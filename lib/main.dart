import 'dart:async';
import 'dart:io';

import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/Login.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/UI/Customers/Home.dart';
import 'package:alpha_ride/UI/Driver/homeDriver.dart';
import 'package:alpha_ride/services/PushNotificationService.dart';
import 'package:alpha_ride/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'Helper/AppLanguage.dart';
import 'Helper/AppLocalizations.dart';

//var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();

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


    // subscriptionConnectivity = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //
    //   if(result == ConnectivityResult.none )
    //     dialogInternetNotConnect();
    //
    //
    // });

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
                  if (auth.currentUser != null)
                    if (snapshot.data == TypeAccount.customer)
                      return Home();
                    else
                      return  HomeDriver();

                  return Login();
                  // SharedPreferencesHelper().getTypeAccount();
                  //return Login();
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

