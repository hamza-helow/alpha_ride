
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Models/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {

  String idCustomer , idDriver , state  , nameDriver ;

  LatLng locationDriver , locationCustomer ;

  Trip({this.idCustomer, this.idDriver, this.state , this.locationCustomer , this.locationDriver , this.nameDriver});

}