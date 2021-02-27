import 'package:alpha_ride/Models/DriverRequest.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DataProvider{

  DataProvider prefs ;

  DataProvider._privateConstructor();

  static final DataProvider _instance = DataProvider._privateConstructor();

  factory DataProvider() {
    return _instance;
  }

  String getHoursFromMin(int minutes ) {
    final int hour = minutes  ~/ 60;
    final int min = minutes  % 60;
    return '${hour.toString().padLeft(2, "0")}:${min.toString().padLeft(2, "0")}';
  }

  Future<String> getArriveTime(LatLng from , LatLng to)async{

    Dio dio = new Dio();
    Response response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${from.latitude},${from.longitude}&destinations=${to.latitude},${to.longitude}&key=${DataProvider().mapKey}");
    print("RESULT :  ${response.data}");


    return response.data['rows'][0]['elements'][0]['duration']['text'] ;

    //  print("RESULT :  ${response.data['rows'][0]['elements'][0]['duration']['text']}");

  }



  double rotateCar = 0.0;

  DriverRequest driverRequest ;


  UserLocation userLocation;


  String currentLanguage = "en" ;

  String mapKey ="AIzaSyAhZEFLG0WG4T8kW7lo8S_fjbSV8UXca7A";

  String accessPointAddress ="";

  LatLng accessPointLatLng ;

  int promoCodePercentage =  0;

  String promoCode="";


}