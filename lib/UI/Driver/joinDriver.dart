import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


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

  @override
  Widget build(BuildContext context) {
    return SafeArea(


      child: Scaffold(

        body: Padding(
          padding: EdgeInsets.all(20.0),
          
          child: SingleChildScrollView(

            child: Column(


              children: [

                SizedBox(height: 20.0,),

                buildThemeTextField(
                  fullName,
                  hintText: "full name",
                  icon: Icon(Icons.person),

                ),

                SizedBox(height: 15.0,),


                buildThemeTextField(
                  typeCar,
                  hintText: "type car",
                  icon: Icon(Icons.local_taxi_sharp),

                ),

                SizedBox(height: 15.0,),


                buildThemeTextField(
                  modelCar,
                  hintText: "car model",
                  icon: Icon(Icons.local_taxi_sharp),

                ),

                SizedBox(height: 15.0,),


                buildThemeTextField(
                  colorCar,
                  hintText: "car color",
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
                  title: Text("Your photo"),
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

                  title: Text("driving license"),
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
                  title: Text("driver's license"),
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
                  title: Text("A front view of the car"),
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

                  title: Text("A photo from the back of the car"),
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
                  title: Text("A picture from inside the car"),
                ),


                SizedBox(height: 20.0,),


                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: MaterialButton(

                    onPressed:  () {

                      sendInfoDriver();
                    },//since this is only a UI app
                    child: Text('CONFIRM',
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
            suffixStyle: const TextStyle(color: Colors.deepOrange)),
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

    String idRequest  =FirebaseFirestore.instance.collection("a").doc().id;

    uploadImage(yourPhoto , idRequest , "DriverImage").then((yourPhoto) {

      uploadImage(drivingLicense , idRequest , "drivingLicense").then((drivingLicense) {

        uploadImage(driverLicense , idRequest , "driverLicense").then((driverLicense) {

          uploadImage(frontCar , idRequest , "frontCar").then((frontCar) {

            uploadImage(endCar , idRequest , "endCar").then((endCar) {

              uploadImage(insideCar , idRequest , "insideCar").then((insideCar) {


                FirebaseFirestore.instance
                    .collection("DriverRequestsAccount")
                    .doc(idRequest)
                    .set({

                  'yourPhoto' : yourPhoto ,
                  'drivingLicense' : drivingLicense ,
                  'driverLicense' : driverLicense ,
                  'frontCar' : frontCar ,
                  'endCar' : endCar ,
                  'insideCar' : insideCar ,
                  'fullName' :fullName.text ,
                  'typeCar' : typeCar.text ,
                  'modelCar' :modelCar.text ,
                  'colorCar' :colorCar.text

                    });


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
