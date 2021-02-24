import 'package:alpha_ride/Enum/TypeTrip.dart';

class TripCustomer {
  String idCustomer, nameCustomer, phoneCustomer, stateRequest;

  double lat, lng;

  String goingTo = "";

  TypeTrip tripType;

  int hours = 0;

  TripCustomer(
      {this.idCustomer,
      this.nameCustomer,
      this.phoneCustomer,
      this.lat,
      this.lng,
      this.stateRequest,
      this.goingTo,
      this.hours,
        this.tripType
      });
}
