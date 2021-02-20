
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHelper{

  MapHelper prefs ;

  MapHelper._privateConstructor();

  static final MapHelper _instance = MapHelper._privateConstructor();

  factory MapHelper() {
    return _instance;
  }


  Future<String> getAddressLine(LatLng location) async
  {

    final coordinates = new Coordinates(location.latitude, location.longitude);

    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print(" ${first.addressLine}");
    print(" ${first.locality}");
    print(" ${first.adminArea}");
    print(" ${first.countryCode}");
    print(" ${first.featureName}");

    print(" ${first.subLocality}");
    print(" ${first.subThoroughfare}");

    print(" ${first.thoroughfare}");

    print(" ${first.subAdminArea}");

    print(" ${first.featureName}");

    return first.addressLine;
  }



}