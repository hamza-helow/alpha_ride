

import 'package:alpha_ride/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      'typeUser' : user.typeUser ,
       'countRating'  : 1 ,
       'rating' :0.0  ,
       'countTrips' : 0


    });

  }

  Future<bool> infoUserExit(String idUser){

    return _fireStore.collection("Users").doc(idUser).get().then((value) async{

     return  value.exists ;

    });

  }


  Future<User> loadUserInfo(String idUser){


   return _fireStore.collection("Users").doc(idUser).get().then((value) async {

      User user = User(
        idUser: "" ,
        typeUser: "",
        fullName: value.data()['fullName'] ,
        email: value.data()['email']
      ) ;

      return user;
    }) ;
  }

}