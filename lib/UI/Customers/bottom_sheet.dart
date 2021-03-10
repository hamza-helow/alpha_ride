import 'dart:async';
import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'file:///C:/Users/hamzi/AndroidStudioProjects/alpha_ride/lib/UI/Common/Login.dart';
import 'package:alpha_ride/Models/User.dart';
import 'file:///C:/Users/hamzi/AndroidStudioProjects/alpha_ride/lib/UI/Customers/PromoCodeBottomSheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

   String promoCode="" ;


   double priceByDistance  = 0.0;

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
            initialChildSize: 0.42,
            minChildSize: 0.2,
            maxChildSize: 0.50,
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
                    height: MediaQuery.of(context).size.height / 2,
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
            Text("${AppLocalizations.of(context).translate('findingDriver')}" , style: TextStyle(fontSize: 20.0),) ,
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
          padding: EdgeInsets.all(5.0),
          child:  ListTile(

            leading: Image.asset("Assets/enconomy.png"),
            title: Text("Enconomy"),
            trailing: Text("$closerTimeTrip"),
            subtitle: Text( widget.numberHours == 0 ?  DataProvider().priceByDistance==0 ?"" : "${DataProvider().priceByDistance} JD":  "${widget.numberHours * 10} JD" , style: TextStyle(color: Colors.green),),
          ),

        ),

        Divider(),
        Padding(
          padding: EdgeInsets.all(5.0),
          child:  ListTile(

            leading: CircleAvatar(
              backgroundColor: DataProvider().baseColor,
              child: Text("%" , style: TextStyle(color: Colors.white),),
            ),
            title: Text("${AppLocalizations.of(context).translate('discount')}"),
            trailing: Text(promoCode.isNotEmpty ?"$promoCode" :"${AppLocalizations.of(context).translate('addPromoCode')}"),
            onTap: () {
             // widget.showPromoCodeWidget();

              dialogPromoCode();
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

                      FirebaseHelper().checkIsUserBlocked().then((value) {


                        if(!value)
                          widget.getDriver();
                        else
                          dialog();

                      });



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
                Icon(Icons.star  ,color: DataProvider().baseColor,) , Text("${rating.toStringAsFixed(2)??"-"}"),
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
                    child: Text( widget.stateTrip == StateTrip.active ?  "${AppLocalizations.of(context).translate('cancel')}" : "${AppLocalizations.of(context).translate('tripStarted')}", style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ,fontSize: 22.0)),

                  ),
                ),

              ),


            ],

          ),
        ),

      ],
    );

  }

  void cancelTrip() async {

    FirebaseFirestore.instance.collection("Users").doc(auth.currentUser.uid).update({
      'countCancelTrip' : FieldValue.increment(1)
    });

    final userInfo =await FirebaseFirestore.instance.collection("Users").doc(auth.currentUser.uid).get();

    if(userInfo.get("countCancelTrip") >=3)
      FirebaseFirestore.instance.collection("BlockUsers").doc().set({
        'idUser' :auth.currentUser.uid,
        'date' : FieldValue.serverTimestamp()
      });


    FirebaseFirestore.instance
        .collection("Trips")
        .doc(widget.idTrip)
        .update({
       'state' : StateTrip.cancelByCustomer.toString()
       }).then((value){

         // if(widget.dateAccept != null &&  widget.dateAccept.difference(DateTime.now()).inSeconds *-1 > 30)
         // FirebaseFirestore
         //     .instance
         //     .collection("Users")
         //     .doc(auth.currentUser.uid)
         //     .update({
         //      'balance' : FieldValue.increment(-1.15)
         //     });

         FirebaseHelper().sendNotification(
           idSender: auth.currentUser.uid,
           idReceiver: widget.idDriver,
           title: "قام" + '${auth.currentUser.displayName}' +"بالغاء الرحلة"
         );

         });


  }

   dialog() async {
     await showDialog<String>(
         context: context,
         builder: (context) => new AlertDialog(
             content: Text("${AppLocalizations.of(context).translate('blockMessage')}") ,
             actions: []));
   }
   
   dialogPromoCode() async {
     await showDialog<String>(
         context: context,
         builder: (context) => new AlertDialog(
             content: Container(
               width: 400,
               height: 180,

               child: PromoCodeBottomSheet((){


                 this.setState(() {
                   promoCode =DataProvider().promoCode;
                 });

                 Navigator.pop(context);

               }),
             ) ,
             actions: []));
   }

}


