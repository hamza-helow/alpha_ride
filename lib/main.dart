import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Models/user_location.dart';
import 'UI/Login.dart';
import 'services/location_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(

        create: (context) => LocationService().locationStream,

    child: MaterialApp(

      debugShowCheckedModeBanner: false,
      home: Login(),
    ),
    );
  }
}


