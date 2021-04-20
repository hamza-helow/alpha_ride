import 'package:alpha_ride/Enum/StateAccount.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/UI/Customers/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:alpha_ride/Models/User.dart' as model;

class CompleteCreateAccount extends StatefulWidget {

  final UserCredential credential ;

  CompleteCreateAccount(this.credential);

  @override
  _CompleteCreateAccountState createState() => _CompleteCreateAccountState();
}

class _CompleteCreateAccountState extends State<CompleteCreateAccount> {

  final fullName = TextEditingController();
  final email = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value ) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value) , backgroundColor: Colors.red,));
  }


  @override
  void initState() {

    SharedPreferencesHelper()
        .setSetTypeAccount(TypeAccount.none);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(child: Scaffold(
      key: _scaffoldKey,

      resizeToAvoidBottomInset: false,

      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottom ,top: 10.0 , right: 15.0  , left: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            SizedBox(height: 30.0,),

            buildThemeTextField(
                fullName,
                helperText: "${AppLocalizations.of(context).translate('fullName')}",
                hintText: "${AppLocalizations.of(context).translate('enterName')}",
                icon: Icon(Icons.person),
                labelText: "${AppLocalizations.of(context).translate('fullName')}"

            ),

            SizedBox(height: 20.0,),


            buildThemeTextField(
                email,
                helperText: "${AppLocalizations.of(context).translate('email')}",
                hintText: "${AppLocalizations.of(context).translate('enterEmail')}",
                icon: Icon(Icons.email),
                labelText: "${AppLocalizations.of(context).translate('email')}"

            ),

            SizedBox(height: 20.0,),


            Padding(
              padding: EdgeInsets.only(top: 20),
              child: MaterialButton(

                onPressed:  () {

                  addUserInfo();

                },//since this is only a UI app
                child: Text('${AppLocalizations.of(context).translate('confirm')}',
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
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),


          ],

        ),
      ),
    ));
  }

  Theme buildThemeTextField(TextEditingController controller ,  {String hintText ,String  helperText , String labelText , Widget icon  }) {
    return new Theme(
            data: new ThemeData(
            primaryColor: Colors.redAccent,
              primaryColorDark: Colors.red,
            ),
            child: new TextField(
              controller: controller,
              autofocus: true,
              decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                  hintText: hintText,
                  helperText: helperText,
                  labelText: labelText,
                  prefixIcon:icon,
                  prefixText: ' ',
                  suffixStyle:  TextStyle(color: DataProvider().baseColor)),
            ),
          );
  }

  void addUserInfo() {
    if(fullName.text.isEmpty){

      showInSnackBar("${AppLocalizations.of(context).translate('pleaseEnterName')}");
      return;
    }


    SharedPreferencesHelper().setEmail(email.text);
    SharedPreferencesHelper().setFullName(fullName.text);
    SharedPreferencesHelper().setSetTypeAccount(TypeAccount.customer);

    FirebaseHelper().insertInformationUser(model.User(
      email: email.text ,
      fullName: fullName.text,
      typeAccount: TypeAccount.customer,
      idUser: widget.credential.user.uid ,
      stateAccount: StateAccount.active,
      phoneNumber: widget.credential.user.phoneNumber

    )).then((value) => {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home(),))
    });

  }
}
