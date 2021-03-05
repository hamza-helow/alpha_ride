import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Login.dart';
import 'package:alpha_ride/Models/DriverRequest.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/Models/SettingApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DataProvider{

  DataProvider prefs ;

  DataProvider._privateConstructor();

   Color baseColor = Colors.red;

  static final DataProvider _instance = DataProvider._privateConstructor();

  factory DataProvider() {
    return _instance;

    // DataProvider().baseColor


  }


  double rotateCar = 0.0;

  DriverRequest driverRequest ;

  UserLocation userLocation;

  String currentLanguage = "en" ;

  String mapKey ="AIzaSyAhZEFLG0WG4T8kW7lo8S_fjbSV8UXca7A";

  String accessPointAddress ="";

  LatLng accessPointLatLng ;

  int promoCodePercentage =  0;

  String promoCode="" , nameUser="" , phoneUser="";

  String getHoursFromMin(int minutes ) {
    final int hour = minutes  ~/ 60;
    final int min = minutes  % 60;
    return '${hour.toString().padLeft(2, "0")}:${min.toString().padLeft(2, "0")}';
  }

  Future<String> getArriveTime(LatLng from , LatLng to)async{

    if(from == null || to == null)
      return "";

    Dio dio = new Dio();
    Response response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${from.latitude},${from.longitude}&destinations=${to.latitude},${to.longitude}&key=${DataProvider().mapKey}");
    print("RESULT :  ${response.data}");


    return response.data['rows'][0]['elements'][0]['duration']['text'] ;

  }



  Future<double> calcPriceTotal({TypeTrip typeTrip , discountTrip = 0 , minTrip =0, kmTrip=0 ,DateTime startDate})async{

  final SettingApp settingApp  =   await FirebaseHelper().getSettingApp();

    double totalPrice ;
    if(typeTrip == TypeTrip.distance){
      double startPrice = settingApp.startPrice ;

      double totalPriceMin = minTrip * settingApp.min;

      double totalKmPrice = kmTrip * settingApp.km;

      totalPrice =  startPrice + totalKmPrice + totalPriceMin ;

      if(totalPrice < 1.15)
        totalPrice = 1.15 ;

      double discount = double.parse("0.$discountTrip");

      totalPrice = totalPrice  -  (totalPrice * discount);

      if(totalPrice < 0)
        totalPrice = 0.0 ;
    }

    else {

      int min =  startDate.difference(DateTime.now()).inMinutes;

      totalPrice =  double.parse(DataProvider().getHoursFromMin(min).replaceAll(":", ".")) * settingApp.hours;

      if(totalPrice < settingApp.hours/2)
        totalPrice = settingApp.hours/2 ;

    }



double percentageDriver = (double.parse(totalPrice.toStringAsFixed(2)) * double.parse('0.${settingApp.percentageDriver}')) ;


        FirebaseFirestore.instance.collection("Users").doc(auth.currentUser.uid)
      .update({
       'balance' : FieldValue.increment((percentageDriver *-1))
          });


    return double.parse(totalPrice.toStringAsFixed(2));

  }


}