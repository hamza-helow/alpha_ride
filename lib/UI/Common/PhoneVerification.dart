import 'package:alpha_ride/Enum/StateAccount.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/UI/Common/Login.dart';
import 'package:alpha_ride/UI/Customers/CompleteCreateAccount.dart';
import 'package:alpha_ride/UI/Customers/Home.dart';
import 'package:alpha_ride/UI/Driver/homeDriver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:alpha_ride/Models/User.dart' as model;
import 'Timer.dart';
import 'autoFill_sms.dart';

class PhoneVerification extends StatefulWidget {
  final bool updateNumberPhone;

  final String phoneNumber;

  final TypeAccount typeAccount;

  final AuthCredential credential;

  final String fullName, email, imageProfile;

  final int flag;

  final bool isRequestDriver;

  PhoneVerification(this.phoneNumber,
      {this.isRequestDriver = false,
      this.updateNumberPhone = false,
      this.imageProfile,
      this.email,
      this.typeAccount = TypeAccount.customer,
      this.credential,
      this.fullName,
      this.flag});

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  String actualCode = "", smsCode = "";

  String appSignature;
  String otpCode;

  final codeController = TextEditingController();


  void listenForCode() async {
    await SmsAutoFill().listenForCode;
  }

  @override
  void initState() {
    super.initState();
    sendCode();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25, top: 25),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: DataProvider().baseColor,
                ),
              ),
            ),
            verificationWidget(context)
          ],
        ),
      ),
    );
  }

  Padding verificationWidget(BuildContext context) {
    return Padding(
            padding: EdgeInsets.all(40.0),
            child: Column(
              children: [
                if (inProgress)
                  SizedBox(
                    height: 35.0,
                  ),
                SizedBox(
                  height: 35.0,
                ),
                Text(
                  "${AppLocalizations.of(context).translate('enterCodeVerification')}",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: buildPinFieldAutoFill(),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: MaterialButton(
                    onPressed: () {
                      verification();
                    },
                    //since this is only a UI app
                    child: Text(
                      '${AppLocalizations.of(context).translate('verification')}',
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
                SizedBox(
                  height: 15.0,
                ),
                Timer(
                  resendCode: () => sendCode(),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          );
  }


  PinFieldAutoFill buildPinFieldAutoFill() {
    return PinFieldAutoFill(
      controller: codeController,
      autofocus: true,
      onCodeChanged: (txt) {
        smsCode = txt;
        print(txt);
      },
      codeLength: 6, //code length, default 6
    );
  }

  var firebaseAuth = FirebaseAuth.instance;

  bool inProgress = false;

  void verification() {
    print('$smsCode , ${widget.phoneNumber}');

    AuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: actualCode, smsCode: smsCode);

    if (widget.updateNumberPhone) {
      FirebaseAuth.instance.currentUser
          .updatePhoneNumber(phoneAuthCredential)
          .then((value) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(auth.currentUser.uid)
            .update({'phoneNumber': widget.phoneNumber});

        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((err) {
        showInSnackBar("The code is incorrect ");
      });
      return;
    }

    if (phoneAuthCredential == null) return;

    signInWithCredential(phoneAuthCredential);
  }

  void signInWithCredential(phoneAuthCredential) {
    firebaseAuth
        .signInWithCredential(phoneAuthCredential)
        .then((c) => {
              if (widget.credential == null)
                FirebaseHelper().infoUserExit(c.user.uid).then((value) => {
                      if (value && !widget.isRequestDriver)
                        {
                          FirebaseHelper()
                              .loadUserInfo(c.user.uid)
                              .then((user) => {
                                    auth.currentUser.updateProfile(
                                        displayName: "${user.fullName}",
                                        photoURL: ''),
                                    SharedPreferencesHelper()
                                        .setFullName(user.fullName),
                                    SharedPreferencesHelper()
                                        .setEmail(user.email),
                                    SharedPreferencesHelper()
                                        .setSetTypeAccount(user.typeAccount),

                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>  user.typeAccount ==
                                        TypeAccount.customer
                                        ? Home()
                                        : HomeDriver() ,), (route) => false),


                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           user.typeAccount ==
                                    //                   TypeAccount.customer
                                    //               ? Home()
                                    //               : HomeDriver(),
                                    //     )),
                                  })
                        }
                      else
                        {
                          if (widget.typeAccount == TypeAccount.customer)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CompleteCreateAccount(c)))
                          else
                            requestNewAccountDriver(c.user.uid)
                        },
                    })
              else
                {
                  c.user.linkWithCredential(widget.credential).then((value) {
                    auth.currentUser.updateProfile(
                        displayName: "${widget.fullName}",
                        photoURL: widget.imageProfile);
                    FirebaseHelper()
                        .insertInformationUser(model.User(
                            fullName: widget.fullName,
                            email: widget.flag == 0 ? widget.email : null,
                            idUser: c.user.uid,
                            stateAccount: StateAccount.active,
                            phoneNumber: widget.phoneNumber,
                            imageProfile: widget.imageProfile,
                            typeAccount: TypeAccount.customer,
                            emailVerified: true,
                            emailFacebook:
                                widget.flag == 1 ? widget.email : null))
                        .then((value) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => Home(),
                          ),
                          (route) => false);
                    });
                  }),
                },
              this.setState(() {
                inProgress = false;
              }),
            })
        .catchError((err) {
      print(err);

      showInSnackBar("The code is incorrect ");
    });
  }

  void onSmsReceived(String message) {
    print(message);
  }

  void sendCode() async {
    print(widget.phoneNumber);

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: '${widget.phoneNumber}',
      verificationCompleted: (credential) async {
        print("credential : $credential");

        codeController.text = credential.smsCode;

        signInWithCredential(credential);
      },
      timeout: Duration(seconds: 10),
      codeSent: (verificationId, [forceResendingToken]) {
        actualCode = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      verificationFailed: (error) {
        print(error);
      },
    );
  }

  void updateSmsCode(String newSmsCode) {
    this.setState(() {
      smsCode = newSmsCode;
    });
  }

  requestNewAccountDriver(String idUser) {
    auth.signOut();

    FirebaseFirestore.instance
        .collection("DriverRequestsAccount")
        .doc(idUser)
        .set({
      'yourPhoto': DataProvider().driverRequest.yourPhoto,
      'drivingLicense': DataProvider().driverRequest.drivingLicense,
      'driverLicense': DataProvider().driverRequest.driverLicense,
      'email': DataProvider().driverRequest.email,
      'frontCar': DataProvider().driverRequest.frontCar,
      'endCar': DataProvider().driverRequest.endCar,
      'insideCar': DataProvider().driverRequest.insideCar,
      'fullName': DataProvider().driverRequest.fullName,
      'typeCar': DataProvider().driverRequest.typeCar,
      'modelCar': DataProvider().driverRequest.modelCar,
      'colorCar': DataProvider().driverRequest.colorCar,
      'phoneNumber': '${widget.phoneNumber}',
      'idUser': idUser,
      'numberCar': DataProvider().driverRequest.numberCar
    }).then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
          (route) => false);
    });
  }
}
