import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

dialog(Widget child,context,
    {List<Widget> widgets, barrierDismissible = true , Widget title , EdgeInsets padding =const EdgeInsets.all(16.0)  }) async {
  await showDialog<String>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => new AlertDialog(
            title: title,
            contentPadding: padding,
            content: child,
            actions: widgets),
      ));
}





Positioned buttonsZoom(currentZoomLevel , _controller ,userLocation  ) {
  return Positioned(
    top: 120,
    left: 10,
    child: Card(
      elevation: 2,
      child: Container(
        color: Color(0xFFFAFAFA),
        width: 40,
        height: 110,
        child: Column(
          children: <Widget>[

            IconButton(
                icon: Icon(Icons.add),
                onPressed: ()  {
                  changeZoom(currentZoomLevel , _controller ,userLocation,typeZoom: 0);

                }),
            SizedBox(height: 2),
            IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => changeZoom(currentZoomLevel , _controller ,userLocation,typeZoom: 1),

            )

          ],
        ),
      ),
    ),
  );
}

Positioned buttonCurrentLocation(_completer , latitude ,longitude  ) {
  return Positioned(
    top: 220,
    left: 10,
    child: Card(
      elevation: 2,
      child: Container(
        color: Color(0xFFFAFAFA),
        width: 40,
        height: 40,
        child:  IconButton(
            icon: Icon(Icons.gps_fixed),
            onPressed: () {
              animateTo(_completer,latitude, longitude);

            }),
      ),
    ),
  );
}


Future<void> animateTo(_completer,double lat, double lng) async {
  final c = await _completer.future;
  final p = CameraPosition(target: LatLng(lat, lng), zoom: 17.0);
  c.animateCamera(CameraUpdate.newCameraPosition(p));
}


void changeZoom( currentZoomLevel , _controller ,userLocation  , {int typeZoom = 0 }) async{

  currentZoomLevel = await _controller.getZoomLevel();

  currentZoomLevel = typeZoom == 0 ? currentZoomLevel +  2 : currentZoomLevel -  2;
  _controller.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(userLocation.latitude ,userLocation.longitude),
        zoom: currentZoomLevel,
      ),
    ),
  );

}
