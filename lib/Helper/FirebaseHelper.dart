

import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/FirebaseConstant.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:alpha_ride/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseHelper {


  FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  FirebaseHelper._privateConstructor();

  static final FirebaseHelper _instance = FirebaseHelper._privateConstructor();

  factory FirebaseHelper() {
    return _instance;
  }


  Future<void> insertInformationUser(User user) async{

   return _fireStore.collection("Users").doc(user.idUser).set({

      'fullName' : user.fullName ,
      'email': user.email ,
      'typeUser' : user.typeAccount.toString() ,
       'countRating'  : 1 ,
       'rating' :0.0  ,
       'countTrips' : 0 ,
       'stateAccount' : user.stateAccount.toString() ,

    });

  }



  Future<void> insertTrip(Trip trip) async{

    return _fireStore.collection("Trips").doc().set({

      'idCustomer' : trip.idCustomer ,
      'idDriver': trip.idDriver ,
      'dateStart' : '',
      'dateAcceptRequest' : FieldValue.serverTimestamp(),
      'state' :StateTrip.active.toString() ,
      'km' : 0.0,
      'totalPrice' :0.0,
       'locationCustomer' :{
        'lat' : trip.locationCustomer.latitude,
         'lng' :trip.locationCustomer.longitude
       },
      'locationDriver' :{
        'lat' : trip.locationDriver.latitude,
        'lng' :trip.locationDriver.longitude ,
         'rotateDriver' : trip.rotateDriver,
         'discount' :trip.discount
      }
    });

  }

  
  void sendNotification(String idSender , String idReceiver , String title , String body){


  String idNotification =   FirebaseDatabase
        .instance
        .reference()
        .child("Notification").push().key;
    
    FirebaseDatabase
        .instance
        .reference()
        .child("Notification/$idNotification")
        .set({

          "idSender" :  idSender ,
          "idReceiver" : idReceiver ,
          "title" : title ,
           "body": body ,
           "createdAt" : DateTime.now().toString()

         });
    
    
  }
  

  Future<bool> infoUserExit(String idUser){

    return _fireStore.collection("Users").doc(idUser).get().then((value) async{

     return  value.exists ;

    });

  }



  Future<int> checkPromoCode(String code){

    return  _fireStore
          .collection(FirebaseConstant().promoCode)
          .where("endDate" , isGreaterThanOrEqualTo:  DateTime.now())
          .where("code" ,isEqualTo: code)
          .limit(1)

          .get().then((value) {

            if(value.docs.length == 0 )
              return 0;

            return value.docs.first.get(FirebaseConstant().percentagePromoCode);
      });
  }



  Future<bool> checkDriverHasActiveTrip(String idDriver){

   return  _fireStore.collection(FirebaseConstant().driverRequests).doc(idDriver).get().then((value) async{

      if(value.exists)
        {
          if(value.get(FirebaseConstant().stateRequest) == "rejected")
            return false ;
          else
            return true ;
        }
      else
        return false ;

    });

  }

  Future<bool> checkLocationExit(String idUser){

    return _fireStore.collection(FirebaseConstant().locations).doc(idUser).get().then((value) async{
      return  value.exists ;
    });

  }


  Future<void> updateLocationUser(String idUser ,Map<String,dynamic> fields ) async{

   await _fireStore
        .collection(FirebaseConstant().locations)
        .doc(idUser).update(fields);
  }


  Future<void> insertLocationUser(String idUser ,Map<String,dynamic> fields ) async{

    await _fireStore
        .collection(FirebaseConstant().locations)
        .doc(idUser).set(fields);
  }


  Future<void> cancelTripFromDriver(String idUser) async{

    await _fireStore
        .collection(FirebaseConstant().driverRequests)
        .doc(idUser).update({

          FirebaseConstant().stateRequest : FirebaseConstant().rejected

        });
  }



  Future<User> loadUserInfo(String idUser , {TypeAccount typeAccount =TypeAccount.customer }){


   return _fireStore.collection("Users").doc(idUser).get().then((value) async {

      User user = User(
        idUser: value.id ,
        typeAccount: value.data()['typeUser'] == TypeAccount.customer.toString() ? TypeAccount.customer : TypeAccount.driver,
        fullName: value.data()['fullName'] ,
        email: value.data()['email'] ,
        countRating: value.data()['countRating'] == 0 ? 1 : value.data()['countRating'] ,
        rating: value.data()['rating']==0.0 ?5.0 :value.data()['rating'] ,

        carModel: typeAccount == TypeAccount.driver ? value.data()['carModel']  :"",
        carType: typeAccount == TypeAccount.driver ? value.data()['carType']  :"",

      ) ;

      print("RATING : ${user.rating}");

      return user;
    }) ;
  }

}