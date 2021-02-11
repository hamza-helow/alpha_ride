import 'dart:async';
import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/UI/widgets/CustomWidgets.dart';
import 'package:alpha_ride/UI/widgets/bottom_sheetDriver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Login.dart';

class HomeDriver extends StatefulWidget {
  HomeDriver({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeDriver> {

  _MyHomePageState();

  double _direction;
  BitmapDescriptor carIcon;
  Set<Marker> markers = Set();

  UserLocation userLocation ;

  final geo = Geoflutterfire();
  GeoFirePoint geoMyLocation ;
  final _firestore = FirebaseFirestore.instance;

  final int zoomIn = 0  , zoomOut = 1;

  var currentZoomLevel;
  var _controller ;

  Position position ;

  Completer<GoogleMapController> _completer = Completer();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  //32.5661186,35.8420676
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(32.5661186, 35.8420676),
    zoom: 16.4746,
  );


  LatLng _lastMapPosition ;
  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }


  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(platform: TargetPlatform.android), "Assets/car.png")
        .then((onValue) {
      carIcon = onValue;
    });
    FlutterCompass.events.listen((double direction) {
      setState(() {
        _direction = direction;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    userLocation = Provider.of<UserLocation>(context);


    if(userLocation != null)
    markers.addAll([
      Marker(
          markerId: MarkerId('value'),
          position: LatLng(position.latitude, position.longitude),
          icon: carIcon,
          rotation: _direction),
    ]);


    var cameraPosition = userLocation != null
        ? CameraPosition(
      target: LatLng(userLocation.latitude, userLocation.longitude),
      zoom: 14,
    )
        : null;

    return Scaffold(

      key: _scaffoldKey,
      drawer: buildDrawer(),

      body: Stack(

        children: [

          GoogleMap(
            onMapCreated: onMapCreated,
             markers: markers,
            initialCameraPosition: cameraPosition??_kGooglePlex,
            compassEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            buildingsEnabled: true,
            myLocationButtonEnabled: false,
            minMaxZoomPreference: MinMaxZoomPreference(12, 20),
            mapToolbarEnabled: false,
            rotateGesturesEnabled: false,
            onCameraMove: _onCameraMove,

          ),

          DriverBottomSheet(),


          buildAppBar(),

          buttonsZoom(currentZoomLevel , _controller , userLocation  ),
          buttonCurrentLocation( )

        ],

      ),

    );
  }


  Positioned buttonCurrentLocation( ) {
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
                animateTo( _completer,userLocation.latitude , userLocation.longitude);

              }),
        ),
      ),
    );
  }


  Positioned buildAppBar() {
    return Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  GestureDetector(
                    onTap: () =>  _scaffoldKey.currentState.openDrawer(),
                    child: Container(

                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey, blurRadius: 11, offset: Offset(3.0, 4.0))
                        ],
                        borderRadius: new BorderRadius.all(new Radius.circular(30)),
                        border: new Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),

                      child: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.deepOrange,

                        child: Icon(Icons.menu  ,size: 25.0, color: Colors.white,),

                      ),

                    ),
                  ) ,

                  SizedBox(width: 10.0,),

                  PriceWidget(
                    price: "0.00",
                    onPressed: () {},
                  ),

                  SizedBox(width: 10.0,),

                  ProfileWidget(),

                  SizedBox(width: 10.0,),

                  NotificationWidget()

                ],
              ),
            ),
          ),
        );
  }

  Drawer buildDrawer() {
    return Drawer(

      child: Container(

        color: Colors.white,
        child: ListView(

          children: <Widget>[

            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),

              accountName: Text("Hamza helow" ,style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold) ),
              accountEmail: Text("hamzihelow3@gmail.com" , style: TextStyle(color: Colors.black54)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.deepOrange ,
                child: Icon(FontAwesomeIcons.user , color: Colors.white,),
              ),

            ),

            Row(

              children: [
                Container(
                  height: 50.5,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(left: 14.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: Icon(
                          FontAwesomeIcons.gift,
                          color: Colors.deepOrange,
                          size: 21,
                        ),
                        backgroundColor: Colors.grey[200],
                        label: Text("300 point"),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50.5,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(left: 14.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: Icon(
                          Icons.star,
                          color: Colors.deepOrange,
                          size: 21,
                        ),
                        backgroundColor: Colors.grey[200],
                        label: Text("4.8"),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            ListTile(
              leading: Icon(Icons.time_to_leave_sharp),
              title: Text("You trips" ,),
              trailing: Padding(padding: EdgeInsets.only(right: 10), child: Text("10+" ,  style: TextStyle(color: Colors.deepOrange),),),
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings" ,),
            ),


            Divider(),

            ListTile(
              onTap: () {

                auth.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
              },
              leading: Icon(Icons.logout),
              title: Text("Log out" ,),
            ),

          ],
        ),
      ),
    );
  }



  onMapCreated( controller) {


    _completer.complete(controller);

    _controller  = controller ;

    var options = LocationOptions(accuracy: LocationAccuracy.low, distanceFilter: 10);

    Geolocator.getPositionStream(desiredAccuracy: options.accuracy  , distanceFilter: options.distanceFilter).listen((position) {

      this.setState(() {
        this.position = position;
      });

      geoMyLocation = geo.point(latitude: position.latitude, longitude:position.longitude);


      FirebaseHelper()
          .checkLocationExit(auth.currentUser.uid)
           .then((isExit) => {

             if(isExit)
               FirebaseHelper()
                   .updateLocationUser(auth.currentUser.uid, { 'name': 'random name', 'position': geoMyLocation.data})
              else
                FirebaseHelper()
                    .insertLocationUser(auth.currentUser.uid, { 'idUser':'${auth.currentUser.uid}','name': 'random name', 'position': geoMyLocation.data})

            });


      print(position);

      animateTo(_completer, position.latitude, position.longitude);
    });


  }

}

class FunctionalButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Function() onPressed;

  const FunctionalButton({Key key, this.title, this.icon, this.onPressed})
      : super(key: key);

  @override
  _FunctionalButtonState createState() => _FunctionalButtonState();
}

class _FunctionalButtonState extends State<FunctionalButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RawMaterialButton(
          onPressed: widget.onPressed,
          splashColor: Colors.black,
          fillColor: Colors.white,
          elevation: 15.0,
          shape: CircleBorder(),
          child: Padding(
              padding: EdgeInsets.all(14.0),
              child: Icon(
                widget.icon,
                size: 30.0,
                color: Colors.black,
              )),
        ),
      ],
    );
  }
}

class ProfileWidget extends StatefulWidget {
  final Function() onPressed;

  const ProfileWidget({Key key, this.onPressed}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
          child: Container(

            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.grey, blurRadius: 11, offset: Offset(3.0, 4.0))
              ],
              borderRadius: new BorderRadius.all(new Radius.circular(30)),
              border: new Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),

            child: CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.deepOrange,

              child: Icon(FontAwesomeIcons.user  ,size: 25.0, color: Colors.white,),

            ),

          ),
    );
  }
}


class NotificationWidget extends StatefulWidget {

  final Function() onPressed;

  const NotificationWidget({Key key, this.onPressed}) : super(key: key);
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(

        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.grey, blurRadius: 11, offset: Offset(3.0, 4.0))
          ],
          borderRadius: new BorderRadius.all(new Radius.circular(30)),
          border: new Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),

        child: CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.deepOrange,

          child: Icon(Icons.notification_important  ,size: 25.0, color: Colors.white,),

        ),

      ),
    );
  }
}


class PriceWidget extends StatefulWidget {
  final String price;
  final Function() onPressed;

  const PriceWidget({Key key, this.price, this.onPressed}) : super(key: key);

  @override
  _PriceWidgetState createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<PriceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.deepOrange,
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey, blurRadius: 11, offset: Offset(3.0, 4.0))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(" \$ ",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          Text(widget.price,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

