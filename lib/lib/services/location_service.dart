import 'dart:async';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:location/location.dart';

class LocationService {
  // keep track of current location
  UserLocation _currentLocation;

  Location location = Location();

  // continuosly emit location data
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>.broadcast();

  LocationService() {



    location.changeSettings(accuracy: LocationAccuracy.powerSave , distanceFilter: 10 );


    location.requestPermission().then((granted) {
      if (granted == PermissionStatus.granted) {

        location.getLocation().then((locationData) => {
          print(" Current location ${locationData.longitude}"),

          _locationController.add(UserLocation(
        longitude: locationData.longitude,
        latitude: locationData.latitude,

        ))

        });


        // location.onLocationChanged.listen((locationData) {
        //   if (locationData != null) {
        //     _locationController.add(UserLocation(
        //       longitude: locationData.longitude,
        //       latitude: locationData.latitude,
        //
        //     ));
        //
        //     print(" Current location ${locationData.longitude}");
        //
        //   }
        // });
      }
    });
  }

  Stream<UserLocation> get locationStream => _locationController.stream;

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
          latitude: userLocation.latitude, longitude: userLocation.longitude);
    } catch (e) {
      print('Could not get the location');
    }
    return _currentLocation;
  }
}
