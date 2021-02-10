import 'dart:io';

import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/UI/Customers/Home.dart';
import 'package:alpha_ride/UI/Driver/homeDriver.dart';
import 'package:alpha_ride/UI/widgets/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'Helper/AppLanguage.dart';
import 'Helper/AppLocalizations.dart';
import 'Models/user_location.dart';
import 'UI/Login.dart';
import 'services/location_service.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();

  await Firebase.initializeApp();


  runApp(EntryPoint(appLanguage,));
}


 class EntryPoint extends StatefulWidget {

   final AppLanguage appLanguage;


   EntryPoint(this.appLanguage);

  @override

   _EntryPointState createState() => _EntryPointState();
 }

 class _EntryPointState extends State<EntryPoint> {


  Widget mainScreen = SplashScreen();


  @override
  void initState() {



    sleep(const Duration(seconds:2));

    this.setState(() {

      if(auth.currentUser != null)
        SharedPreferencesHelper().getTypeAccount().then((typeAccount)  {

          print("TTTTTT${typeAccount}");

          this.setState(() {
            if(typeAccount == TypeAccount.customer)
              mainScreen = Home();
            else
              mainScreen = HomeDriver();
          });

        });

      else
      mainScreen = Login();

    });


  }





  @override
   Widget build(BuildContext context) {
     return StreamProvider<UserLocation>(

       create: (context) => LocationService().locationStream,

       child: ChangeNotifierProvider<AppLanguage>(

         create: (context) =>  widget.appLanguage,

         builder: (context, child) => Consumer<AppLanguage>(

             builder: (context, value, child) =>MaterialApp(

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
               home: mainScreen,
             )

         ),

       ),
     );
   }
 }



class MyApp extends StatelessWidget {

  final AppLanguage appLanguage;

  MyApp({this.appLanguage});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(

        create: (context) => LocationService().locationStream,

    child: ChangeNotifierProvider<AppLanguage>(

      create: (context) =>  appLanguage,

      builder: (context, child) => Consumer<AppLanguage>(

          builder: (context, value, child) =>MaterialApp(

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
            home: SplashScreen(),
          )

      ),

    ),
    );
  }
}


