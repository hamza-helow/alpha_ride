import 'dart:async';
import 'dart:io';
import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/Helper/MapHelpers.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/Models/User.dart';
import 'package:alpha_ride/UI/Common/Login.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:google_maps_webservice/places.dart' as loc;

import 'package:alpha_ride/Models/TripCustomer.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/UI/Common/ResultTrip.dart';
import 'package:alpha_ride/UI/Common/Notification.dart' as ui ;
import 'package:alpha_ride/UI/Common/TripsScreen.dart';
import 'package:alpha_ride/UI/Common/ContactUs.dart';
import 'package:alpha_ride/UI/Customers/PromoCodeBottomSheet.dart';
import 'package:alpha_ride/UI/Customers/bottom_sheet.dart';
import 'package:alpha_ride/UI/Driver/homeDriver.dart';
import 'package:alpha_ride/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:alpha_ride/UI/Common/Settings.dart' as w;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//key0
// key password : hh0788051422**@@
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GeoFirePoint geoFirePoint;

  StreamSubscription<DocumentSnapshot> subscriptionRequestDriver ;

  StreamSubscription<DocumentSnapshot> subscriptionChangeAccount ;
  StreamSubscription<ConnectivityResult> subscriptionConnectivity;
  StreamSubscription<List<DocumentSnapshot>> subscriptionStreamCloserDriver;

  StreamSubscription<List<DocumentSnapshot>> subscriptionStreamCloserAllDrivers;


  @override
  void dispose() {
    super.dispose();

    if(subscriptionRequestDriver != null)
    subscriptionRequestDriver.cancel();

    if(subscriptionConnectivity != null )
    subscriptionConnectivity.cancel();

    if(subscriptionStreamCloserAllDrivers != null)
      subscriptionStreamCloserAllDrivers.cancel();

    if(subscriptionChangeAccount != null )
      subscriptionChangeAccount.cancel();

  }


  var locationReference;
  var _controller;
  final String field = 'position';
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: "AIzaSyAhZEFLG0WG4T8kW7lo8S_fjbSV8UXca7A");
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final Completer<GoogleMapController> _completer = Completer();

  String idDriver = "",
      closerTimeTrip = "",
      addressTo = "",
      _currentAddress = "";
  double radius = 1, accessPointLat, accessPointLng, rating = 0;
  List<String> rejected = List();
  bool findDriver = false;

  final Trip currentTrip = Trip();

  Set<Marker> markers = Set();
  Map<PolylineId, Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];

  poly.PolylinePoints polylinePoints = poly.PolylinePoints();

  final int zoomIn = 0, zoomOut = 1;

  int points = 0;

  double balance = 0.0;

  UserLocation userLocation;

  bool internetNotConnect= false ;
  bool confirmPickup = false,
      showPromoCode = false;
  Stream<List<DocumentSnapshot>> streamCloserDrivers;

  final CameraPosition defaultPosition = CameraPosition(
    target: LatLng(32.5661186, 35.8420676),
    zoom: 17.4746,
  );

  void _onCameraMove(CameraPosition position) async {

    DataProvider().userLocation = UserLocation(
        latitude: position.target.latitude,
        longitude: position.target.longitude);


  }

  String _fullName = "", _email = "", selectedDriver = "";

  BitmapDescriptor carIcon;



  Timer timer  ;
  void timerCancelTrip(){
    timer = Timer.periodic(Duration(seconds: 7), (timer) {

      print("Time : ${timer.tick}");

      if(timer.tick == 7){
        timer.cancel();
        FirebaseFirestore.instance.collection("driverRequests").doc(idDriver).delete();
        subscriptionStreamCloserDriver.cancel();
        rejected.add(idDriver);
        radius = 0 ;
        getDriver();

      }

    });

  }

  void getDriver() {

    print("Call  getDriver");

    this.setState(() {
      findDriver = true;
    });
    print("getDriver");

    if (DataProvider().userLocation != null) {
      geoFirePoint = geo.point(
          latitude: DataProvider().userLocation.latitude,
          longitude: DataProvider().userLocation.longitude);
      locationReference = _firestore
          .collection('locations')
          .where(FirebaseConstant().available, isEqualTo: true);

      streamCloserDrivers = geo
          .collection(collectionRef: locationReference)
          .within(center: geoFirePoint, radius: radius, field: field);
    }

    if(radius >150)
      return;


    subscriptionStreamCloserDriver =  streamCloserDrivers.listen((event) {
      DocumentSnapshot currentDriver = event.firstWhere(
        (element) => !rejected.contains(element.data()['idUser']),
        orElse: () => null,
      );
      if (findDriver) if (currentDriver == null) {
        print("$radius");
        radius++;
        getDriver();
      } else {
        FirebaseHelper()
            .checkDriverHasActiveTrip(currentDriver.data()['idUser'])
            .then((exit) {
          if (!exit)
           {
             timerCancelTrip();
             subscriptionStreamCloserDriver.cancel();
             sendRequestToDriver(currentDriver.data());
           }
          else {
            if (findDriver) {
              radius = 0 ;
              radius++;
              getDriver();
            }
          }
        });
      }
    });
  }

  void sendRequestToDriver(Map<String, dynamic> dataDriver) {
    this.setState(() {
      idDriver = dataDriver['idUser'];
    });

    if (findDriver)
      FirebaseHelper()
          .sendRequestToDriver(
              TripCustomer(
                idCustomer: auth.currentUser.uid,
                discount: DataProvider().promoCodePercentage,
                lat: DataProvider().userLocation.latitude,
                lng: DataProvider().userLocation.longitude,
                nameCustomer: '',
                phoneCustomer: '',
                stateRequest: 'pending',
                goingTo: addressTo,
                hours: numberHours,
                currentAddress: _currentAddress,
                tripType: numberHours == 0 ? TypeTrip.distance : TypeTrip.hours,
                accessPoint:
                    LatLng(accessPointLat ?? 0.0, accessPointLng ?? 0.0),
              ),
              idDriver)
          .then((_) {
        listenRequestDriver(idDriver);
        FirebaseHelper().sendNotification(
            title: "لديك طلب جديد من :",
            body: '${auth.currentUser.displayName}',
            idReceiver: idDriver,
            idSender: auth.currentUser.uid);
      });
  }

  void deleteRequest() {

    if(timer != null)
      timer.cancel();

    this.setState(() {
      findDriver = false;
      if (idDriver.isNotEmpty)
        _firestore
            .collection(FirebaseConstant().driverRequests)
            .doc(idDriver)
            .delete();
    });
  }

  void listenRequestDriver(String idDriver) async {
    subscriptionRequestDriver = FirebaseFirestore.instance
        .collection(FirebaseConstant().driverRequests)
        .doc(idDriver)
        .snapshots()
        .listen((event) {
      print("listenRequestDriver");
      if (!event.exists){

        // not thing
      }
        else if (event.data()['stateRequest'] == "rejected") {
        radius = 1;
        rejected.add(idDriver);
        getDriver();
      }
        else if (event.data()['stateRequest'] == "pending")
          {

            // not thing
          }

        else {
          timer.cancel();
          rejected.clear();
        subscriptionRequestDriver.cancel();
        return;
      }
    });
  }

  dialogInternetNotConnect() async {

    internetNotConnect = true;

    await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            child: new AlertDialog(
            content: Text("${AppLocalizations.of(context).translate('noInternetConnection')}") ,
            actions: []),
             onWillPop:(){},)
    );
  }

  void getNearDrivers(){

    if (userLocation != null) {
      geoFirePoint = geo.point(
          latitude: userLocation.latitude,
          longitude: userLocation.longitude);
      locationReference = _firestore
          .collection('locations')
          .where(FirebaseConstant().available, isEqualTo: true);

      streamCloserDrivers = geo
          .collection(collectionRef: locationReference)
          .within(center: geoFirePoint, radius: 100, field: field);

      subscriptionStreamCloserAllDrivers =  streamCloserDrivers.listen((event) {

        print("position.geopoint${event.length}");

        event.forEach((element) {
          print("position.geopoint${element.get("position.geopoint").latitude}");
         this.setState(() {
           showMarkerDriver(
               element.get("position.geopoint").latitude ,
               element.get("position.geopoint").longitude, 0 , id:element.id );
         });
        });

      });
    }
  }

  @override
  void initState() {

    whenCustomerHasBecomeDriver();
    FirebaseHelper().updateTokenDevice();
    getCurrentLocation();

    checkInternetExit();

    super.initState();
  }


  void checkInternetExit(){
    subscriptionConnectivity = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {

      if(result == ConnectivityResult.none )
        dialogInternetNotConnect();
      else
      {
        if(internetNotConnect)
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home(),), (route) => false);
        else{
          loadInfoUser();
          //listenCurrentTrip();

          BitmapDescriptor.fromAssetImage(
              ImageConfiguration(platform: TargetPlatform.android),
              "Assets/car.png")
              .then((onValue) {
            carIcon = onValue;
          });
        }
      }


    });

  }

  void loadInfoUser() async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(auth.currentUser.uid)
        .snapshots()
        .listen((event) {
      SharedPreferencesHelper().setPoints(int.parse('${event.get("points")}'));
      SharedPreferencesHelper().setEmail(event.get('email'));
      SharedPreferencesHelper().setFullName(event.get("fullName"));
      SharedPreferencesHelper()
          .setRating(event.get("rating") / event.get('countRating'));

      if (this.mounted)
        this.setState(() {
          _email = event.get('email');
          _fullName = event.get("fullName");
          rating = event.get("rating") / event.get('countRating');
          points = int.parse('${event.get("points")}');
          balance = event.get('balance');
        });
    });

    _email = await SharedPreferencesHelper().getEmail();

    _fullName = await SharedPreferencesHelper().getFullName();

    rating = await SharedPreferencesHelper().getRating();

    SharedPreferencesHelper().getPoints().then((value) {
      print("Type : ${value.runtimeType}");

      // if(this.mounted)
      //   this.setState(() {
      //     points= value??0;
      //   });
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

    return  WillPopScope(

      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Trips")
            .where("state", whereIn: [
          StateTrip.active.toString(),
          StateTrip.started.toString(),
          StateTrip.needRatingByCustomer.toString()
        ])
            .where("idCustomer", isEqualTo: auth.currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {

          final exitTrip =snapshot.hasData && snapshot.data.docs.length > 0 ;

          if(exitTrip)
            if(timer != null)
              timer.cancel();

          // if(!exitTrip){
          //
          //   markers.clear();
          //   polylines.clear();
          //   polylineCoordinates.clear();
          // }

          findDriver = findDriver?!exitTrip : false ;

          if (exitTrip &&
              snapshot.data.docs.first.get("state") ==
                  StateTrip.started.toString())
            animateTo(snapshot.data.docs.first.get('locationDriver.lat'),
                snapshot.data.docs.first.get('locationDriver.lng'));

          if (exitTrip && snapshot.data.docs.first.get("state") == StateTrip.active.toString()){
            {

              markers.clear() ;
              showMarkerDriver(snapshot.data.docs.first.get('locationDriver.lat'), snapshot.data.docs.first.get('locationDriver.lng'), 0);

              _getPolyline(
                  LatLng(snapshot.data.docs.first.get('locationCustomer.lat'), snapshot.data.docs.first.get('locationCustomer.lng'))
                  ,  LatLng(snapshot.data.docs.first.get('locationDriver.lat'), snapshot.data.docs.first.get('locationDriver.lng'))).then((value) {
                _addPolyLine();
              });
            }
          }
          else if (exitTrip && snapshot.data.docs.first.get("state") == StateTrip.started.toString())
          {
            polylines.clear();
            polylineCoordinates.clear();
          }

          if (exitTrip && snapshot.data.docs.first.get("state") == StateTrip.needRatingByCustomer.toString())
            rejected.clear();

          return Scaffold(
            key: _scaffoldKey,
            drawer: buildDrawer(),
            body: Stack(
              children: [

                googleMapBuilder(exitTrip, snapshot, cameraPosition),

                buttonsZoom(),

                buttonCurrentLocation(),

                if(!exitTrip)
                  pin(context),
                startTrip(),

                buildAppBar(),

                if (exitTrip && snapshot.data.docs.first.get("state") == StateTrip.needRatingByCustomer.toString())
                  ResultTrip(
                    typeUser: TypeAccount.customer,
                    idUser: snapshot.data.docs.first.get("idDriver"),
                    name: "",
                    totalTrip: snapshot.data.docs.first.get("totalPrice"),
                    typeTrip: snapshot.data.docs.first.get('typeTrip') ==
                        TypeTrip.distance.toString() ? TypeTrip.distance : TypeTrip.hours,
                    idTrip: snapshot.data.docs.first.id
                    ,
                  ),

                if ((snapshot.hasData && snapshot.data.docs.length > 0) && snapshot.data.docs.first.get("state") != StateTrip.needRatingByCustomer.toString())
                  CustomerBottomSheet(
                    onCancelTrip: () {
                      if(timer != null)
                      timer.cancel();

                    },
                    dateAccept: DateTime.parse(snapshot.data.docs.first
                        .get("dateAcceptRequest")
                        .toDate()
                        .toString()),
                    idTrip: snapshot.data.docs.first.id,
                    locationCustomer: LatLng(
                        snapshot.data.docs.first.get("locationCustomer.lat"),
                        snapshot.data.docs.first.get("locationCustomer.lng")),
                    locationDriver: LatLng(
                        snapshot.data.docs.first.get("locationDriver.lat"),
                        snapshot.data.docs.first.get("locationDriver.lng")),
                    stateTrip: () {
                      var state = snapshot.data.docs.first.get("state");
                      if (state == StateTrip.active.toString())
                        return StateTrip.active;
                      else if (state == StateTrip.rejected.toString())
                        return StateTrip.rejected;
                      else
                        return StateTrip.started;
                    }(),
                    findDriver: exitTrip ?  false : findDriver,
                    getDriver: () {
                      getDriver();
                    },
                    deleteRequest: () => deleteRequest(),
                    tripActive: snapshot.data.docs.first.get("state") ==
                        StateTrip.active ||
                        snapshot.data.docs.first.get("state") ==
                            StateTrip.started,
                    numberHours: numberHours,
                    idDriver: snapshot.data.docs.first.get("idDriver"),
                    callBack: () {
                      this.setState(() {
                        confirmPickup = false;
                      });
                    },
                    onStateTripChanged: (stateTrip) {},
                    showPromoCodeWidget: () {
                      this.setState(() {
                        showPromoCode = true;
                      });
                    },
                  ),

                if (confirmPickup &&
                    !(snapshot.hasData && snapshot.data.docs.length > 0))
                  CustomerBottomSheet(
                    onCancelTrip: () {
                      if(timer != null)
                        timer.cancel();
                    },
                    stateTrip: StateTrip.none,
                    findDriver: exitTrip ?  false : findDriver,
                    getDriver: () {
                      getDriver();
                    },
                    deleteRequest: () => deleteRequest(),
                    tripActive: false,
                    numberHours: numberHours,
                    idDriver: null,
                    callBack: () {
                      this.setState(() {
                        confirmPickup = false;
                        numberHours = 0.0 ;
                      });
                    },
                    onStateTripChanged: (stateTrip) {},
                    showPromoCodeWidget: () {
                      this.setState(() {
                        showPromoCode = true;
                      });
                    },
                  ),

                if (showPromoCode)
                  PromoCodeBottomSheet(() {
                    this.setState(() {
                      showPromoCode = false;
                    });
                  }),
              ],
            ),
          );
        },
      ),

      onWillPop: () {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("${AppLocalizations.of(context).translate('confirmExit')}"),
                content: Text("${AppLocalizations.of(context).translate('wantToExit')}"),
                actions: <Widget>[
                  MaterialButton(
                    child: Text("${AppLocalizations.of(context).translate('yes')}" , style: TextStyle(color: DataProvider().baseColor)),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                  MaterialButton(
                    child: Text("${AppLocalizations.of(context).translate('no')}" , style: TextStyle(color: DataProvider().baseColor),),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
        );
      //  return Future.value(true);
      },
    );
  }

  StreamBuilder<List<DocumentSnapshot>> googleMapBuilder(bool exitTrip, AsyncSnapshot<QuerySnapshot> snapshot, CameraPosition cameraPosition) {
    return StreamBuilder<List<DocumentSnapshot>>(
              stream: geo
                  .collection(collectionRef: _firestore.collection('locations').where(FirebaseConstant().available, isEqualTo: true))
                  .within(center:userLocation ==null ? GeoFirePoint(0,0) : GeoFirePoint(userLocation.latitude, userLocation.longitude), radius: 100, field: field),

              builder: (context, drivers) {

                if(drivers.hasData && !exitTrip)
                drivers.data.forEach((element) {
                  showMarkerDriver(
                      element.get("position.geopoint").latitude ,
                      element.get("position.geopoint").longitude, 0 , id:element.id );
                });

               return GoogleMap(
                  initialCameraPosition: () {
                    if (exitTrip &&
                        snapshot.data.docs.first.get("state") ==
                            StateTrip.started.toString())
                      return CameraPosition(
                        target: LatLng(
                            snapshot.data.docs.first.get('locationDriver.lat'),
                            snapshot.data.docs.first.get('locationDriver.lng')),
                        zoom: 16.4,
                      );
                    else {
                      if (cameraPosition != null)
                        return cameraPosition;
                      else
                        return defaultPosition;
                    }
                  }(),
                  compassEnabled: false,
                  markers: markers,
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
                  polylines: Set<Polyline>.of(polylines.values),
                );

              },

            );
  }

  Positioned buttonsZoom() {
    return Positioned(
      bottom: 100,
      right: 15,
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
                  onPressed: () {
                   MapHelpers.getInstance().changeZoom(_controller , userLocation ,typeZoom: zoomIn);
                  }),
              SizedBox(height: 2),
              IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () =>  MapHelpers.getInstance().changeZoom(_controller , userLocation ,typeZoom: zoomOut),
              )
            ],
          ),
        ),
      ),
    );
  }

  Positioned buttonCurrentLocation() {

    return Positioned(
      bottom: 200,
      right: 15,
      child: Card(
        elevation: 2,
        child: Container(
          color: Color(0xFFFAFAFA),
          width: 40,
          height: 40,
          child: IconButton(
              icon: Icon(Icons.gps_fixed),
              onPressed: () {
                animateTo(userLocation.latitude, userLocation.longitude);
              }),
        ),
      ),
    );
  }


  void whenCustomerHasBecomeDriver(){

    subscriptionChangeAccount= FirebaseFirestore
        .instance
        .collection("Users")
        .doc(auth.currentUser.uid)
        .snapshots().listen((event) {

         if(event.data()['typeUser'] == TypeAccount.driver.toString())
           {

             print("TypeChange ${ event.data()['typeAccount']}");

             SharedPreferencesHelper().setSetTypeAccount(TypeAccount.driver);
             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeDriver(),), (route) => false);


             // FirebaseHelper().deleteTokenDevice().then((value) {
             //
             // //  auth.signOut();
             //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Login(),), (route) => false);
             // });


           }

         });


  }

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

  Positioned startTrip() {
    return Positioned(
      left: 35,
      bottom: 20,
      right: 35,
      child: Visibility(
        maintainState: true,
        maintainAnimation: true,
        visible: !confirmPickup,
        child: MaterialButton(
          height: 60.0,
          color: DataProvider().baseColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(color: DataProvider().baseColor)),
          onPressed: () {
            setState(() {
              confirmPickup = true;

              print("true");
            });
          },
          child: Text(
            "${AppLocalizations.of(context).translate('confirmPickup')}",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22.0),
          ),
        ),
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
              SizedBox(
                width: 15,
              ),
              GestureDetector(
                onTap: () => {_scaffoldKey.currentState.openDrawer()},
                child: Icon(
                  Icons.menu,
                  size: 30.0,
                  color: DataProvider().baseColor,
                ),
              ),
              SizedBox(
                width: 20,
              ),
                Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 11,
                              offset: Offset(3.0, 4.0))
                        ],
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(10)),
                        border: new Border.all(
                          color: Colors.white,
                          width: 1.0,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width - 100,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    // show input autocomplete with selected mode
                                    // then get the Prediction selected
                                    Prediction p = await PlacesAutocomplete.show(
                                      components: [new Component(Component.country , "jo")],
                                      radius: 1000,
                                      language: AppLocalizations.of(context).locale.languageCode == "en" ?"en" : "ar",
                                       location: loc.Location(DataProvider().userLocation.latitude , DataProvider().userLocation.longitude) ,
                                        mode: Mode.overlay,
                                        context: context,
                                        apiKey: DataProvider().mapKey,
                                        logo: Text("") );
                                    displayPrediction(p);
                                  },
                                  child: Container(
                                    height: 60.5,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${AppLocalizations.of(context).translate('whereTo')}',
                                          style: TextStyle(
                                            fontSize: 22,
                                          ),
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
                                      child:GestureDetector(
                                        onTap: () => dialogReserveHours(),
                                        child:  Chip(
                                          avatar: Icon(
                                            Icons.watch_later,
                                            color: DataProvider().baseColor,
                                            size: 21,
                                          ),
                                          backgroundColor: Colors.grey[200],
                                          label: RichText(
                                            text: TextSpan(
                                              children: <InlineSpan>[
                                                TextSpan(
                                                  text: numberHours == 0.0
                                                      ? '${AppLocalizations.of(context).translate('now')}'
                                                      : '$numberHours',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                WidgetSpan(
                                                  child: SizedBox(
                                                    width: 2.5,
                                                  ),
                                                ),
                                                WidgetSpan(
                                                  alignment:
                                                  PlaceholderAlignment
                                                      .middle,
                                                  child: Icon(Icons
                                                      .keyboard_arrow_down),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          if (_currentAddress.isNotEmpty)
                            Container(
                              color: Colors.white,
                              child: ListTile(
                                title: Text("$_currentAddress"),
                                leading: Icon(Icons.location_pin),
                              ),
                            ),
                          if (addressTo.isNotEmpty)
                            Container(
                              color: Colors.white,
                              child: ListTile(
                                trailing: GestureDetector(
                                  onTap: () {
                                    this.setState(() {
                                      addressTo = "";
                                      DataProvider().priceByDistance = 0.0 ;

                                        markers.clear();
                                        polylines.clear();
                                        polylineCoordinates.clear();
                                    });
                                  },
                                  child: Icon(Icons.clear),
                                ),
                                title: Text("$addressTo"),
                                leading: Icon(Icons.location_searching_rounded),
                              ),
                            )
                        ],
                      )),
                ),
              SizedBox(
                width: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }


  final picker = ImagePicker();

  void updateImageProfile() async {

    List<ImageSource> l ;

    final pickedFile = await picker.getImage(source: ImageSource.gallery);


    final ref =     FirebaseStorage
        .instance.ref()
        .child("UsersImage")
        .child(auth.currentUser.uid).
        child("imgProfile");


    ref.putFile(File(pickedFile.path)).then((result) {

      ref.getDownloadURL().then((value) => {

        FirebaseFirestore
            .instance.collection("Users")
            .doc(auth.currentUser.uid)
             .update({
               'imageProfile' : value
              })
      });

    });



  }

  Drawer buildDrawer() {
    return Drawer(
      child: FutureBuilder<User>(
        future: FirebaseHelper().loadUserInfo(auth.currentUser.uid , typeAccount: TypeAccount.customer),
        builder: (context, user) => Container(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              GestureDetector(

                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  accountName: Text("${ !user.hasData || user.data == null ?  "" : user.data.fullName}",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  accountEmail:
                  Text((){
                    if(!user.hasData || user.data == null)
                      return "";

                    if(user.data.email.isEmpty)
                      return  user.data.phoneNumber ;
                    else
                      return  user.data.email ;
                  }(), style: TextStyle(color: Colors.black54)),
                  currentAccountPicture: GestureDetector(
                    onTap: () => {
                      updateImageProfile()
                    },
                    child: CircleAvatar(
                      backgroundImage: () {
                        if (!user.hasData || user.data == null)
                          return null;

                        else if (user.data.imageProfile.isEmpty)
                          return null ;
                        else
                          return !user.hasData && user.data.imageProfile.isEmpty
                              ? null
                              : NetworkImage(user.data.imageProfile);
                      }(),
                      backgroundColor: DataProvider().baseColor,
                      child:!user.hasData ||
                          user.data == null ||
                          user.data.imageProfile == null ||
                          user.data.imageProfile.isEmpty
                          ? Icon(
                        FontAwesomeIcons.user,
                        color: Colors.white,
                      )
                          : null,
                    ),
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
                            color: DataProvider().baseColor,
                            size: 21,
                          ),
                          backgroundColor: Colors.grey[200],
                          label: Text("$points ${AppLocalizations.of(context).translate('point')}"),
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
                          label: Text("${ rating ==null || rating == 0 ? 0: rating.toStringAsFixed(2)}"),
                        ),
                      ),
                    ),
                  ),
                ],
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
                            Icons.monetization_on_rounded,
                            color: DataProvider().baseColor,
                            size: 21,
                          ),
                          backgroundColor: Colors.grey[200],
                          label: Text(
                            "${balance.toStringAsFixed(2)} ${AppLocalizations.of(context).translate('jd')}",
                            style: TextStyle(
                                color: balance < 0 ? Colors.red : Colors.green),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripsScreen(),
                    )),
                leading: Icon(Icons.time_to_leave_sharp),
                title: Text(
                  "${AppLocalizations.of(context).translate('yourTrips')}",
                ),

              ),
              ListTile(
                onTap: () {
                  _scaffoldKey.currentState.openEndDrawer();
                  dialogReserveHours();
                },
                leading: Icon(Icons.access_time),
                title: Text(
                  "${AppLocalizations.of(context).translate('reserveHours')}",
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(right: 10),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ui.Notification(typeAccount: TypeAccount.customer,),
                      ));
                },
                leading: Icon(Icons.notifications),
                title: Text(
                  "${AppLocalizations.of(context).translate('notification')}",
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => w.Settings(),
                      ));
                },
                leading: Icon(Icons.settings),
                title: Text(
                  "${AppLocalizations.of(context).translate('setting')}",
                ),
              ),
              Divider(),
              ListTile(
                onTap: () =>Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUs(),)),
                leading: Icon(Icons.contact_support),
                title: Text(
                  "${AppLocalizations.of(context).translate('contactUs')}",
                ),
              ),
              ListTile(
                onTap: () {
                  FirebaseHelper().deleteTokenDevice();
                  auth
                      .signOut()
                      .then((value) => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                          (route) => false));
                },
                leading: Icon(Icons.logout),
                title: Text(
                  "${AppLocalizations.of(context).translate('logout')}",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onMapCreated(controller) {
    if(!_completer.isCompleted)
    _completer.complete(controller);
    _controller = controller;

  }

  void getCurrentLocation() async{


    Geolocator.getCurrentPosition().then((value) => {
          this.setState(() {
            userLocation = UserLocation(
                latitude: value.latitude, longitude: value.longitude);

            print("UserLocation ${userLocation.longitude} ${userLocation.latitude} ");

            DataProvider().userLocation = userLocation;

            MapHelpers.getInstance().getAddressFromLatLng(userLocation.latitude, userLocation.longitude)
                .then((address) => {
                      this.setState(() {
                        _currentAddress = address;
                        animateTo(value.latitude, value.longitude);
                        //showMarkerDriver(value.latitude , value.longitude);
                      })
                    });
          })
        });
  }

  PolylineId id = PolylineId("poly");

  _addPolyLine() {
    Polyline polyline = Polyline(
        polylineId: id,
        color: DataProvider().baseColor,
        points: polylineCoordinates);
       polylines[id] = polyline;



   // setState(() {});
  }

Future<void>  _getPolyline(LatLng origin, LatLng dest) async {
    poly.PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      DataProvider().mapKey,
      poly.PointLatLng(origin.latitude, origin.longitude),
      poly.PointLatLng(dest.latitude, dest.longitude),
      travelMode: poly.TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((poly.PointLatLng point) {
        if(polylines.isEmpty)
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
  }


  double numberHours = 0;

  dialogReserveHours() async {
    String err;

    final hours = TextEditingController();

    await showDialog<String>(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => new AlertDialog(
                  contentPadding: EdgeInsets.all(20.0),
                  title: Text("${AppLocalizations.of(context).translate('reserveHours')}"),
                  content: TextField(
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    controller: hours,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty || double.parse(value) > 24)
                          err = "please enter correct number";
                        else
                          err = null;
                      });
                    },
                    decoration: InputDecoration(
                      helperText: "${AppLocalizations.of(context).translate('canReserveSpecific')}",
                      errorText: err,
                      labelText: "${AppLocalizations.of(context).translate('selectNumberHours')}",
                      border: new OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("${AppLocalizations.of(context).translate('cancel')}",
                          style: TextStyle(
                              color: DataProvider().baseColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          if (hours.text.isEmpty)
                            err = "${AppLocalizations.of(context).translate('enterCorrectNumber')}";
                          return;
                        });

                        if (hours.text.isEmpty) return;

                        if (err == null)
                          this.setState(() {
                            confirmPickup = true;
                            numberHours = double.parse(hours.text);
                          });
                        Navigator.pop(context);
                      },
                      child: Text(
                        "${AppLocalizations.of(context).translate('confirm')}",
                        style: TextStyle(
                            color: DataProvider().baseColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                  ]),
            ));
  }

  Future<void> animateTo(double lat, double lng) async {
    final c = await _completer.future;
    final p = CameraPosition(
        target: LatLng(lat, lng), zoom: 17);
    c.animateCamera(CameraUpdate.newCameraPosition(p));
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      MapHelpers.getInstance().getAddressFromLatLng(lat, lng).then((value) => {
            this.setState(() {
              addressTo = value;
              accessPointLat = lat;
              accessPointLng = lng;

                markers.clear();
                polylines.clear();
                polylineCoordinates.clear();

              DataProvider().accessPointAddress = value ;


          //    zoomBetweenTwoPoints(LatLng( DataProvider().userLocation.latitude,  DataProvider().userLocation.longitude), LatLng(accessPointLat, accessPointLng));


              _getPolyline(LatLng( DataProvider().userLocation.latitude,  DataProvider().userLocation.longitude), LatLng(accessPointLat, accessPointLng))

                  .then((value) {
                _addPolyLine();

              });



              DataProvider().calcApproximatePrice(LatLng(lat, lng), LatLng(userLocation.latitude, userLocation.longitude)).then((value) {

                this.setState(() {
                  DataProvider().priceByDistance = value;
                });

              });

            })
          });
    }
  }

  whenDriverComing(double lat, double lng, double latCustomer,
      double lngCustomer, double rotateDriver) {

    print("whenDriverComing , $lat , $lng");

    if (polylines.isEmpty) {
      _getPolyline(LatLng(latCustomer, lngCustomer), LatLng(lat, lng));

      MapHelpers.getInstance().zoomBetweenTwoPoints(LatLng(latCustomer, lngCustomer), LatLng(lat, lng) , _controller);
    }

    showMarkerDriver(lat, lng, rotateDriver);
  }

  void clearPolyline() {
    this.setState(() {
      polylineCoordinates.clear();
      polylines.clear();
    });
  }

  void showMarkerDriver(double lat, double lng, double rotateDriver , {String id= "current"}) {
    markers.addAll([
      Marker(
          markerId: MarkerId(id),
          position: LatLng(lat, lng),
          icon: carIcon,
          rotation: rotateDriver),
    ]);

    print("marker : ${markers.length}");
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





}
