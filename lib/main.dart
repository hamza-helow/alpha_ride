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


  runApp(MyApp(appLanguage: appLanguage,));
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
            home: Login(),
          )

      ),

    ),
    );
  }
}


