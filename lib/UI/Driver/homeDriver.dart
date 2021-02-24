import 'dart:async';
import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Login.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/UI/widgets/CustomWidgets.dart';
import 'package:alpha_ride/UI/widgets/bottom_sheetDriver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart' as coder;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomeDriver extends StatefulWidget {
  HomeDriver({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeDriver> {

  _MyHomePageState();

  Map<PolylineId, Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];

  poly.PolylinePoints polylinePoints = poly.PolylinePoints();

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


  bool exitTrip = false ;


  Trip currentTrip ;

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

    currentTrip = Trip();

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(platform: TargetPlatform.android), "Assets/car.png")
        .then((onValue) {
      carIcon = onValue;
    });

    listenCurrentTrip();
  }

  void listenCurrentTrip(){

    _firestore
        .collection("Trips")
        .where("state" , isNotEqualTo: StateTrip.done.toString())
        .where("idDriver" , isEqualTo: auth.currentUser.uid)
        .snapshots().listen((event) {

      if(event.docs.length > 0) {

        this.setState(() {
          exitTrip = true ;
        });


        FirebaseHelper().loadUserInfo(event.docs.first.get("idCustomer")).then((value) {

          this.setState(() {

            currentTrip.nameCustomer = value.fullName;
            currentTrip.ratingCustomer = value.rating;
            currentTrip.idTrip = event.docs.first.id;
            currentTrip.locationCustomer = LatLng(event.docs.first.get("locationCustomer.lat") , event.docs.first.get("locationCustomer.lng"));
            currentTrip.locationDriver = LatLng(event.docs.first.get("locationDriver.lat")??0.0 , event.docs.first.get("locationDriver.lng")??0.0) ;


            currentTrip.stateTrip = (){

              var state = event.docs.first.get("state");

              if(state == StateTrip.active.toString())
                return StateTrip.active ;
              else if(state == StateTrip.rejected.toString())
                return StateTrip.rejected ;
              else
                return StateTrip.started ;

            }();

            if(currentTrip.stateTrip == StateTrip.started){

              currentTrip.startDate =  DateTime.parse(event.docs.first.get("dateStart").toDate().toString());

              currentTrip.minTrip = DateTime.now().difference(currentTrip.startDate ).inMinutes;

              currentTrip.hourTrip = DateTime.now().difference(currentTrip.startDate ).inHours.toString();

              currentTrip.km =  event.docs.first.get("km");

              currentTrip.discount = event.docs.first.get("discount");

            }




            if(polylineCoordinates.isEmpty && currentTrip.stateTrip == StateTrip.active){
              _getPolyline(currentTrip.locationCustomer,  currentTrip.locationDriver);

              zoomBetweenTwoPoints(currentTrip.locationCustomer, currentTrip.locationDriver);

              addMarker(currentTrip.locationCustomer);

              print("DIS : ${ distanceBetweenTwoLocation(currentTrip.locationCustomer , currentTrip.locationDriver)}");


            }


          });


        });



      }// trip exit
      print("Exit trip ${event.size}");

    });

  }

  double distanceBetweenTwoLocation(LatLng customer , LatLng driver){
    if(customer == null || driver == null )
      return 0.0 ;

    return   Geolocator.distanceBetween(customer.latitude, customer.longitude, driver.latitude, driver.longitude);

  }

  @override
  Widget build(BuildContext context) {
    userLocation = Provider.of<UserLocation>(context);


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
            polylines: Set<Polyline>.of(polylines.values),

          ),

          if(!exitTrip)
            DriverBottomSheet(),
          buildAppBar(),

        ],

      ),

    );
  }


  void updateKm(double meter){

    if(meter == 0.0)
      return;

    _firestore
        .collection("Trips")
        .doc(currentTrip.idTrip)
        .update({

      'km' :  FieldValue.increment(meter / 1000)

    });

  }

  Card buttonMenu( ) {
    return Card(
      elevation: 2,
      child: Container(
        color: Color(0xFFFAFAFA),
        width: 40,
        height: 40,
        child:  IconButton(
            color: Colors.deepOrange,
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();

            }),
      ),
    );
  }


  Card buttonCurrentLocation( ) {
    return Card(
      elevation: 2,
      child: Container(
        color: Color(0xFFFAFAFA),
        width: 40,
        height: 40,
        child:  IconButton(
            icon: Icon(Icons.gps_fixed),
            onPressed: () {
              animateTo( _completer,position.latitude , position.longitude);

            }),
      ),
    );
  }

  Card buttonsZoom(  ) {
    return Card(
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

            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[

              Column(
                children: [
                  buttonMenu(),
                  buttonsZoom( ),
                  buttonCurrentLocation( ) ,

                ],
              ),


              SizedBox(width: 10.0,),

              if(!exitTrip)
                PriceWidget(
                  price: "0.00",
                  onPressed: () {},
                ),

              if(!exitTrip)
                SizedBox(width: 10.0,),

              if(!exitTrip)
                ProfileWidget(),
              if(!exitTrip)
                SizedBox(width: 10.0,),
              if(!exitTrip)
                NotificationWidget() ,

              if(exitTrip)
                controlTrip()


            ],
          ),
        ),
      ),
    );
  }

  Padding controlTrip() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0) ,

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

        width: MediaQuery.of(context).size.width - 80,


        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            infoCustomer(),

            timeAndDistanceWidget(),

            if(
            distanceBetweenTwoLocation(currentTrip.locationCustomer , currentTrip.locationDriver) <= 100
                && currentTrip.stateTrip == StateTrip.active
            )
              buttonStartTrip(),

            if(currentTrip.stateTrip == StateTrip.started)
              buttonFinishTrip(),


            if(currentTrip.stateTrip == StateTrip.active)
              rejectTrip(),

            Container(height: 10, color: Colors.white,)
          ],
        ),

      ),


    );
  }

  Row infoCustomer() {
    return Row(
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
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange,
                    child: Icon(Icons.person ,color: Colors.white,),),
                  title: Text("${currentTrip.nameCustomer??"-"}"),

                  trailing: Wrap(
                    spacing: 5.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [

                      Icon(Icons.star , color: Colors.deepOrange,),
                      Text("${currentTrip.ratingCustomer??"-"}")
                    ],
                  ),

                ),
              ),
            ),
          ),
        ),

      ],
    );
  }

  Row rejectTrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 60.5,
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.only(top: 15.0 , right: 15.0 , left: 15.0) ,
                child: MaterialButton(
                  color: Colors.red,
                  child: Text("Cancel" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),) , onPressed: () {

                },)
            ),
          ),
        ),

      ],
    );
  }

  Row timeAndDistanceWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[


        Expanded(
          child: Container(
            height: 60.5,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0 , right: 5.0 , left: 5.0) ,
              child: Text("KM : ${currentTrip.km.toStringAsFixed(2)??0.0}     min : ${currentTrip.minTrip??0}" , textAlign: TextAlign.center,),
            ),
          ),
        ),
      ],
    );
  }

  Row buttonStartTrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 60.5,
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.only(top: 15.0 , right: 15.0 , left: 15.0) ,
                child: MaterialButton(
                  color: Colors.deepOrange,
                  child: Text("Start trip" , style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ),) ,
                  onPressed: () {
                    this.setState(() {

                      currentTrip.stateTrip = StateTrip.started;
                    });

                    _firestore
                        .collection("Trips")
                        .doc(currentTrip.idTrip)
                        .update({
                      'state' :StateTrip.started.toString(),
                      'dateStart' :FieldValue.serverTimestamp()
                    });

                  },)
            ),
          ),
        ),

      ],
    );
  }

  Row buttonFinishTrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 60.5,
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.only(top: 15.0 , right: 15.0 , left: 15.0) ,
                child: MaterialButton(
                  color: Colors.deepOrange,
                  child: Text("Finish trip" , style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ),) ,
                  onPressed: () {
                    // this.setState(() {
                    //
                    //   currentTrip.stateTrip = StateTrip.started;
                    // });


                    _firestore
                        .collection("Trips")
                        .doc(currentTrip.idTrip)
                        .update({
                      'totalPrice' : calcPriceTotal() ,
                      'state' : StateTrip.done.toString()
                    });

                  },)
            ),
          ),
        ),

      ],
    );
  }

  double calcPriceTotal(){


    double startPrice = 0.55 ;

    double totalPriceMin = currentTrip.minTrip * 0.03;

    double totalKmPrice = currentTrip.km * 0.17;


    double totalPrice =  startPrice + totalKmPrice + totalPriceMin ;

    if(totalPrice < 1.15)
      totalPrice = 1.15 ;


    double discount = double.parse("0.${currentTrip.discount}");

    totalPrice = totalPrice  -  (totalPrice * discount);

    if(totalPrice < 0)
      totalPrice = 0.0 ;


    return double.parse(totalPrice.toStringAsFixed(2));

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

  double km = 0.0 ;

  _getAddressLine() async
  {
    debugPrint('location: ${position.latitude}');
    final coordinates = new coder.Coordinates(position.latitude, position.longitude);
    var addresses = await coder.Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print(" ${first.addressLine}");
  }

  onMapCreated( controller) {

    _completer.complete(controller);

    _controller  = controller ;

    var options = LocationOptions(accuracy: LocationAccuracy.low, distanceFilter: 20 );

    Geolocator.getPositionStream(desiredAccuracy: options.accuracy  , distanceFilter: options.distanceFilter).listen((position) {

      this.setState(() {
        this.position = position;
      });

      _getAddressLine();

      geoMyLocation = geo.point(latitude: position.latitude, longitude:position.longitude);

      DataProvider().userLocation = UserLocation(latitude: position.latitude , longitude:position.longitude  );


      markers.addAll([
        Marker(
            markerId: MarkerId('value'),
            position: LatLng(position.latitude, position.longitude),
            icon: carIcon,
            rotation: _direction),
      ]);


      FirebaseHelper()
          .checkLocationExit(auth.currentUser.uid)
          .then((isExit) => {

        if(isExit)
          FirebaseHelper()
              .updateLocationUser(auth.currentUser.uid, { 'name': 'random name', 'position': geoMyLocation.data})
        else
          FirebaseHelper()
              .insertLocationUser(auth.currentUser.uid, { 'available' : false   ,'idUser':'${auth.currentUser.uid}','name': 'random name', 'position': geoMyLocation.data})

      });

      // km+= 20 ;

      updateKm(20);

      print("KM : $km");




      animateTo(_completer, position.latitude, position.longitude);

      //   listenCurrentTrip();


      if(exitTrip)
        updateLocationDriverInTrip();

    });




  }

  void updateLocationDriverInTrip() {

    if(currentTrip.idTrip != null)
      _firestore
          .collection("Trips")
          .doc(currentTrip.idTrip)
          .update({
        'locationDriver' :{

          'lat': position.latitude ,
          'lng' : position.longitude ,
          'rotateDriver' : _direction

        }

      });

  }

  void updateRotateDriverInTrip() {

    if(currentTrip.idTrip != null)
      _firestore
          .collection("Trips")
          .doc(currentTrip.idTrip)
          .update({
        'locationDriver' :{

          'rotateDriver' : _direction

        }

      });

  }


  PolylineId id = PolylineId("poly");
  _addPolyLine() {


    Polyline polyline = Polyline(
        polylineId: id, color: Colors.deepOrange, points: polylineCoordinates);

    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline(LatLng origin ,LatLng dest ) async {
    poly.PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      DataProvider().mapKey,
      poly.PointLatLng(origin.latitude, origin.longitude),
      poly.PointLatLng(dest.latitude, dest.longitude),
      travelMode: poly.TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((poly.PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
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

  void addMarker(LatLng latLng) {


    final Marker marker = Marker(
      markerId: MarkerId("Customer"),
      position: latLng,
      onTap: () {
      },
    );

    markers.add(marker) ;

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

