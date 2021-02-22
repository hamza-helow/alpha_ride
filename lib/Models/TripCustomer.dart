class TripCustomer {
  String idCustomer, nameCustomer, phoneCustomer, stateRequest;

  double lat, lng;

  int discount = 0;

  TripCustomer(
      {this.idCustomer,
      this.nameCustomer,
      this.phoneCustomer,
      this.lat,
      this.lng,
      this.stateRequest,
      this.discount});
}
