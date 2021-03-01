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

  bool exitAccount = false ;

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
                      child: Text(
                        '${AppLocalizations.of(context).translate("signIn")}',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'SFUIDisplay',
                          fontWeight: FontWeight.bold,
                        ),
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

                        Image.asset(
                          "Assets/facebook.png",
                          width: 50,
                          height: 50,
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
                  )
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: GestureDetector(
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

    if(currentUser != null)
    auth
        .signInWithEmailAndPassword(
        email: currentUser.email, password: passwordController.text)
        .then((result) {
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
    try {
      await _googleSignIn.signIn().then((value) {
        print(value.email);
      });
    } catch (error) {
      print(error);
    }
  }
}
