
import 'package:alpha_ride/Enum/StateAccount.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';

class User {

  String fullName , email , idUser  ;

  TypeAccount typeAccount ;

  StateAccount stateAccount ;


  User({this.fullName, this.email, this.idUser, this.typeAccount ,this.stateAccount});
}