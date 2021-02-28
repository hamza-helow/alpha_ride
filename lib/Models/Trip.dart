import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Models/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {

  String idCustomer ,
      idDriver , state  , nameDriver
  , arriveTime , carType , carModel , idTrip , nameCustomer;

  LatLng locationDriver , locationCustomer ;

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
    this.nameDriver ,
    this.ratingDriver,
    this.carModel ,
    this.carType ,
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
    this.totalPrice
  });

}