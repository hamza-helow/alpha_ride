import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/UI/Customers/Home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';



class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Stack(
        children: <Widget>[
          Container(

            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('Assets/logo.jpg' ),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                )
            ),
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
                          labelText: '${AppLocalizations.of(context).translate("phoneNumber")}',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        initialCountryCode: 'JO',
                        onChanged: (phone) {
                          print(phone.completeNumber);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: MaterialButton(
                      onPressed: (){

                        Navigator.push(context, MaterialPageRoute(builder: (context) => Home(),));

                      },//since this is only a UI app
                      child: Text('${AppLocalizations.of(context).translate("signIn")}',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'SFUIDisplay',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      color: Colors.deepOrange,
                      elevation: 0,
                      minWidth: 400,
                      height: 50,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "${AppLocalizations.of(context).translate("loginWith")}",
                                  style: TextStyle(
                                    fontFamily: 'SFUIDisplay',
                                    color: Colors.black,
                                    fontSize: 15,
                                  )
                              ),

                            ]
                        ),
                      ),
                    ),
                  ) ,

                  Padding(
                    padding: EdgeInsets.only(top: 30),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                       // Icon(FontAwesomeIcons.facebook ,  size: 50, color: Colors.deepOrange,),

                        Image.asset("Assets/facebook.png" , width: 50, height: 50,),

                        SizedBox(width: 22.0,),
                        
                        Image.asset("Assets/gmail.png" , width: 50, height: 50,)



                      ],

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
}



