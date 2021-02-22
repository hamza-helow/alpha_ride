
class FirebaseConstant {

  FirebaseConstant._privateConstructor();

  static final FirebaseConstant _instance = FirebaseConstant._privateConstructor();

  factory FirebaseConstant() {
    return _instance;
  }


  final String available = "available";
  final String locations ="locations";
  final String driverRequests = "driverRequests";
  final String stateRequest ="stateRequest";

  final String pending = "pending";
  final String  rejected = "rejected";

  final String promoCode = "promoCode";

  final String percentagePromoCode ="percentage";




}