
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHelpers {

  static MapHelpers _instance ;

  MapHelpers._internal(){

    print("new  MapHelpers");
  }

  static MapHelpers getInstance (){
    if(_instance == null)
      _instance = MapHelpers._internal();
    return _instance;
  }


  void zoomBetweenTwoPoints(LatLng customerLocation, LatLng driverLocation ,_controller ) {
    final LatLng offerLatLng = driverLocation;

    LatLngBounds bound;
    if (offerLatLng.latitude > customerLocation.latitude &&
        offerLatLng.longitude > customerLocation.longitude) {
      bound = LatLngBounds(southwest: customerLocation, northeast: offerLatLng);
    } else if (offerLatLng.longitude > customerLocation.longitude) {
      bound = LatLngBounds(
          southwest: LatLng(offerLatLng.latitude, customerLocation.longitude),
          northeast: LatLng(customerLocation.latitude, offerLatLng.longitude));
    } else if (offerLatLng.latitude > customerLocation.latitude) {
      bound = LatLngBounds(
          southwest: LatLng(customerLocation.latitude, offerLatLng.longitude),
          northeast: LatLng(offerLatLng.latitude, customerLocation.longitude));
    } else {
      bound = LatLngBounds(southwest: offerLatLng, northeast: customerLocation);
    }

    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    _controller.animateCamera(u2).then((void v) {});
  }


  Future<String> getAddressFromLatLng(double lat, double lng) async {
    String address = "";

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks[0];

      address = "${place.locality}, ${place.name}, ${place.country}";

      print(place);
    } catch (e) {
      print("EEEEE $e");
    }

    return address;
  }

  void changeZoom(_controller , userLocation, {int typeZoom = 0}) async {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(userLocation.latitude, userLocation.longitude),
          zoom: typeZoom == 0
              ? await _controller.getZoomLevel() + 1
              : await _controller.getZoomLevel() - 1,
        ),
      ),
    );
  }



}