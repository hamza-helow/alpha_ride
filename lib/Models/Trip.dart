import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {

  String idCustomer ,
      idDriver , state  , nameDriver
  , arriveTime , carType , carModel , idTrip , nameCustomer , carColor;

  LatLng locationDriver , locationCustomer , accessPointLatLng ;

  double ratingDriver  , rotateDriver , ratingCustomer;



  StateTrip stateTrip ;

  TypeTrip typeTrip ;

  double hourTrip ;
  int minTrip ;

  DateTime startDate ;

  double km = 0.0 , totalPrice;

  int discount = 0 ;

  String addressStart , addressEnd ;


  Trip({
    this.idCustomer,
    this.idDriver,
    this.state ,
    this.locationCustomer ,
    this.locationDriver ,
    this.nameDriver ="" ,
    this.ratingDriver,
    this.carModel ="" ,
    this.carType ="" ,
    this.rotateDriver,
    this.idTrip,
    this.ratingCustomer,
    this.stateTrip ,
    this.hourTrip ,
    this.minTrip = 0 ,
    this.startDate,
    this.km = 0.0,
    this.discount,
    this.typeTrip ,
    this.totalPrice,
    this.carColor = "",
    this.nameCustomer = "",
    this.accessPointLatLng,
    this.addressEnd,
    this.addressStart,
    this.arriveTime
  });



  factory Trip.fromJson(QueryDocumentSnapshot doc) => new  Trip(


    idTrip:  doc.id ,
    km: double.parse('${doc.get("km")}'),
    typeTrip: doc.get("typeTrip") == TypeTrip.distance.toString() ? TypeTrip.distance : TypeTrip.hours,
    startDate:doc.get("dateStart")==null ?  null: DateTime.parse(doc.get("dateStart").toDate().toString())  ,
    minTrip: doc.get("dateStart")==null ?  0:  DateTime.now().difference(DateTime.parse(doc.get("dateStart").toDate().toString())).inMinutes   ,
    stateTrip: (){

      final state = doc.get("state") ;
      if (state == StateTrip.active.toString())
        return StateTrip.active;
      else if (state == StateTrip.started.toString())
        return StateTrip.started;
      else if (state == StateTrip.needRatingByDriver.toString())
        return StateTrip.needRatingByDriver;
      else if (state == StateTrip.needRatingByCustomer.toString())
        return StateTrip.needRatingByCustomer;

      else if (state == StateTrip.cancelByDriver.toString())
        return StateTrip.cancelByDriver;

      else if (state == StateTrip.cancelByCustomer.toString())
        return StateTrip.cancelByCustomer;

      else
        return StateTrip.done;


    }()  ,

    idDriver: doc.get("idDriver"),
    idCustomer: doc.get('idCustomer'),
    hourTrip: doc.get('hours'),
    discount: doc.get('discount'),
    locationCustomer: LatLng(doc.get("locationCustomer.lat") , doc.get("locationCustomer.lng") ),
    locationDriver: LatLng(doc.get("locationDriver.lat") , doc.get("locationDriver.lng") ),
    totalPrice: doc.get('totalPrice') == null ? 0.0 :doc.get('totalPrice') ,
    accessPointLatLng:  !doc.data().containsKey("accessPoint") ? null  :  doc.get('accessPoint.lat') == 0.0 ? null:  LatLng(doc.get('accessPoint.lat') , doc.get('accessPoint.lng')) ,
    addressStart: doc.get('addressCurrent'),
    addressEnd:  !doc.data().containsKey("accessPoint")  ? "" :  doc.get('accessPoint.addressTo'),

  );

}

//You direct the captain