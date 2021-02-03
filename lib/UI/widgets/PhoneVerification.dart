
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Timer.dart';
import 'autoFill_sms.dart';


class PhoneVerification extends StatefulWidget {

  String phoneNumber ;


  PhoneVerification(this.phoneNumber);

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {

  String verificationId , smsCode ="" ;


  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
     sendCode();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(



      body: SafeArea(


        child: Stack(

          children: [

            Padding(
              padding: EdgeInsets.only(left: 25 ,  top: 25),
              child: InkWell(

                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios_rounded , color: Colors.deepOrange,),
              ),
            ),


            Padding(
              padding: EdgeInsets.all(40.0),


              child: Column(


                children: [



                  SizedBox(
                    height: 35.0,
                  ),

                  Text("Enter code Verification" ,
                    style: TextStyle(

                        fontWeight: FontWeight.bold ,
                        fontSize: 20.0
                    ),),

                  SizedBox(
                    height: 20.0,
                  ),


                  Padding(padding: EdgeInsets.only(left: 40.0 ,right: 40.0) ,
                    child:  buildPinFieldAutoFill(),
                  ) ,

                  SizedBox(
                    height: 20.0,
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: MaterialButton(

                      onPressed:  () {

                        verification();
                      },//since this is only a UI app
                      child: Text('VERIFICATION',
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

                  SizedBox(
                    height: 15.0,
                  ),


                  Timer(),


                ],

              ),

            )
          ],
        ),

      ),

    );
  }

  PinFieldAutoFill buildPinFieldAutoFill() {
    return  PinFieldAutoFill(
                autofocus: true,
                onCodeChanged: (txt)  {

                  print(txt);
                },
                codeLength:  6 , //code length, default 6
              );
  }


  var firebaseAuth =  FirebaseAuth.instance;


  void verification (){


    AuthCredential phoneAuthCredential =
    PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode);

    // Sign the user in (or link) with the credential
    firebaseAuth.signInWithCredential(phoneAuthCredential);


  }

  void sendCode() async {

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: '${widget.phoneNumber}',
      verificationCompleted: (credential) async {
        // ANDROID ONLY!

        PhoneVerificationCompleted c ;
        print(credential);
        // Sign the user in (or link) with the auto-generated credential
        //await firebaseAuth.signInWithCredential(credential);

      }, timeout: Duration(seconds: 60),

      codeSent: (verificationId, [forceResendingToken])  {


      }, codeAutoRetrievalTimeout: (String verificationId) {



    }, verificationFailed: (AuthException error) {

    },

    );


  }


  void updateSmsCode(String newSmsCode){

    this.setState(() {
      smsCode = newSmsCode;
    });

  }

}
