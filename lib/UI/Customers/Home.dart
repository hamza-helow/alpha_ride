import 'dart:async';

import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/UI/Common/Settings.dart' as w;
import 'package:alpha_ride/UI/Login.dart';
import 'package:alpha_ride/UI/widgets/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

// key password : hh0788051422**@@

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final int zoomIn = 0  , zoomOut = 1;

  var currentZoomLevel;
  var _controller ;

  String kGoogleApiKey = "AIzaSyAhZEFLG0WG4T8kW7lo8S_fjbSV8UXca7A";

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyAhZEFLG0WG4T8kW7lo8S_fjbSV8UXca7A");

  LocationData currentLocation ;

  UserLocation userLocation ;

  LatLng _lastMapPosition ;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  Completer<GoogleMapController> _completer = Completer();

  static final CameraPosition defaultPosition = CameraPosition(
    target: LatLng(32.5661186, 35.8420676),
    zoom: 17.4746,
  );


  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;


  }

  String _fullName ="" , _email ="" ;

 @override
  void initState() {
    loadInfoUser();
    super.initState();
  }


  void loadInfoUser(){


    SharedPreferencesHelper().getEmail().then((value) {

      if(this.mounted)
        this.setState(() {
          _email= value;
        });

    });

    SharedPreferencesHelper().getFullName().then((value) {

      if(this.mounted)
        this.setState(() {
          _fullName= value;
        });

    });
  }


  @override
  Widget build(BuildContext context) {

    userLocation = Provider.of<UserLocation>(context);

    var cameraPosition = userLocation != null
        ? CameraPosition(
      target: LatLng(userLocation.latitude, userLocation.longitude),
      zoom: 16.4,
    )
        : null;

    return Scaffold(

      key: _scaffoldKey,
      drawer: buildDrawer(),

      body: Stack(

        children: [

          GoogleMap(
            initialCameraPosition: cameraPosition??defaultPosition,
            compassEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            buildingsEnabled: true,
            myLocationButtonEnabled: false,
            minMaxZoomPreference: MinMaxZoomPreference(12, 20),
            mapToolbarEnabled: false,
            rotateGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onCameraMove: _onCameraMove,
            onMapCreated: onMapCreated,

          ),

           buttonsZoom(),

          buttonCurrentLocation(),

          pin(context),

          if(!confirmPickup)
          startTrip(),

          buildAppBar() ,

         if(confirmPickup)
         CustomerBottomSheet(
           callBack: (){

             this.setState(() {
               confirmPickup = false ;
             });

           },
         )

        ],

      ),

    );
  }

  Positioned buttonsZoom() {
    return Positioned(
      top: 90,
      left: 10,
      child: Card(
        elevation: 2,
        child: Container(
          color: Color(0xFFFAFAFA),
          width: 40,
          height: 100,
          child: Column(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: ()  {
                    changeZoom(typeZoom: zoomIn);

                  }),
              SizedBox(height: 2),
              IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => changeZoom(typeZoom: zoomOut)),

            ],
          ),
        ),
      ),
    );
  }

  Positioned buttonCurrentLocation() {
    return Positioned(
          top: 200,
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

                    print("XXXXXXXXXXXXx");
                    animateTo(userLocation.latitude, userLocation.longitude);

                  }),
            ),
          ),
        );
  }

  Positioned pin(BuildContext context) {
    return Positioned(
          left: 0,
          top: (MediaQuery.of(context).size.height/2)-50,
          right: 0,
          child: Column(
            children: <Widget>[

              Icon(Icons.location_on_sharp , size: 50, color: Colors.deepOrange,)
            ],
          ),
        );
  }


  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;



  bool confirmPickup = false ;
  Positioned startTrip() {
    return Positioned(
          left: 35,
          bottom: 20,
          right: 35,
          child:  MaterialButton(
            height: 60.0,
            color: Colors.deepOrange,

            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: BorderSide(color: Colors.red)
            ),
            onPressed: ()  {
              this.setState(() {
                confirmPickup = true;
              });

            },

            child: Text("Confirm pickup" , style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ,fontSize: 22.0),),
          ),
        );
  }

  Positioned buildAppBar() {
    return Positioned(
      top: 27,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              SizedBox(width: 15,),

              GestureDetector(
                onTap: () => {
                  _scaffoldKey.currentState.openDrawer()
                },
                child: Icon(Icons.menu ,size: 30.0, color: Colors.deepOrange,) ,
              ),

              SizedBox(width: 20,),

              Expanded(

                child: Container(

                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey, blurRadius: 11, offset: Offset(3.0, 4.0))
                      ],
                      borderRadius: new BorderRadius.all(new Radius.circular(10)),
                      border: new Border.all(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),

                    width: MediaQuery.of(context).size.width - 100,

                    child:Column(

                      children: [

                        GestureDetector(

                          onTap: () async {
                            // show input autocomplete with selected mode
                            // then get the Prediction selected
                            Prediction p = await PlacesAutocomplete.show(
                                context: context, apiKey: kGoogleApiKey,
                                logo: Text("")


                            );
                            displayPrediction(p);
                          },

                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  height: 60.5,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Where to?',
                                        style: TextStyle(
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 60.5,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 14.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Chip(
                                        avatar: Icon(
                                          Icons.watch_later,
                                          color: Colors.deepOrange,
                                          size: 21,
                                        ),
                                        backgroundColor: Colors.grey[200],
                                        label: TimeSelectorWidget(),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        if(_currentAddress.isNotEmpty)
                          Container(
                            color: Colors.white,

                            child: ListTile(

                              title: Text("$_currentAddress"),
                              leading: Icon(Icons.location_pin),
                            ),
                          ) ,

                        if(addressTo.isNotEmpty)
                          Container(
                            color: Colors.white,

                            child: ListTile(

                              trailing: GestureDetector(
                                onTap: () {
                                  this.setState(() {
                                    addressTo ="";
                                  });

                                },
                                child: Icon(Icons.clear),
                              ),
                              title: Text("$addressTo"),
                              leading: Icon(Icons.location_searching_rounded),
                            ),
                          )

                      ],
                    )
                ),

              ),



              SizedBox(width: 30,),

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

            GestureDetector(

              onTap: () => {

              } ,

              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),

                accountName: Text("$_fullName" ,style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold) ),
                accountEmail: Text("$_email" , style: TextStyle(color: Colors.black54)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.deepOrange ,
                  child: Icon(FontAwesomeIcons.user , color: Colors.white,),
                ),

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
              onTap: () {

                Navigator.push(context, MaterialPageRoute(builder: (context) => w.Settings(),));


              },
              leading: Icon(Icons.settings),
              title: Text("Settings" ,),
            ),


            Divider(),

            ListTile(
              onTap: () {

                auth.signOut() ;

                Navigator.of(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  Login(),));

              },
              leading: Icon(Icons.logout),
              title: Text("Log out" ,),
            ),

          ],
        ),
      ),
    );
  }


   String addressTo ="";
  // When map ready
  onMapCreated( controller) {



    _completer.complete(controller);

    _controller  = controller ;


    Geolocator.getCurrentPosition().then((value) => {

      this.setState(() {

        userLocation = UserLocation(latitude: value.latitude , longitude: value.longitude);

        DataProvider().userLocation = userLocation;

        _getAddressFromLatLng(userLocation.latitude ,userLocation.longitude).then((address) => {

          this.setState(() {
            _currentAddress = address;
          })
        });

      })


    });

  }


  Future<void> animateTo(double lat, double lng) async {
    final c = await _completer.future;
    final p = CameraPosition(target: LatLng(lat, lng), zoom: 17.0);
    c.animateCamera(CameraUpdate.newCameraPosition(p));
  }


  void changeZoom({int typeZoom = 0 }) async{

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


  Future<Null> displayPrediction(Prediction  p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      _getAddressFromLatLng(lat, lng).then((value) => {
        this.setState(() {
      addressTo = value;
        })
      });

   //   var address = await Geocoder.local.findAddressesFromQuery(p.description);


    }
  }

  String _currentAddress ="" ;

  Future<String> _getAddressFromLatLng(double lat , double lng) async {

    String address ="";

    try {

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks[0];

      address =  "${place.locality}, ${place.name}, ${place.country}";

      // setState(() {
      //   _currentAddress =
      //   "${place.locality}, ${place.name}, ${place.country}";
      //
      //   print("ADDRESS $_currentAddress");
      //
      // });


    } catch (e) {
      print("EEEEE $e");
    }

    return address;
  }

}
