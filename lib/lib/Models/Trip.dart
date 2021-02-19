
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Models/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {


  String idCustomer ,
      idDriver , state  , nameDriver ,
      arriveTime , carType , carModel
      ,nameCustomer , idTrip;

  LatLng locationDriver , locationCustomer ;

  double ratingDriver  , rotateDriver , ratingCustomer;


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
    this.rotateDriver ,
    this.nameCustomer,
    this.ratingCustomer ,
    this.idTrip
  });

}