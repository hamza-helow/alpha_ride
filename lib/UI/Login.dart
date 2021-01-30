import 'package:alpha_ride/UI/Customers/Home.dart';
import 'package:flutter/material.dart';



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
            margin: EdgeInsets.only(top: 320),
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
                      child: TextFormField(
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'SFUIDisplay'
                        ),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'phone number',
                            prefixIcon: Icon(Icons.phone),
                            labelStyle: TextStyle(
                                fontSize: 15
                            )
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: TextFormField(
                      obscureText: true,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SFUIDisplay'
                      ),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          labelStyle: TextStyle(
                              fontSize: 15
                          )
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: MaterialButton(
                      onPressed: (){

                        Navigator.push(context, MaterialPageRoute(builder: (context) => Home(),));

                      },//since this is only a UI app
                      child: Text('SIGN IN',
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
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text('Forgot your password?',
                        style: TextStyle(
                            fontFamily: 'SFUIDisplay',
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),
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
                                  text: "Don't have an account?",
                                  style: TextStyle(
                                    fontFamily: 'SFUIDisplay',
                                    color: Colors.black,
                                    fontSize: 15,
                                  )
                              ),
                              TextSpan(
                                  text: "sign up",
                                  style: TextStyle(
                                    fontFamily: 'SFUIDisplay',
                                    color: Colors.deepOrange,
                                    fontSize: 15,
                                  )
                              )
                            ]
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
}



