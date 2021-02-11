import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/UI/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverBottomSheet extends StatelessWidget {
  const DriverBottomSheet({
    Key key,
  }) : super(key: key);

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
                              width: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StateDriver(),

                    SizedBox(height: 20.0,),

                    Center(

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(Icons.info_outline , size: 30, color: Colors.deepOrange,),
                          SizedBox(width: 10,),

                          Text("There is no request"  , style: TextStyle(fontSize: 20.0),),

                        ],
                      ),
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
                  alignment: Alignment.centerLeft,
                  child: Text(
                   isOnline ? "You're online"  : "You're offline",
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.grey.shade700,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 60.5,
            width: 120,
            color: Colors.grey[200],
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



class _RecommendedTrip extends StatelessWidget {
  final String postcode;
  final String addressLine1;
  const _RecommendedTrip({
    Key key,
    String postcode,
    String addressLine1,
  })  : this.postcode = postcode,
        this.addressLine1 = addressLine1,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        leading: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: ShapeDecoration(
              color: Colors.grey[200],
              shape: CircleBorder(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.location_on,
                size: 15,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              postcode,
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            Text(
              addressLine1,
              style: TextStyle(fontSize: 14, color: Colors.deepOrange),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 17,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
