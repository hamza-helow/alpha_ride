import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Enum/TypeNotification.dart';
import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/UI/Common/Login.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:alpha_ride/Models/TripCustomer.dart';
import 'package:alpha_ride/Models/SettingApp.dart';
import 'package:alpha_ride/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class FirebaseHelper {


  FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  FirebaseHelper._privateConstructor();

  static final FirebaseHelper _instance = FirebaseHelper._privateConstructor();

  factory FirebaseHelper() {
    return _instance;
  }


  Future<void> insertInformationUser(User user) async {
    return _fireStore.collection("Users").doc(user.idUser).get().then((
        value) async {
      if (value.exists) //update
          {
        return _fireStore.collection("Users").doc(user.idUser).update({
          if(user.email != null)
            'email': user.email,
          if(user.emailFacebook != null)
            'emailFacebook': user.emailFacebook,
          'phoneNumber': user.phoneNumber,
          'imageProfile': user.imageProfile == null ? "" : user.imageProfile,
          'emailVerified' :user.emailVerified

        });
      }
      else { // insert

        return _fireStore.collection("Users").doc(user.idUser).set({

          'countCancelTrip': 0,

          'usePassword': user.usePassword,
          'fullName': user.fullName,
          'email': user.email,
          'typeUser': user.typeAccount.toString(),
          'countRating': 1,
          'rating': 5.0,
          'countTrips': 0,
          'stateAccount': user.stateAccount.toString(),
          'phoneNumber': user.phoneNumber,
          'points': 0,
          'emailVerified': user.emailVerified,
          'emailFacebook': user.emailFacebook,
          'imageProfile': user.imageProfile == null ? "" : user.imageProfile,
          'balance': 0.0
        });
      }
    });
  }


  Future<SettingApp> getSettingApp() async {
    final DocumentSnapshot doc = await FirebaseFirestore.instance.collection(
        "admin").doc("settings").get();

    return new SettingApp(hours: doc.get('hours'),
        km: doc.get('km'),
        min: doc.get('min'),
        percentageDriver: doc.get('percentageDriver'),
        startPrice: doc.get('startPrice'));
  }


  Future <void> updateCustomerPoint(String idUser) async {
    return FirebaseFirestore
        .instance
        .collection("Users")
        .doc(idUser).update({
      'points': FieldValue.increment(10),
      'countTrips': FieldValue.increment(1),
    });
  }


  Future<void> sendRequestToDriver(TripCustomer tripCustomer, idDriver) async {
    return FirebaseFirestore.instance
        .collection(FirebaseConstant().driverRequests)
        .doc(idDriver)
        .set({
      'idCustomer': auth.currentUser.uid,
      'nameCustomer': tripCustomer.nameCustomer,
      'phoneCustomer': "0788051422",
      'lat': tripCustomer.lat,
      'lng': tripCustomer.lng,
      'stateRequest': "pending",
      'discount': DataProvider().promoCodePercentage,
      'typeTrip': tripCustomer.tripType.toString(),
      'hours': tripCustomer.hours,
      if(tripCustomer.accessPoint != null)
        'currentAddress': tripCustomer.currentAddress,
      if(tripCustomer.accessPoint != null)
        "accessPoint": {
          'lat': tripCustomer.accessPoint.latitude,
          'lng': tripCustomer.accessPoint.longitude,
          'addressName': tripCustomer.goingTo
        }
    });
  }


  Future<void> insertTrip(Trip trip) async {
    return _fireStore.collection("Trips").doc().set({

      'date': DateFormat("yyyy/MM/dd").format(DateTime.now()),
      'idCustomer': trip.idCustomer,
      'idDriver': trip.idDriver,
      'dateStart': FieldValue.serverTimestamp(),
      'dateAcceptRequest': FieldValue.serverTimestamp(),
      'state': StateTrip.active.toString(),
      'km': 0.0,
      'totalPrice': 0.0,
      'hours': trip.hourTrip,
      'typeTrip': trip.typeTrip.toString(),
      'discount': trip.discount,
      'addressCurrent': trip.addressStart,

      if(trip.typeTrip == TypeTrip.distance)
        'accessPoint': {
          'lat': trip.accessPointLatLng.latitude,
          'lng': trip.accessPointLatLng.longitude,
          'addressTo': trip.addressEnd,
        },

      'locationCustomer': {
        'lat': trip.locationCustomer.latitude,
        'lng': trip.locationCustomer.longitude
      },
      'locationDriver': {
        'lat': trip.locationDriver.latitude,
        'lng': trip.locationDriver.longitude,
        'rotateDriver': trip.rotateDriver,
      }
    });
  }


  Future<void> resetRequestDriver() async {
    await _fireStore
        .collection(FirebaseConstant().driverRequests)
        .doc(auth.currentUser.uid)
        .delete();
  }

  Future<void> ratingUser(String idUser, double rating) async {
    _fireStore.collection("Users").doc(idUser).update({

      'rating': FieldValue.increment(rating),
      'countRating': FieldValue.increment(1)
    });
  }


  final geo = Geoflutterfire();

  Future<String> getCloserTimeTrip() async {
    if (DataProvider().userLocation == null)
      return "";

    GeoFirePoint center = geo.point(
        latitude: DataProvider().userLocation.latitude,
        longitude: DataProvider().userLocation.longitude);

    var collectionReference =
    _fireStore.collection('locations')
        .where(FirebaseConstant().available, isEqualTo: true);

    String field = 'position';

    Future<LatLng> latLng = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: 100, field: field)
        .first
        .then((value) async {
      if (value.isEmpty)
        return null;

      GeoPoint geoPoint = value.first.get("$field.geopoint");
      return LatLng(geoPoint.latitude, geoPoint.longitude);
    });

    if (latLng == null)
      return "";

    Future<String> time = latLng.then((value) async {
      return DataProvider().getArriveTime
        (LatLng(DataProvider().userLocation.latitude,
          DataProvider().userLocation.longitude)
          , LatLng(value.latitude, value.longitude)).then((value) async {
        return value;
      });
    });

    return time;
  }


  void sendNotification(
      {String idSender, String idReceiver, String title, String body , TypeNotification typeNotification = TypeNotification.arriveDriver}) {
    String idNotification = FirebaseDatabase
        .instance
        .reference()
        .child("Notification")
        .push()
        .key;

    FirebaseDatabase
        .instance
        .reference()
        .child("Notification/$idNotification")
        .set({

      "idSender": idSender,
      "idReceiver": idReceiver,
      "title": title,
      "body": body,
      "createdAt": DateTime.now().toString() ,
      "type" :typeNotification.toString()
    });

    FirebaseDatabase
        .instance
        .reference()
        .child("UsersNotification/$idReceiver").set({
      '$idSender': '$idNotification'
    });
  }


  Future<bool> infoUserExit(String idUser) {
    return _fireStore.collection("Users").doc(idUser).get().then((value) async {
      return value.exists;
    });
  }


  Future<double> getAarningsDay(String idDriver) {
    double total = 0.0;
    return _fireStore
        .collection("Trips")
        .where("idDriver", isEqualTo: idDriver)
        .where(
        "date", isEqualTo: DateFormat("yyyy/MM/dd").format(DateTime.now()))
        .get().then((value) async {
      print("getAarningsDay ${value.docs.length}");

      if (value.docs.length == 0)
        return 0.0;

      value.docs.forEach((element) {
        print("getAarningsDay ${element.get("dateStart")}");


        if (element.get("totalPrice") != null)
          total += element.get("totalPrice");
      });

      return total;
    });
  }


  Future<int> checkPromoCode(String code) async {
    final userInfo = await FirebaseHelper().loadUserInfo(
        auth.currentUser.uid, typeAccount: TypeAccount.customer);


    return _fireStore
        .collection(FirebaseConstant().promoCode)
        .where("endDate", isGreaterThanOrEqualTo: DateTime.now())
        .where("code", isEqualTo: code)
        .limit(1)

        .get().then((value) {
      if (value.docs.length == 0)
        return 0;

      if (!(value.docs.first.get("lessPoint") <= userInfo.points)) {
        print("LEEEES");
        return 0;
      }

      print("${value.docs.first.get("lessPoint")} < ${userInfo.points }");

      return value.docs.first.get(FirebaseConstant().percentagePromoCode);
    });
  }


  Future<bool> checkDriverHasActiveTrip(String idDriver) {
    return _fireStore.collection(FirebaseConstant().driverRequests).doc(
        idDriver).get().then((value) async {
      if (value.exists) {
        if (value.get(FirebaseConstant().stateRequest) == "rejected")
          return false;
        else
          return true;
      }
      else
        return false;
    });
  }

  Future<bool> checkLocationExit(String idUser) {
    return _fireStore.collection(FirebaseConstant().locations).doc(idUser)
        .get()
        .then((value) async {
      return value.exists;
    });
  }


  Future<void> updateLocationUser(String idUser,
      Map<String, dynamic> fields) async {
    await _fireStore
        .collection(FirebaseConstant().locations)
        .doc(idUser).update(fields);
  }


  Future<void> insertLocationUser(String idUser,
      Map<String, dynamic> fields) async {
    await _fireStore
        .collection(FirebaseConstant().locations)
        .doc(idUser).set(fields);
  }


  Future<void> cancelTripFromDriver(String idUser) async {
    await _fireStore
        .collection(FirebaseConstant().driverRequests)
        .doc(idUser).update({

      FirebaseConstant().stateRequest: FirebaseConstant().rejected
    });
  }


  Future<User> loadUserInfo(String idUser,
      {TypeAccount typeAccount = TypeAccount.customer }) {
    return _fireStore.collection("Users").doc(idUser).get().then((value) async {
      if (!value.exists)
        return null;

      return User(
          idUser: value.id,
          phoneNumber: value.data()['phoneNumber'],
          typeAccount: value.data()['typeUser'] ==
              TypeAccount.customer.toString()
              ? TypeAccount.customer
              : TypeAccount.driver,
          fullName: value.data()['fullName'],
          email: value.data()['email'],
          countRating: value.data()['countRating'] == 0 ? 1 : value
              .data()['countRating'],
          rating: value.data()['rating'] == 0.0 ? 5.0 : value.data()['rating'],
          carModel: typeAccount == TypeAccount.driver
              ? value.data()['carModel']
              : "",
          carType: typeAccount == TypeAccount.driver
              ? value.data()['carType']
              : "",
          carColor: typeAccount == TypeAccount.driver
              ? value.data()['carColor']
              : "",
          numberCar: typeAccount == TypeAccount.driver ? value
              .data()['numberCar'] : "",
          points: value.get('points')
      );
    });
  }


  Future<bool> checkIsUserBlocked() async {
    return FirebaseFirestore
        .instance
        .collection("BlockUsers")
        .where("idUser", isEqualTo: auth.currentUser.uid)
        .get()
        .then((value) async
    {
      if (value.docs.isEmpty)
        return false;
      else {
        final dateBlock = DateTime.parse(
            value.docs.first.get("date").toDate().toString());

        if (DateTime
            .now()
            .difference(dateBlock)
            .inHours < 24)
          return true;
        else {
          FirebaseFirestore
              .instance
              .collection("BlockUsers")
              .doc(value.docs.first.id).delete();

          FirebaseFirestore.instance.collection("Users").doc(
              auth.currentUser.uid).update({'countCancelTrip': 0});

          return false;
        }
      }
    }
    );
  }

  void updateTokenDevice() {
    FirebaseDatabase.instance.reference()
        .child("TokensDevices")
        .child(auth.currentUser.uid)
        .set({
         DataProvider().tokenDevice : 'true'
         });
  }


  void deleteTokenDevice() {
    FirebaseDatabase.instance.reference()
        .child("TokensDevices")
        .child(auth.currentUser.uid).remove();
  }

}