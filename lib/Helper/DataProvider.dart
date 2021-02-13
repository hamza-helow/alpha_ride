
import 'package:alpha_ride/Models/user_location.dart';

class DataProvider{

  DataProvider prefs ;

  DataProvider._privateConstructor();

  static final DataProvider _instance = DataProvider._privateConstructor();

  factory DataProvider() {
    return _instance;
  }


  UserLocation userLocation;


   String currentLanguage = "en" ;



}