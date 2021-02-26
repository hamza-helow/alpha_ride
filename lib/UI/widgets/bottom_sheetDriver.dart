import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Login.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:alpha_ride/Models/TripCustomer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverBottomSheet extends StatefulWidget {
  @override
  _DriverBottomSheetState createState() => _DriverBottomSheetState();
}

class _DriverBottomSheetState extends State<DriverBottomSheet> {
  bool exitTrip = false;
  final _firestore = FirebaseFirestore.instance;
  TripCustomer currentTrip;

  @override
  void initState() {
    checkExitRequest();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: true,
        initialChildSize: 0.19,
        minChildSize: 0.19,
        maxChildSize: 0.27,
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
                              width: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StateDriver(),
                    Center(
                      child: () {
                        if (!exitTrip)
                          return noRequestWidget();
                        else
                          return requestWidget();
                      }(),
                    ),
                    SizedBox(
                      height: 40.0,
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Row noRequestWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          size: 30,
          color: Colors.deepOrange,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          "There is no request",
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    );
  }

  Column requestWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
               cancelTrip();
              },
              child: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            InkWell(
              onTap: () {
                acceptTrip();
              },
              child: CircleAvatar(
                child: Icon(Icons.done),
              ),
            ),
            SizedBox(
              width: 200,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepOrange,
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                  ),
                ),
                title: Text(currentTrip.nameCustomer),
                subtitle: Text(currentTrip.phoneCustomer),
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.deepOrange,
              child: Icon(
                Icons.phone,
                color: Colors.white,
              ),
            ),
          ],
        ),

         Padding(padding: EdgeInsets.only(left: 10.0 ,  right: 10.0)
         ,
           child:  ListTile(
             leading: Icon(Icons.info),
             title: Text("Other information"),
             subtitle: Text(currentTrip.tripType == TypeTrip.distance ?"going to ${currentTrip.goingTo}" : "For ${currentTrip.hours} Hours" ),
             trailing: InkWell(
               onTap: () {

               },
               child: Text("Show location" ,style: TextStyle(fontWeight: FontWeight.bold),),
             ),
           ),
         )

      ],
    );
  }

  checkExitRequest() {
    _firestore
        .collection(FirebaseConstant().driverRequests)
         .doc(auth.currentUser.uid)
         .snapshots()
        .listen((event) {




      if (event.exists)
        this.setState(() {
          currentTrip = new TripCustomer(
              idCustomer: event.get("idCustomer"),
              phoneCustomer: event.get("phoneCustomer"),
              nameCustomer: event.get("nameCustomer"),
              lng: event.get("lng"),
              lat: event.get("lat"),
              goingTo: "",
              tripType: event.get("typeTrip") == TypeTrip.hours.toString() ? TypeTrip.hours :TypeTrip.distance ,
              hours: event.get("hours") ,
              stateRequest:
              event.get(FirebaseConstant().stateRequest));

          if (currentTrip.stateRequest == FirebaseConstant().pending)
            exitTrip = true;
          else
            exitTrip = false;
        });
      else
        {
          if(this.mounted)
          this.setState(() {
            exitTrip = false;
          });
        }
    });
  }

  void acceptTrip() {
    FirebaseHelper()
        .insertTrip(new Trip(
         idDriver: auth.currentUser.uid ,
         idCustomer: currentTrip.idCustomer ,
         locationCustomer: LatLng(currentTrip.lat , currentTrip.lng),
          locationDriver: LatLng(DataProvider().userLocation.latitude , DataProvider().userLocation.longitude ),
          rotateDriver: DataProvider().rotateCar,
        ))
        .then((value) {
      _firestore
          .collection(FirebaseConstant().driverRequests)
          .doc(auth.currentUser.uid)
          .delete();
    });
  }

  void cancelTrip() {

    FirebaseHelper()
        .cancelTripFromDriver(auth.currentUser.uid)
        .then((value) {
      _firestore
          .collection(FirebaseConstant().locations)
          .doc(auth.currentUser.uid)
          .update({FirebaseConstant().available: true});
    });
  }

}

class StateDriver extends StatefulWidget {
  @override
  _StateDriverState createState() => _StateDriverState();
}

class _StateDriverState extends State<StateDriver> {
  bool isOnline = false;

  final _firestore = FirebaseFirestore.instance;

  
  


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("locations").doc(auth.currentUser.uid).snapshots(),
        
        builder: (context, snapshot){

          if(snapshot.hasData)
           isOnline = snapshot.data.data()['available'];
          else
            isOnline = false;


          return  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 60.5,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        isOnline ? "You're online" : "You're offline",
                        style: TextStyle(
                          color: isOnline
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 60.5,
                width: 120,
                color: Colors.deepOrange[80],
                child: Padding(
                  padding: EdgeInsets.only(right: 14.0),
                  child: SizedBox(
                    width: 80.0,
                    child: Switch(
                      value: isOnline,
                      onChanged: (value) {
                        _firestore
                            .collection(FirebaseConstant().locations)
                            .doc(auth.currentUser.uid)
                            .update({FirebaseConstant().available: value});

                      },
                      activeColor: Colors.deepOrange,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
