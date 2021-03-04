import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/Login.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/UI/Common/ResultTrip.dart';
import 'package:alpha_ride/UI/Common/TripsScreen.dart';
import 'package:alpha_ride/UI/widgets/CustomWidgets.dart';
import 'package:alpha_ride/UI/widgets/bottom_sheetDriver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart' as coder;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

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

  double ratingCustomer = 3.0 ;

  UserLocation userLocation ;

  final geo = Geoflutterfire();
  GeoFirePoint geoMyLocation ;
  final _firestore = FirebaseFirestore.instance;

  final int zoomIn = 0  , zoomOut = 1;

  var currentZoomLevel;
  var _controller ;

  double km = 0.0 ;

  LatLng last  ;

  Position position ;

  Completer<GoogleMapController> _completer = Completer();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();


  bool exitTrip = false  , showResultTrip = false ;

  Trip currentTrip ;

  //32.5661186,35.8420676
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(32.5661186, 35.8420676),
    zoom: 16.4746,
  );


  @override
  void initState() {

    print("intit");

    super.initState();

    currentTrip = Trip();

    initImageCar();
    listenCurrentTrip();
    loadInfoUser();

    getAarningsDay();
  }




  double aarningsDay = 0.0 ;

  void getAarningsDay(){
    FirebaseHelper().getAarningsDay(auth.currentUser.uid).then((value) {
      this.setState(() {
        aarningsDay = value;
      });
    });
  }

  void initImageCar() async{

    final Uint8List markerIcon = await getBytesFromAsset('Assets/car.png', 100);
    carIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }


  void listenCurrentTrip(){

    _firestore
        .collection("Trips")
        .where("state" , isNotEqualTo: StateTrip.done.toString())
        .where("idDriver" , isEqualTo: auth.currentUser.uid)
        .snapshots().listen((event) {

        this.setState(() {
          if(event.docs.length > 0) {
            exitTrip = true ;
            setupCurrentTrip(event);
          }// trip exit
          else
            exitTrip = false;

        });

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
            polylines: Set<Polyline>.of(polylines.values),

          ),

          if(!exitTrip)
            DriverBottomSheet(),
            buildAppBar(),

               if(showResultTrip)
               ResultTrip((){
                 this.setState(() {
                   exitTrip = false ;
                   showResultTrip = false ;
                   currentTrip = null ;

                   polylineCoordinates.clear();
                   polylines.clear();

                 });
               } ,currentTrip  ,typeUser: TypeAccount.driver,),

        ],

      ),

    );
  }

  void updateKm(double meter){

    print("Meter = $meter");

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
            color: DataProvider().baseColor,
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
              animateTo( position.latitude , position.longitude);

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
                  price: "$aarningsDay",
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

              if(exitTrip  && !showResultTrip)
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
                    backgroundColor: DataProvider().baseColor,
                    child: Icon(Icons.person ,color: Colors.white,),),
                  title: Text("${currentTrip.nameCustomer??"-"}"),

                  trailing: Wrap(
                    spacing: 5.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [

                      Icon(Icons.star , color: DataProvider().baseColor,),
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
                  color: DataProvider().baseColor,
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
                  color: DataProvider().baseColor,
                  child: Text("Finish trip" , style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ),) ,
                  onPressed: () {

                    this.setState(() {

                      showResultTrip = true ;
                    });

                    FirebaseHelper().updateCustomerPoint(currentTrip.idCustomer);

                    FirebaseHelper().resetRequestDriver().then((_) {
                      _firestore
                          .collection("Trips")
                          .doc(currentTrip.idTrip)
                          .update({
                        'totalPrice' : DataProvider().calcPriceTotal(currentTrip) ,
                        'state' : StateTrip.done.toString()
                      });

                    });



                  },)
            ),
          ),
        ),

      ],
    );
  }



  double balance = 100;
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
                backgroundColor: DataProvider().baseColor ,
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

                        Icons.monetization_on,
                          color: DataProvider().baseColor,
                          size: 21,
                        ),
                        backgroundColor: Colors.grey[200],
                        label: Text("$balance JD" , style: TextStyle(color: balance<0 ?Colors.red :null ),),
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
                          color: DataProvider().baseColor,
                          size: 21,
                        ),
                        backgroundColor: Colors.grey[200],
                        label: Text("${rating.toStringAsFixed(2)}"),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TripsScreen(typeAccount: TypeAccount.driver,),)),
              leading: Icon(Icons.time_to_leave_sharp),
              title: Text("You trips" ,),
              trailing: Padding(padding: EdgeInsets.only(right: 10), child: Text("10+" ,  style: TextStyle(color: DataProvider().baseColor),),),
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings" ,),
            ),


            Divider(),

            ListTile(
                onTap: () {

                  auth.signOut().then((value) =>  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login(),), (route) => false) );

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

    var options = LocationOptions(accuracy: LocationAccuracy.low, distanceFilter: 20 );

    Geolocator.getPositionStream(desiredAccuracy: options.accuracy  , distanceFilter: options.distanceFilter).listen((position) {

      this.setState(() {
        this.position = position;
      });

      geoMyLocation = geo.point(latitude: position.latitude, longitude:position.longitude);

      DataProvider().userLocation = UserLocation(latitude: position.latitude , longitude:position.longitude  );

      markers.addAll([
        Marker(
            markerId: MarkerId('value'),
            position: LatLng(position.latitude, position.longitude),
            icon: carIcon,
            rotation: _direction),
      ]);


      updateDriverInfo();


      calcKmCurrentTrip();


      animateTo( position.latitude, position.longitude);

      if(exitTrip)
        updateLocationDriverInTrip();

    });

  }

  Future<void> animateTo(double lat, double lng) async {
  final c = await _completer.future;
  final p = CameraPosition(target: LatLng(lat, lng), zoom: 17.0);
  c.animateCamera(CameraUpdate.newCameraPosition(p));
}

  String  _email ,_fullName;
  int points = 0 ;
  double rating=0.0 ;
  void loadInfoUser(){

    FirebaseFirestore.instance.collection("Users").doc(auth.currentUser.uid)
        .snapshots().listen((event) {
          SharedPreferencesHelper().setEmail(event.get('email'));
      SharedPreferencesHelper().setFullName(event.get("fullName"));
      SharedPreferencesHelper().setRating(event.get("rating") /event.get('countRating'));
      if(this.mounted)
        this.setState(() {
          _email= event.get('email');
          _fullName = event.get("fullName");
          rating = event.get("rating") /event.get('countRating');

        });
    });

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



    SharedPreferencesHelper().getRating().then((value) {

      if(this.mounted)
        this.setState(() {
          rating= value??0.0;
        });

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
        polylineId: id, color: DataProvider().baseColor, points: polylineCoordinates);

    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline(LatLng origin ,LatLng dest ) async {

    polylineCoordinates.clear();


    print("_getPolyline");

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

  void setupCurrentTrip(QuerySnapshot event) {

    if(currentTrip == null)
      currentTrip = Trip();

    FirebaseHelper().loadUserInfo(event.docs.first.get("idCustomer")).then((value) {

      this.setState(() {

        currentTrip.nameCustomer = value.fullName;
        currentTrip.idCustomer = event.docs.first.get("idCustomer");
        currentTrip.idDriver = event.docs.first.get("idDriver");
        currentTrip.ratingCustomer = value.rating;
        currentTrip.idTrip = event.docs.first.id;
        currentTrip.locationCustomer = LatLng(event.docs.first.get("locationCustomer.lat") , event.docs.first.get("locationCustomer.lng"));
        currentTrip.locationDriver = LatLng(event.docs.first.get("locationDriver.lat")??0.0 , event.docs.first.get("locationDriver.lng")??0.0) ;
        currentTrip.typeTrip =  event.docs.first.get("typeTrip") == TypeTrip.hours.toString() ? TypeTrip.hours :TypeTrip.distance ;
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

          //  currentTrip.hourTrip = DateTime.now().difference(currentTrip.startDate ).inHours.toString();

          currentTrip.km =  event.docs.first.get("km");

          currentTrip.discount = event.docs.first.get("discount");

          if(currentTrip.typeTrip == TypeTrip.distance){
            currentTrip.addressStart = event.docs.first.get("accessPoint.addressTo");
            currentTrip.accessPointLatLng = LatLng(event.docs.first.get("accessPoint.lat"), event.docs.first.get("accessPoint.lng"));

            _getPolyline(currentTrip.locationDriver,  currentTrip.accessPointLatLng);
          }

        }




        if(currentTrip.stateTrip == StateTrip.active){
          _getPolyline(currentTrip.locationCustomer,  currentTrip.locationDriver);

         // zoomBetweenTwoPoints(currentTrip.locationCustomer, currentTrip.locationDriver);

          addMarker(currentTrip.locationCustomer);

          print("DIS : ${ distanceBetweenTwoLocation(currentTrip.locationCustomer , currentTrip.locationDriver)}");

        }


      });


    });



  }

  void updateDriverInfo() {
    FirebaseHelper()
        .checkLocationExit(auth.currentUser.uid)
        .then((isExit) => {

      if(isExit)
        FirebaseHelper()
            .updateLocationUser(auth.currentUser.uid, {  'position': geoMyLocation.data})
      else
        FirebaseHelper()
            .insertLocationUser(auth.currentUser.uid, { 'available' : false   ,'idUser':'${auth.currentUser.uid}','position': geoMyLocation.data})

    });

  }

  void calcKmCurrentTrip() {

    if(currentTrip.stateTrip == StateTrip.started)
    if(currentTrip.typeTrip == TypeTrip.distance){
      if(last != null )
        updateKm(Geolocator.distanceBetween(last.latitude, last.longitude, position.latitude, position.longitude));
        last = LatLng(position.latitude, position.longitude);
    }
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
          backgroundColor: DataProvider().baseColor,

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
          backgroundColor: DataProvider().baseColor,

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
      width: MediaQuery.of(context).size.width/2.5,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        color: DataProvider().baseColor,
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
                  fontWeight: FontWeight.bold) ,overflow: TextOverflow.clip),
          Text(widget.price,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold) , overflow: TextOverflow.visible,),
        ],
      ),
    );
  }
}

