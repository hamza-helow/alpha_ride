import 'dart:async';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:location/location.dart';

class LocationService {


  UserLocation _currentLocation;  var location = Location();

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }    return _currentLocation;
  }

  StreamController<UserLocation> _locationController =
  StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  LocationService() {

    location.changeSettings(accuracy: LocationAccuracy.powerSave , distanceFilter: 10 );
    location.requestPermission().then((granted) {

      print(" Current location ");

      if (granted == PermissionStatus.granted) {

        location.onLocationChanged.listen((locationData) {
          print(" >>>>>Current location ${locationData.longitude}");

          _locationController.add(UserLocation(
          longitude: locationData.longitude,
          latitude: locationData.latitude,

          ));

        });

      }

    });
  }

}
