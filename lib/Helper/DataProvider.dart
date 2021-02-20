
import 'package:alpha_ride/Models/DriverRequest.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DataProvider{

  DataProvider prefs ;

  DataProvider._privateConstructor();

  static final DataProvider _instance = DataProvider._privateConstructor();

  factory DataProvider() {
    return _instance;
  }


  double rotateCar = 0.0;

  DriverRequest driverRequest ;


  UserLocation userLocation;


   String currentLanguage = "en" ;

   String mapKey ="AIzaSyAhZEFLG0WG4T8kW7lo8S_fjbSV8UXca7A";

   String accessPointAddress ="";

   LatLng accessPointLatLng ;



}