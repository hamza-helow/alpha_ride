import 'dart:async';
import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Login.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:alpha_ride/Models/TripCustomer.dart';
import 'package:cloud_firestore/cloud_firestore.dart' ;
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class CustomerBottomSheet extends StatefulWidget {
  final Function callBack , showPromoCodeWidget;

  final Function( double ,double , double customerLat , double customerLng , double rotateDriver)  whenDriverComing;

  final Function(StateTrip stateTrip) onStateTripChanged;

  final numberHours ;

  CustomerBottomSheet({this.callBack , this.whenDriverComing , this.showPromoCodeWidget , this.onStateTripChanged , this.numberHours});

  @override
  _CustomerBottomSheetState createState() => _CustomerBottomSheetState();
}

class _CustomerBottomSheetState extends State<CustomerBottomSheet> {

   final String field = 'position';

   StreamSubscription<DocumentSnapshot> subscription;

  var locationReference;

  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;

  String idDriver ="" , closerTimeTrip = "";
  double radius = 1;

  List<String > rejected ;

  bool findDriver = false , tripActive = false;

  Trip currentTrip ;

 GeoFirePoint geoFirePoint ;


 Stream<List<DocumentSnapshot>> streamCloserDrivers ;
  @override
  void initState() {
    init();
    super.initState();
  }

  void init(){

    FirebaseHelper().getCloserTimeTrip().then((value) {

      if(this.mounted)
        this.setState(() {
          closerTimeTrip = value;
        });

    });
    currentTrip = Trip();
    rejected = List();
    listenCurrentTrip();


  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: true,
        initialChildSize: 0.37,
        minChildSize: 0.2,
        maxChildSize: 0.38,
        builder: (context, scrollController) {
          return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
              return true;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: ClampingScrollPhysics(),
              child: Container(
                color: Color(0xF2FFFFFF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[


                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[300],
                              ),
                              height: 5,
                              width: 40,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if(!findDriver && !tripActive )
                      confirmationTripWidget(),

                    if(tripActive)
                      driverInfo(),

                    if(findDriver)
                      searchDriverWidget(),

                    SizedBox(height: 20.0, )
                  ],
                ),
              ),
            ),
          );
        });
  }

  SizedBox searchDriverWidget() {
    return SizedBox(
      height: 230,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Finding driver.." , style: TextStyle(fontSize: 20.0),) ,
            SizedBox(height: 15.0,),
            CircularProgressIndicator() ,

            SizedBox(height: 15.0,),

            Padding(
              padding: EdgeInsets.only(
                  top: 10 ,
                  bottom: 10.0
              ),

              child: SizedBox(
                width: 100.0,

                child:  MaterialButton(
                  color: Colors.deepOrange,

                  shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.red)
                  ),

                  onPressed: () {

                    this.setState(() {
                      findDriver = false ;
                      if(idDriver.isNotEmpty)
                        _firestore
                            .collection(FirebaseConstant().driverRequests)
                            .doc(idDriver)
                            .delete();
                    });
                  },
                  height: 60.0,
                  child: Icon(Icons.clear ,color: Colors.white,),

                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

  Widget confirmationTripWidget(){

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),

          child:  ListTile(

            leading: Image.asset("Assets/enconomy.png"),
            title: Text("Enconomy"),
            trailing: Text("$closerTimeTrip"),
            subtitle: Text( widget.numberHours == 0 ? "":  "${widget.numberHours * 10} JD" , style: TextStyle(color: Colors.green),),

          ),

        ),

        Divider(),

        Padding(
          padding: EdgeInsets.all(10.0),

          child:  ListTile(

            leading: CircleAvatar(
              backgroundColor: Colors.deepOrange,
              child: Text("%" , style: TextStyle(color: Colors.white),),
            ),
            title: Text("Discount"),
            trailing: Text(DataProvider().promoCode.isNotEmpty ?"${DataProvider().promoCode}" :"Add promo code"),
            onTap: () {
              widget.showPromoCodeWidget();
            },

          ),

        ),

        Padding(
          padding: EdgeInsets.all(10.0),

          child:  Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,


            children: [

              Padding(
                padding: EdgeInsets.only(
                    top: 10 ,
                    bottom: 10.0
                ),

                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.20,

                  child:  MaterialButton(
                    color: Colors.deepOrange,

                    shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Colors.red)
                    ),

                    onPressed: () {

                      widget.callBack();
                    },
                    height: 50.0,
                    child: Icon(Icons.arrow_back_ios_rounded ,color: Colors.white,),

                  ),
                ),

              ),

              Padding(
                padding: EdgeInsets.only(
                    top: 10 ,
                    bottom: 10.0 ,
                    left: 7.0
                ),

                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,

                  child:  MaterialButton(
                    color: Colors.deepOrange,

                    shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Colors.red)
                    ),

                    onPressed: () {

                      getDriver();

                    },
                    height: 50.0,
                    child: Text("YALLA", style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ,fontSize: 22.0)),

                  ),
                ),

              ),


            ],

          ),
        ),

      ],
    );

  }

  Widget driverInfo(){

    return Column(

      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.0 ,right: 10.0),

          child:  ListTile(

            leading: CircleAvatar(
              backgroundColor: Colors.deepOrange,
              child: Icon(Icons.person  , color: Colors.white,),
            ),
            title: Text(currentTrip.nameDriver??""),
            subtitle: Row(

              children: [
                Icon(Icons.star  ,color: Colors.deepOrange,) , Text("${currentTrip.ratingDriver??"-"}"),
              ],

            ),

            trailing: Text("${currentTrip.arriveTime??"-"}"),

          ),

        ),

        Divider(),


        Padding(
          padding: EdgeInsets.only(left: 10.0 ,right: 10.0),

          child:  ListTile(

            leading: Image.asset("Assets/enconomy.png"),
            title: Text("${currentTrip.carType} ${currentTrip.carModel}"),
            trailing: Text("Red color"),
            subtitle: Text("15687988"),

          ),

        ),

        Padding(
          padding: EdgeInsets.all(1.0),

          child:  Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Padding(
                padding: EdgeInsets.only(
                    top: 10 ,
                    bottom: 10.0 ,
                    left: 7.0
                ),

                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,

                  child:  MaterialButton(
                    color: currentTrip.stateTrip == StateTrip.active ? Colors.red : Colors.green ,

                    shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: currentTrip.stateTrip == StateTrip.active ? Colors.red : Colors.green)
                    ),

                    onPressed: () {

                      //  getDriver();

                    },
                    height: 50.0,
                    child: Text( currentTrip.stateTrip == StateTrip.active ?  "Cancel" : "Trip started", style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ,fontSize: 22.0)),

                  ),
                ),

              ),


            ],

          ),
        ),

      ],
    );

  }

  void getDriver() {

    this.setState(() {
      findDriver =true;
    });

    if(DataProvider().userLocation != null){
      geoFirePoint = geo.point(latitude: DataProvider().userLocation.latitude, longitude: DataProvider().userLocation.longitude);
      locationReference =
          _firestore.collection('locations')
              .where(FirebaseConstant().available , isEqualTo: true);

      streamCloserDrivers = geo.collection(collectionRef: locationReference)
          .within(center: geoFirePoint, radius: radius, field: field);
    }

    streamCloserDrivers.listen((event) {

      DocumentSnapshot currentDriver =   event.firstWhere((element) => !rejected.contains(element.data()['idUser']) , orElse: () => null,);
      if(findDriver)
        if(currentDriver == null)
        {
          print("$radius");
          radius ++ ;
          getDriver() ;

        }
        else{

          FirebaseHelper().checkDriverHasActiveTrip(currentDriver.data()['idUser'])
              .then((exit) {

            if(!exit)
              sendRequestToDriver(currentDriver.data());
            else
            {
              if(findDriver){
                radius ++ ;
                getDriver() ;
              }

            }
          });



        }


    });


  }

  void sendRequestToDriver(Map<String, dynamic> dataDriver){

    idDriver  = dataDriver['idUser'] ;

    if(findDriver)
    FirebaseHelper().sendRequestToDriver(
      TripCustomer(
        idCustomer: auth.currentUser.uid,
        discount: DataProvider().promoCodePercentage,
        lat: DataProvider().userLocation.latitude,
        lng:  DataProvider().userLocation.longitude,
        nameCustomer: '',
        phoneCustomer: '',
        stateRequest: 'pending',
        goingTo: DataProvider().accessPointAddress,
        hours: widget.numberHours,
        tripType: widget.numberHours == 0 ? TypeTrip.distance: TypeTrip.hours,
      ),
      idDriver
    ).then((_) {
      listenRequestDriver(idDriver);
    });

  }


  void listenRequestDriver (String idDriver) async{

    subscription  =
    _firestore
        .collection(FirebaseConstant().driverRequests)
        .doc(idDriver)
        .snapshots()
        .listen((event) {

          print("event Lis");
      if(event.exists)
        if(event.data()['stateRequest'] == "rejected")
        {
          radius =  1 ;
          rejected.add(idDriver);
          getDriver();
        }
        else
        {
          subscription.cancel();
          listenCurrentTrip();
          return;
        }

    });


  }

  void listenCurrentTrip (){
    _firestore
        .collection("Trips")
        .where("state" , whereIn: [StateTrip.active.toString(),StateTrip.started.toString()])
        .where("idCustomer" , isEqualTo: auth.currentUser.uid)
        .snapshots().listen((event) {
      if(this.mounted)
        this.setState(() {
          if(event.size > 0 ){
            tripActive = true ;
            setupCurrentTrip(event);
          }
          else
            tripActive = false ;
        });

    });

  }

  LatLng driverLocation ;
  void setupCurrentTrip(event){
    FirebaseHelper().loadUserInfo(event.docs.first.get("idDriver") , typeAccount: TypeAccount.driver).then((value)  {

      print("CCCCC  ${event.docs.first.id}");
      if(this.mounted)
      this.setState(() {

        currentTrip.idCustomer= "";
        currentTrip.idDriver =event.docs.first.get("idDriver") ;
        currentTrip.nameDriver = value.fullName ;
        currentTrip.ratingDriver = value.rating/value.countRating ;
        currentTrip.locationCustomer =  LatLng(event.docs.first.get("locationCustomer.lat") , event.docs.first.get("locationCustomer.lng")) ;
        currentTrip.locationDriver = LatLng(event.docs.first.get("locationDriver.lat") , event.docs.first.get("locationDriver.lng")) ;
        currentTrip.carType =value.carType;
        currentTrip.carModel= value.carModel;
        currentTrip.stateTrip = (){
          var state = event.docs.first.get("state");

          if(state == StateTrip.active.toString())
            return StateTrip.active ;
          else if(state == StateTrip.rejected.toString())
            return StateTrip.rejected ;
          else
            return StateTrip.started ;
        }();

        widget.onStateTripChanged(currentTrip.stateTrip);
        widget.whenDriverComing(currentTrip.locationDriver.latitude , currentTrip.locationDriver.longitude , currentTrip.locationCustomer.latitude , currentTrip.locationCustomer.longitude ,event.docs.first.get("locationDriver.rotateDriver")  );



          DataProvider().getArriveTime(currentTrip.locationCustomer , currentTrip.locationDriver).then((arriveTime) {

          this.setState(() {
            currentTrip.arriveTime = arriveTime;
          });

        });


      });

    });

  }

}


