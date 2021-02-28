import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xff10cbec),

      body:Column(

        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          Align(

            alignment: Alignment.bottomCenter,

            child:   Image.asset("Assets/spalsh.jpg" , width: 150, height: 150,alignment: Alignment.center,),
          ),




       //   Text("Alpha Ride"  , style: TextStyle(color: DataProvider().baseColor  ,fontSize: 30.0),) ,
        ],
      ),

    );
  }
}
