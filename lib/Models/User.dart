import 'package:alpha_ride/Enum/StateAccount.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';

class User {

  String fullName , email , idUser ,  carType , carModel ;

  TypeAccount typeAccount ;

  StateAccount stateAccount ;

  double rating ;

  int countRating;

  String phoneNumber;

  bool emailVerified   ;


  User({
    this.fullName,
    this.email,
    this.idUser,
    this.typeAccount ,
    this.stateAccount ,
    this.countRating,
    this.rating ,
    this.carModel ,
    this.carType,
    this.phoneNumber ,
    this.emailVerified = false
  });
}