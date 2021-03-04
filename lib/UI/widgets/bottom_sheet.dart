import 'dart:async';
import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Login.dart';
import 'package:alpha_ride/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerBottomSheet extends StatefulWidget {
  final Function callBack , showPromoCodeWidget;


  final Function(StateTrip stateTrip) onStateTripChanged;

  final Function getDriver , deleteRequest;

  final numberHours ;
 // final Trip currentTrip ;

  final  String idDriver ;

   bool findDriver , tripActive ;

   StateTrip stateTrip ;
   //String arriveTime ;

  LatLng locationCustomer , locationDriver ;

  final  String idTrip;

  final DateTime dateAccept ;

  CustomerBottomSheet({this.callBack ,this.idTrip,this.dateAccept ,
      this.showPromoCodeWidget ,
    this.onStateTripChanged , this.numberHours ,
      this.tripActive = false , this.getDriver ,
    this.findDriver = false , this.idDriver , this.deleteRequest , this.stateTrip , this.locationDriver , this.locationCustomer});

  @override
  _CustomerBottomSheetState createState() => _CustomerBottomSheetState();
}

class _CustomerBottomSheetState extends State<CustomerBottomSheet> {

   String  closerTimeTrip = "";

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

  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: FirebaseHelper().loadUserInfo(widget.idDriver , typeAccount: TypeAccount.driver),


      builder: (context, snapshot) {

        print(" builder: (context, snapshot)  builder: (context, snapshot)  builder: (context, snapshot)");

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

                        // if(!widget.findDriver && !widget.tripActive )

                        if(!widget.findDriver &&snapshot.data == null )
                          confirmationTripWidget(),

                        if(snapshot.data != null )
                          driverInfo(
                              rating: snapshot.data.rating / snapshot.data.countRating,
                              carModel: snapshot.data.carModel,
                              carType: snapshot.data.carType ,
                              colorCar: snapshot.data.carColor,
                              numberCar: snapshot.data.numberCar,
                              name: snapshot.data.fullName
                          ),

                        if(widget.findDriver)
                          searchDriverWidget(),

                        SizedBox(height: 20.0, )
                      ],
                    ),
                  ),
                ),
              );
            });
      }

    );
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
                  color: DataProvider().baseColor,

                  shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.red)
                  ),

                  onPressed: () {

                    widget.deleteRequest();

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
              backgroundColor: DataProvider().baseColor,
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
                    color: DataProvider().baseColor,

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
                    color: DataProvider().baseColor,

                    shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Colors.red)
                    ),

                    onPressed: () {

                      widget.getDriver();

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

  Widget driverInfo({String name , double rating, carType , carModel , colorCar , numberCar } ){

    return Column(

      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.0 ,right: 10.0),

          child:  ListTile(

            leading: CircleAvatar(
              backgroundColor: DataProvider().baseColor,
              child: Icon(Icons.person  , color: Colors.white,),
            ),
            title: Text(name??""),
            subtitle: Row(

              children: [
                Icon(Icons.star  ,color: DataProvider().baseColor,) , Text("${rating??"-"}"),
              ],

            ),

            trailing: FutureBuilder<String>(
              future: widget.stateTrip == StateTrip.active ?
              DataProvider().getArriveTime(widget.locationCustomer , widget.locationDriver) : Future.value("--"),

              builder: (context, snapshot) => Text("${ snapshot.data??"-"}"),
            ),

          ),

        ),

        Divider(),


        Padding(
          padding: EdgeInsets.only(left: 10.0 ,right: 10.0),

          child:  ListTile(

            leading: Image.asset("Assets/enconomy.png"),
            title: Text("${carType??""} ${carModel??""}"),
            trailing: Text("${colorCar??""}"),
            subtitle: Text("${numberCar??""}"),

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
                    color: widget.stateTrip == StateTrip.active ? Colors.red : Colors.green ,

                    shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: widget.stateTrip == StateTrip.active ? Colors.red : Colors.green)
                    ),

                    onPressed: () {

                      if(widget.stateTrip == StateTrip.active)
                        cancelTrip() ;

                    },
                    height: 50.0,
                    child: Text( widget.stateTrip == StateTrip.active ?  "Cancel" : "Trip started", style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ,fontSize: 22.0)),

                  ),
                ),

              ),


            ],

          ),
        ),

      ],
    );

  }

  void cancelTrip() {


    FirebaseFirestore.instance
        .collection("Trips")
        .doc(widget.idTrip)
        .update({
       'state' : StateTrip.cancelByCustomer.toString()
       }).then((value){

         if(widget.dateAccept.difference(DateTime.now()).inSeconds *-1 > 30)
         FirebaseFirestore
             .instance
             .collection("Users")
             .doc(auth.currentUser.uid)
             .update({
              'balance' : FieldValue.increment(-1.15)
             });

         FirebaseHelper().sendNotification(
           idSender: auth.currentUser.uid,
           idReceiver: widget.idDriver,
           title: "قام" + '${auth.currentUser.displayName}' +"بالغاء الرحلة"
         );

         });


  }


}


