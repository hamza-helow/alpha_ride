import 'dart:io';

import 'package:alpha_ride/Enum/StateAccount.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/Models/User.dart' as m;
import 'package:alpha_ride/UI/Customers/Home.dart';
import 'package:alpha_ride/UI/Driver/homeDriver.dart';
import 'package:alpha_ride/UI/Driver/joinDriver.dart';
import 'package:alpha_ride/UI/Common/PhoneVerification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String phoneNumber = "";

  bool exitAccount = false   , onLogin = false ;

  m.User currentUser ;

  final passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value ) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value) , backgroundColor: Colors.red,));
  }

  @override
  void initState() {

    DataProvider().checkLocationPermission();

    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      key: _scaffoldKey,

      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('Assets/logo3.jpg' ),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            )),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(23),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Container(
                      color: Colors.white,
                      child: IntlPhoneField(
                        decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context).translate("phoneNumber")}',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        initialCountryCode: 'JO',
                        onChanged: (phone) {
                          print(phone.completeNumber);

                          phoneNumber = phone.completeNumber;

                          if(phoneNumber.length > 9){

                            checkAccountExit().then((user) {
                              this.setState(() {
                                if(user != null)
                                  exitAccount = true ;
                                else
                                  exitAccount = false ;
                              });

                              currentUser = user;
                            });

                          }
                        },
                      ),
                    ),
                  ),



                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: MaterialButton(
                      onPressed: () => phoneVerification(phoneNumber , typeAccount: TypeAccount.customer),
                      //since this is only a UI app
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${AppLocalizations.of(context).translate("signIn")}',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'SFUIDisplay',
                              fontWeight: FontWeight.bold,
                            ),
                          ) ,

                         if(onLogin)
                         Padding(padding:
                         EdgeInsets.all(10.0),
                           child:  CircularProgressIndicator(
                             valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                             backgroundColor: Colors.white,
                             strokeWidth: 2.0,
                           ),
                         )

                        ],
                      ),
                      color: DataProvider().baseColor,
                      elevation: 0,
                      minWidth: 400,
                      height: 50,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Center(
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  "${AppLocalizations.of(context).translate("loginWith")}",
                              style: TextStyle(
                                fontFamily: 'SFUIDisplay',
                                color: Colors.black,
                                fontSize: 15,
                              )),
                        ]),
                      ),
                    ),
                  ),
                  if(Platform.isAndroid)
                  otherMethodWidget() ,
                  joinDriverWidget(context)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  GestureDetector joinDriverWidget(BuildContext context) {
    return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JoinDriver(),
                        ));
                  },
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20.0, top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.drive_eta,
                            size: 40,
                            color: DataProvider().baseColor,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            "Join as captain",
                            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                );
  }

  Padding otherMethodWidget() {
    return Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      InkWell(

                        child:  Image.asset(
                          "Assets/facebook.png",
                          width: 50,
                          height: 50,
                        ),
                          onTap: () {
                            loginFacebook();
                          },
                      ),
                      SizedBox(
                        width: 22.0,
                      ),

                      InkWell(
                        onTap: () {

                          _handleSignIn();
                        },
                        child: Image.asset(
                          "Assets/gmail.png",
                          width: 50,
                          height: 50,
                        ),
                      ),

                     // if(Platform.isIOS)
                      SizedBox(
                        width: 22.0,
                      ),
                     // if(Platform.isIOS)
                      InkWell(
                        onTap: () {


                          withApple();

                        },
                        child: Image.asset(
                          "Assets/apple.png",
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                );
  }

  Future<m.User> checkAccountExit()async{

   return FirebaseFirestore.instance
        .collection("Users")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .where('usePassword' , isEqualTo: true)
        .get()
        .then((value) {

           if(value.docs.length > 0)
            {
              TypeAccount typeAccount = value.docs.first.get("typeUser") ==
                  TypeAccount.customer.toString()
                  ? TypeAccount.customer
                  : TypeAccount.driver;

              return m.User(
                typeAccount: typeAccount ,
                phoneNumber: value.docs.first.get("phoneNumber"),
                carType: typeAccount == TypeAccount.driver ? value.docs.first.get("carType") : "",
                carModel: typeAccount == TypeAccount.driver ? value.docs.first.get("carModel") : "",
                rating: double.parse('${value.docs.first.get("rating")}'),
                countRating: value.docs.first.get("countRating"),
                stateAccount: (){



                  if(value.docs.first.get("stateAccount") == StateAccount.active.toString())
                    return StateAccount.active ;
                  else if (value.docs.first.get("stateAccount") == StateAccount.rejected)
                    return StateAccount.rejected;
                  else
                    return StateAccount.pending;

                }() ,

                idUser: value.docs.first.id ,
                fullName: value.docs.first.get("fullName"),
                email: value.docs.first.get("email"),
              );

            }
           else
             return null;
    });

  }



  void withApple() async{

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    print(credential);

  }


  Future<void> _handleSignIn() async {
    this.setState(() {
      onLogin = true ;
    });

    final GoogleSignIn googleSignIn = GoogleSignIn();

    googleSignIn.signOut();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    loginOtherMethod(   credential: credential ,  fullName: googleSignInAccount.displayName,imageProfile: googleSignInAccount.photoUrl, email: googleSignInAccount.email , flag: 0);

  }

  Future<QuerySnapshot> getPhoneFromEmail(String email , int flag ) async{


      return FirebaseFirestore.instance
          .collection("Users")
          .where( flag == 0 ? "email" : "emailFacebook" ,isEqualTo: email)
          .get()
          .then((user) async {
        return user;
      });




  }


  void loginOtherMethod({String email  ,String fullName , String imageProfile ,AuthCredential  credential  ,  int  flag=0}){ // flag 0 : gmail , flag 1 :facebook
    getPhoneFromEmail(email , flag) .then((user) {

      this.setState(() {
        onLogin = false ;
      });

      if(user.size > 0 ){

        print("EXIT");

        String phoneNumber = user.docs.first.get("phoneNumber");

        print("$phoneNumber");

        if(user.docs.first.get("emailVerified"))
        {
          FirebaseAuth.instance.signInWithCredential(credential).then((value) {

            auth.currentUser.updateProfile(displayName: "${user.docs.first.get("fullName")}" , photoURL: "");
            SharedPreferencesHelper()
                .setFullName(user.docs.first.get("fullName"));
            SharedPreferencesHelper().setEmail(user.docs.first.get("email"));
            SharedPreferencesHelper().setSetTypeAccount(user.docs.first.get("typeUser") == TypeAccount.customer.toString() ? TypeAccount.customer : TypeAccount.driver);

            if(user.docs.first.get("typeUser") == TypeAccount.customer.toString())
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home(),), (route) => false);
            else
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeDriver(),), (route) => false);

          });

        }

        else
       {
         if(phoneNumber != null){
           phoneVerification(phoneNumber , credential: credential , fullName: fullName  , flag:flag );
         }
         else
           {
             phoneVerification(this.phoneNumber , credential: credential , fullName: fullName,flag:flag  );

             print(this.phoneNumber);
           }
       }
      }
      else
      {
         phoneVerification( this.phoneNumber , credential: credential , fullName: fullName  , email: email, flag:flag  );
      }

    });

  }

  Future<void> loginFacebook() async {
    try {
      AccessToken accessToken = await FacebookAuth.instance.login();
      print(accessToken.toJson());
      // get the user data
      final userData = await FacebookAuth.instance.getUserData();

      loginOtherMethod(email: userData['email'] , fullName: userData['name'] ,
          credential: FacebookAuthProvider.credential(accessToken.token) , imageProfile: userData['picture']['data']['url'] , flag: 1);

      print(userData['picture']['data']['url']);

      print(userData);
    } on FacebookAuthException catch (e) {
      switch (e.errorCode) {
        case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
          print("You have a previous login operation in progress");
          break;
        case FacebookAuthErrorCode.CANCELLED:
          print("login cancelled");
          break;
        case FacebookAuthErrorCode.FAILED:
          print("login failed");
          break;
      }
    }
  }


  void phoneVerification (String phoneNumber ,   {String imageProfile ,String email,String fullName ,TypeAccount typeAccount , AuthCredential credential , int flag}){

    if(phoneNumber == null || phoneNumber.isEmpty)
      {
        showInSnackBar("Pleas enter phone number");
        return;
      }

    this.setState(() {
      onLogin = false;
    });

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneVerification( phoneNumber , imageProfile: imageProfile,
            typeAccount: typeAccount , credential:credential ,email: email ,fullName: fullName,flag: flag,),
        ));

  }

}

