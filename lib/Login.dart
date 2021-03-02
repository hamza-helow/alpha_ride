import 'package:alpha_ride/Enum/StateAccount.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/Models/User.dart' as m;
import 'package:alpha_ride/UI/Customers/Home.dart';
import 'package:alpha_ride/UI/Driver/homeDriver.dart';
import 'package:alpha_ride/UI/Driver/joinDriver.dart';
import 'package:alpha_ride/UI/widgets/PhoneVerification.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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



  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('Assets/logo.jpg'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            )),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 200),
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

                  if(exitAccount)
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 20),
                    child: Container(
                      color: Colors.white,
                      child: TextField(
                        obscureText : true ,
                        controller: passwordController,
                        decoration: InputDecoration(
                           labelText: "Enter password",

                          suffixIcon: Icon(Icons.lock),

                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          )
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: MaterialButton(
                      onPressed: () {
                        login();
                      },
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
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon(FontAwesomeIcons.facebook ,  size: 50, color: DataProvider().baseColor,),

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
                        )
                      ],
                    ),
                  ) ,

                  GestureDetector(
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
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<m.User> checkAccountExit()async{

   return FirebaseFirestore.instance
        .collection("Users")
        .where("phoneNumber", isEqualTo: phoneNumber)
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

  void login() {

    this.setState(() {
      onLogin = true ;
    });

    if(currentUser != null)
    auth
        .signInWithEmailAndPassword(
        email: currentUser.email, password: passwordController.text)
        .then((result) {

          this.setState(() {
            onLogin = false ;
          });

      if (result.user != null) {
        if (currentUser.typeAccount == TypeAccount.customer)
          
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home(),), (route) => false);
        else
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeDriver(),), (route) => false);


        SharedPreferencesHelper()
            .setFullName(currentUser.fullName);
        SharedPreferencesHelper().setEmail(currentUser.email);
        SharedPreferencesHelper().setSetTypeAccount(currentUser.typeAccount);
      }
    });
    else
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneVerification(phoneNumber),
          ));


  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<void> _handleSignIn() async {

    this.setState(() {
      onLogin = true ;
    });

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    // //googleSignInAccount.email;
    // checkAccountExit();
    //
    //
    // final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
    // final User user = authResult.user;

  //  getPhoneFromEmail(googleSignInAccount.email , googleSignInAccount.displayName ,credential);

    loginGoogle(googleSignInAccount.email , googleSignInAccount.displayName ,credential);

    // try {
    //   await _googleSignIn.signIn().then((value) {
    //     print(value.photoUrl);
    //   });
    // } catch (error) {
    //   print(error);
    // }
  }

  Future<QuerySnapshot> getPhoneFromEmail(String email ) async{

        return FirebaseFirestore.instance
        .collection("Users")
        .where("email" ,isEqualTo: email)
        .get()
        .then((user) async {
         return user;
       });


  }


  void loginGoogle(String email  ,String fullName ,AuthCredential  credential){
    getPhoneFromEmail(email).then((user) {

      this.setState(() {
        onLogin = false ;
      });

      if(user.size > 0 ){

        print("EXIT");

        String phoneNumber = user.docs.first.get("phoneNumber");

        if(user.docs.first.get("emailVerified"))
        {
          FirebaseAuth.instance.signInWithCredential(credential).then((value) {
           
            if(user.docs.first.get("typeUser") == TypeAccount.customer.toString())
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home(),), (route) => false);
            else
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeDriver(),), (route) => false);

          });
        }

        else
        if(phoneNumber != null){
          phoneVerification(phoneNumber , credential: credential , fullName: fullName );
        }
        else
          phoneVerification(this.phoneNumber , credential: credential , fullName: fullName );
      }
      else
      {
        phoneVerification( this.phoneNumber , credential: credential , fullName: fullName  , email: email );
      }

    });

  }


  Future<void> loginFacebook() async {
    try {
      // by default the login method has the next permissions ['email','public_profile']
      AccessToken accessToken = await FacebookAuth.instance.login();
      print(accessToken.toJson());
      // get the user data
      final userData = await FacebookAuth.instance.getUserData();


      print(accessToken.token);

      FirebaseAuth.instance.signInWithCredential(FacebookAuthProvider.credential(accessToken.token) );

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


  void phoneVerification (String phoneNumber ,   { String email,String fullName ,TypeAccount typeAccount , AuthCredential credential}){

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneVerification(phoneNumber , typeAccount: typeAccount , credential:credential ,email: email ,fullName: fullName,),
        ));

  }

}

