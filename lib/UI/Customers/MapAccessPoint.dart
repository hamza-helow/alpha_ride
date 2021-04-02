import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapAccessPoint extends StatelessWidget {

  final CameraPosition cameraPosition;

  final Function (LatLng latLng) onChangePin;

  MapAccessPoint(this.cameraPosition  , this.onChangePin);


  LatLng center ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DataProvider().baseColor,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: onCreated,
            initialCameraPosition: cameraPosition,
            compassEnabled: false,
            myLocationEnabled: false,
            zoomControlsEnabled: true,
            buildingsEnabled: true,
            myLocationButtonEnabled: false,
            minMaxZoomPreference: MinMaxZoomPreference(12, 20),
            mapToolbarEnabled: false,
            rotateGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onCameraMove: _onCameraMove,
          ),
          pin(context) ,
          setAccessPoint(context)
        ],
      ),
    );
  }

  void onCreated(GoogleMapController controller) {}

  Positioned pin(BuildContext context) {
    return Positioned(
      left: 0,
      top: (MediaQuery.of(context).size.height / 2) - 50,
      right: 0,
      child: Column(
        children: <Widget>[
          Icon(
            Icons.location_on_sharp,
            size: 50,
            color: DataProvider().baseColor,
          )
        ],
      ),
    );
  }


  Positioned setAccessPoint(BuildContext context) {
    return Positioned(
      left: 35,
      bottom: 20,
      right: 35,
      child: MaterialButton(
        height: 60.0,
        color: DataProvider().baseColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: BorderSide(color: DataProvider().baseColor)),
        onPressed: () {

          onChangePin(center);
          Navigator.pop(context);

        },
        child: Text(
          "${AppLocalizations.of(context).translate('confirmDestination')}",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22.0),
        ),
      ),
    );
  }


  void _onCameraMove(CameraPosition position) {


    center = LatLng(position.target.latitude , position.target.longitude);


  }
}
