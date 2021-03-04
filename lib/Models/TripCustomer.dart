import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripCustomer {
  String idCustomer, nameCustomer, phoneCustomer, stateRequest;

  double lat, lng;

  LatLng accessPoint ;

  String goingTo  , currentAddress;

  TypeTrip tripType;

  double hours = 0;

  int discount ;





  TripCustomer(
      {this.idCustomer,
      this.nameCustomer,
      this.phoneCustomer,
      this.lat,
      this.lng,
      this.stateRequest,
      this.goingTo ="",
      this.hours,
        this.tripType,
        this.discount,
        this.currentAddress = "",
        this.accessPoint
      });
}
