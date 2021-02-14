import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/UI/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';


class CustomerBottomSheet extends StatefulWidget {
  final Function callBack;

  CustomerBottomSheet({this.callBack});

  @override
  _CustomerBottomSheetState createState() => _CustomerBottomSheetState();
}

class _CustomerBottomSheetState extends State<CustomerBottomSheet> {

  List<String > rejected ;

  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;

  bool findDriver = false;

  @override
  void initState() {
    rejected = List();
   // rejected.add("NNIjAVmI4qaio7ila09rBXVDtTb2");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: true,
        initialChildSize: 0.37,
        minChildSize: 0.2,
        maxChildSize: 0.37,
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

                    if(!findDriver)
                    confirmationTripWidget(),

                    if(findDriver)
                      SizedBox(
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
                      ),

                    SizedBox(height: 20.0, )
                  ],
                ),
              ),
            ),
          );
        });
  }


  Widget confirmationTripWidget(){

    return Column(

      children: [
        Padding(
          padding: EdgeInsets.all(10.0),

          child:  ListTile(

            leading: Image.asset("Assets/enconomy.png"),
            title: Text("Enconomy"),
            trailing: Text("1 min"),

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
            trailing: Text("Add promo code"),

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
                   height: 60.0,
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
                   height: 60.0,
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


  String idDriver ="";
  double radius = 1;



  void getDriver() {

    this.setState(() {
      findDriver =true;
    });

    // Create a geoFirePoint
    GeoFirePoint center = geo.point(latitude: DataProvider().userLocation.latitude, longitude: DataProvider().userLocation.longitude);

     // get the collection reference or query
      var collectionReference =
      _firestore.collection('locations')
          .where(FirebaseConstant().available , isEqualTo: true);
          //.orderBy("idUser" ,descending: false)
          //.where(FirebaseConstant().available , isNotEqualTo: "0");


    String field = 'position';

    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference)
    .within(center: center, radius: radius, field: field);

           stream.listen((event) {

              if(findDriver)
             if(event.isEmpty)
              {
                print("$radius");
                radius ++ ;
                getDriver() ;

              }
             else{

            //   event.where((element) => element.)

              // List<DocumentSnapshot> currentDriver =   event.where((element) => !rejected.contains(element.data()['idUser']));

               //print("${event[0].exists}  EXIT DRIVER");

               if(event.isNotEmpty)
               sendRequestToDriver(event[0].data());
             }


        });


  }


  void sendRequestToDriver(Map<String, dynamic> dataDriver){

    idDriver  = dataDriver['idUser'] ;

    if(findDriver)
    _firestore
        .collection(FirebaseConstant().driverRequests)
        .doc(dataDriver['idUser'])
        .set({
         'idCustomer' : auth.currentUser.uid,
          'nameCustomer' : "hamza helow" ,
          'phoneCustomer' : "0788051422" ,
            'lat' : DataProvider().userLocation.latitude,
           'lng' : DataProvider().userLocation.longitude
         });


  }

}


class _ConfirmTrip extends StatelessWidget {
  const _ConfirmTrip({
    Key key,
  }) : super(key: key);

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
              color: Colors.grey[200],
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
                    backgroundColor: Colors.white,
                    label: TimeSelectorWidget(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TimeSelectorWidget extends StatelessWidget {
  const TimeSelectorWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: 'Now',
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
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.keyboard_arrow_down),
          ),
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
