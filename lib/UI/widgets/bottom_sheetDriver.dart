import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:alpha_ride/UI/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class DriverBottomSheet extends StatefulWidget {
  @override
  _DriverBottomSheetState createState() => _DriverBottomSheetState();
}

class _DriverBottomSheetState extends State<DriverBottomSheet> {

   bool exitTrip = false ;

   final _firestore = FirebaseFirestore.instance;

   Trip currentTrip ;

   @override
  void initState() {


    _firestore
         .collection(FirebaseConstant().driverRequests)
         .snapshots().listen((event) {

      print(event.docs.length);

      if(event.docs.length> 0)
        this.setState(() {

          currentTrip = new Trip(
            idCustomer: event.docs.first.get("idCustomer"),
            phoneCustomer: event.docs.first.get("phoneCustomer"),
            nameCustomer: event.docs.first.get("nameCustomer"),
            lng: event.docs.first.get("lng"),
             lat: event.docs.first.get("lat"),
          );

          exitTrip = true ;
        });
      else
        this.setState(() {
          exitTrip = false ;
        });


    });


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

                      child: (){

                        if(!exitTrip)
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Icon(Icons.info_outline , size: 30, color: Colors.deepOrange,),
                              SizedBox(width: 10,),

                              Text("There is no request"  , style: TextStyle(fontSize: 20.0),),

                            ],
                          );
                         else
                           return Column(
                             children: [

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.clear ,color: Colors.white, ),
                                  ),
                                  SizedBox(width: 10.0,),
                                  CircleAvatar(
                                    child: Icon(Icons.done),
                                  ),

                                  SizedBox(
                                    width: 200,

                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.deepOrange,
                                        child: Icon(Icons.person_outline_rounded , color: Colors.white,),
                                      ),
                                      title: Text(currentTrip.nameCustomer),
                                      subtitle: Text(currentTrip.phoneCustomer),
                                    ),
                                  ) ,

                                  CircleAvatar(
                                    backgroundColor: Colors.deepOrange,
                                    child: Icon(Icons.phone , color: Colors.white,),
                                  ),

                                ],
                              )


                             ],
                           );



                      } (),
                    ),


                    // _RecommendedTrip(
                    //     postcode: 'irbid', addressLine1: 'Design District'),
                    // Divider(),
                    // _RecommendedTrip(
                    //     postcode: 'YF82 2LO', addressLine1: 'Flutter Avenue'),

                    SizedBox(height: 40.0,)
                  ],
                ),
              ),
            ),
          );
        });
  }
}




class StateDriver extends StatefulWidget {
  @override
  _StateDriverState createState() => _StateDriverState();
}

class _StateDriverState extends State<StateDriver> {

  bool isOnline = false ;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
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
                   isOnline ? "You're online"  : "You're offline",
                    style: TextStyle(
                      color: isOnline ? Colors.green.shade700 : Colors.grey.shade700,
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
                child: Switch(value: isOnline,
                  onChanged: (value) {

                  _firestore.collection(FirebaseConstant().locations)
                      .doc(auth.currentUser.uid)
                       .update({
                        FirebaseConstant().available : value
                        });

                    this.setState(() {
                      isOnline = value ;
                    });

                  },

                  activeColor: Colors.deepOrange,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}



