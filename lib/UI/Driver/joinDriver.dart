import 'dart:io';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Models/DriverRequest.dart';
import 'file:///C:/Users/hamzi/AndroidStudioProjects/alpha_ride/lib/UI/Common/PhoneVerification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';


class JoinDriver extends StatefulWidget {
  @override
  _JoinDriverState createState() => _JoinDriverState();
}

class _JoinDriverState extends State<JoinDriver> {

  final picker = ImagePicker();

  File yourPhoto ,drivingLicense , driverLicense , frontCar , endCar , insideCar;

  final fullName = TextEditingController();
  final email = TextEditingController();
  final modelCar = TextEditingController();
  final typeCar = TextEditingController();
  final colorCar = TextEditingController();
  final numberCar = TextEditingController();

  String phoneNumber ="";

  bool inProgress = false ;

  @override
  Widget build(BuildContext context) {
    return SafeArea(


      child: Scaffold(

        body: Padding(
          padding: EdgeInsets.all(20.0),
          
          child: SingleChildScrollView(

            child: Column(


              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Container(
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
                        phoneNumber =phone.completeNumber ;

                      },
                    ),
                  ),
                ),
                SizedBox(height: 15.0,),

                buildThemeTextField(
                  fullName,
                  hintText: "${AppLocalizations.of(context).translate('fullName')}",
                  icon: Icon(Icons.person),

                ),

                SizedBox(height: 15.0,),


                buildThemeTextField(
                  typeCar,
                  hintText: "${AppLocalizations.of(context).translate('typeCar')}",
                  icon: Icon(Icons.local_taxi_sharp),

                ),

                SizedBox(height: 15.0,),


                buildThemeTextField(
                  modelCar,
                  hintText: "${AppLocalizations.of(context).translate('carModel')}",
                  icon: Icon(Icons.local_taxi_sharp),

                ),

                SizedBox(height: 15.0,),

                buildThemeTextField(
                  numberCar,
                  hintText: "${AppLocalizations.of(context).translate('numberCar')}",
                  icon: Icon(Icons.local_taxi_sharp),

                ),

                SizedBox(height: 15.0,),


                buildThemeTextField(
                  colorCar,
                  hintText: "${AppLocalizations.of(context).translate('carColor')}",
                  icon: Icon(Icons.color_lens_outlined),
                ),

                SizedBox(height: 15.0,),

                ListTile(
                  onTap: () {

                    getImage().then((value) {

                      this.setState(() {

                        yourPhoto = value;

                      });

                    });

                  },
                  leading: yourPhoto != null ? Icon(Icons.done)  : Icon(Icons.add),
                  title: Text("${AppLocalizations.of(context).translate('yourPhoto')}"),
                ),

                ListTile(

                  onTap: () {

                    getImage().then((value) {

                      this.setState(() {

                        drivingLicense = value;

                      });



                    });

                  },

                  leading: drivingLicense != null ? Icon(Icons.done)  : Icon(Icons.add),

                  title: Text("${AppLocalizations.of(context).translate('drivingLicense')}"),
                ),

                ListTile(
                  onTap: () {

                    getImage().then((value) {

                      this.setState(() {

                        driverLicense = value;

                      });
                    });

                  },
                  leading: driverLicense != null ? Icon(Icons.done)  : Icon(Icons.add),
                  title: Text("${AppLocalizations.of(context).translate('driverLicense')}"),
                ),

                ListTile(
                  onTap: () {

                    getImage().then((value) {

                      this.setState(() {

                        frontCar = value;

                      });
                    });

                  },
                  leading: frontCar != null ? Icon(Icons.done)  : Icon(Icons.add),
                  title: Text("${AppLocalizations.of(context).translate('frontViewCar')}"),
                ),

                ListTile(
                  onTap: () {

                    getImage().then((value) {

                      this.setState(() {

                        endCar = value;

                      });
                    });

                  },
                  leading: endCar != null ? Icon(Icons.done)  : Icon(Icons.add),

                  title: Text("${AppLocalizations.of(context).translate('photoBackCar')}"),
                ),

                ListTile(
                  onTap: () {

                    getImage().then((value) {

                      this.setState(() {

                        insideCar = value;

                      });
                    });

                  },
                  leading: insideCar != null ? Icon(Icons.done)  : Icon(Icons.add),
                  title: Text("${AppLocalizations.of(context).translate('photoInsideCar')}"),
                ),



                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: MaterialButton(

                    onPressed:  () {

                      sendInfoDriver();
                    },//since this is only a UI app
                    child:inProgress ? Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 10.0,

                      children: [


                        Text("Loading.. ") ,
                        CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        )

                      ],

                    )    :  Text('${AppLocalizations.of(context).translate('send')}',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'SFUIDisplay',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: DataProvider().baseColor,
                    elevation: 0,
                    minWidth: 400,
                    height: 60,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                  ),
                ),


              ],

            ),
          ),
          
        ),
      ),

    );
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

  Future<File> getImage() async {

    List<ImageSource> l ;

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null ;
    }

  }


  void sendInfoDriver(){

    if(yourPhoto == null
        ||drivingLicense == null ||
        driverLicense == null   ||
        frontCar == null  || endCar == null || insideCar==null || phoneNumber.isEmpty  )
      return;

    this.setState(() {
      inProgress = true ;
    });



    String idRequest  =FirebaseFirestore.instance.collection("a").doc().id;

    uploadImage(yourPhoto , idRequest , "DriverImage").then((yourPhoto) {

      uploadImage(drivingLicense , idRequest , "drivingLicense").then((drivingLicense) {

        uploadImage(driverLicense , idRequest , "driverLicense").then((driverLicense) {

          uploadImage(frontCar , idRequest , "frontCar").then((frontCar) {

            uploadImage(endCar , idRequest , "endCar").then((endCar) {

              uploadImage(insideCar , idRequest , "insideCar").then((insideCar) {


                DataProvider().driverRequest = DriverRequest(

                  fullName: fullName.text ,
                  email: email.text ,
                  colorCar: colorCar.text ,
                  driverLicense: driverLicense ,
                  drivingLicense: drivingLicense ,
                  endCar: endCar ,
                  frontCar: frontCar ,
                  insideCar: insideCar ,
                  modelCar: modelCar.text ,
                  typeCar: typeCar.text ,
                  yourPhoto: yourPhoto ,
                  numberCar: numberCar.text
                );

                this.setState(() {
                  inProgress = false ;
                });


                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    PhoneVerification(phoneNumber , typeAccount: TypeAccount.driver ,isRequestDriver: true,),));


              });

            });

          });

        });


      });

    });







  }

  Future<String> uploadImage(var imageFile , String idRequest , String fileName ) async {

    Reference ref = FirebaseStorage.instance.ref("imageRequestDriver").child(idRequest).child(fileName);

    UploadTask uploadTask = ref.putFile(imageFile);

   return  uploadTask.then((task) async {

   return ref.getDownloadURL().then((value) async{

      return value;

    });

    });

  }

}
