import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;



class TripInfoScreen extends StatefulWidget {

  Trip trip ;


  TripInfoScreen(this.trip);

  @override
  _TripInfoScreenState createState() => _TripInfoScreenState();
}

class _TripInfoScreenState extends State<TripInfoScreen> {

  Set<Marker> markers = Set();
  Map<PolylineId, Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];

  poly.PolylinePoints polylinePoints = poly.PolylinePoints();

  var cameraPosition ;


  @override
  void initState() {

    print(widget.trip.locationCustomer.latitude);

     this.setState(() {

       cameraPosition =CameraPosition(
         target: LatLng(widget.trip.locationCustomer.latitude, widget.trip.locationCustomer.longitude),
         zoom: 16.4,
       );
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DataProvider().baseColor,
      ),

      body: SingleChildScrollView(
        child: Column(

          children: [
            
          Container(
            height: 350,

            child:  Stack(
              children: [
                GoogleMap(
                  markers: markers,
                  onMapCreated: onCreated,
                  initialCameraPosition: cameraPosition ,
                  compassEnabled: false,
                  myLocationEnabled: false,
                  zoomControlsEnabled: true,
                  buildingsEnabled: true,
                  myLocationButtonEnabled: false,
                  minMaxZoomPreference: MinMaxZoomPreference(12, 20),
                  mapToolbarEnabled: false,
                  rotateGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  polylines: Set<Polyline>.of(polylines.values),

                )
              ],
            ),
          ),

          SizedBox(
            height: 20.0,
          ),

         Padding(padding: EdgeInsets.all(20.0) ,child:   Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            Row(
              children: [

                Icon(Icons.monetization_on , size: 40.0, color: DataProvider().baseColor,),
                SizedBox(width: 20.0,),
                Text("cash" , style: TextStyle( fontWeight: FontWeight.bold , fontSize: 17.0),)
              ],
            ) ,

            Text("${widget.trip.totalPrice} JD" ,style: TextStyle( color: Colors.green.shade900,fontWeight: FontWeight.bold , fontSize: 17.0),),


          ],
        ),) ,

            Divider(),

            Padding(padding: EdgeInsets.all(10.0) ,

              child:   ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),

                title: Text("Hamza helow"),
                subtitle: Text("Economy -Dark Red Fusion 2568794"),

                trailing: Chip(
                  avatar: Icon(
                    Icons.star,
                    color: DataProvider().baseColor,
                    size: 21,
                  ),
                  backgroundColor: Colors.grey[200],
                  label: Text("5.0"),
                ),

              ),

            ) ,

          ],
        ),
      ),
    );
  }

  var _controller ;

  onCreated(controller) {

    this._controller = controller;
    _getPolyline(widget.trip.locationCustomer , widget.trip.locationDriver);

    addMarker(widget.trip.locationCustomer , 'customer');
    addMarker(widget.trip.locationDriver , 'driver');

    zoomBetweenTwoPoints(widget.trip.locationCustomer ,widget.trip.locationDriver);
  }


  void zoomBetweenTwoPoints(LatLng customerLocation , LatLng driverLocation){

    final LatLng offerLatLng =  driverLocation ;

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


    this._controller.animateCamera(u2).then((void v){
    });

  }


  PolylineId id = PolylineId("poly11");

  _addPolyLine() {

    Polyline polyline = Polyline(
        polylineId: id, color: DataProvider().baseColor,
        points: polylineCoordinates ,
        geodesic: false,

    );

    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline(LatLng origin ,LatLng dest ) async {
    poly.PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      DataProvider().mapKey,
      poly.PointLatLng(origin.latitude, origin.longitude),
      poly.PointLatLng(dest.latitude, dest.longitude),
      travelMode: poly.TravelMode.driving,
      optimizeWaypoints: true ,
      avoidFerries: false

    );

    if (result.points.isNotEmpty) {

      result.points.forEach((poly.PointLatLng point) {
        if(polylines.isEmpty)
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  void addMarker(LatLng latLng , String id) {


    final Marker marker = Marker(
      markerId: MarkerId("$id"),
      position: latLng,
      onTap: () {
      },
    );

    markers.add(marker) ;

  }


}
