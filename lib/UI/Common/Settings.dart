import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/UI/Common/Login.dart';
import 'package:alpha_ride/UI/Common/PhoneVerification.dart';
import 'package:alpha_ride/UI/Common/setupLanguage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {


  @override
  void initState() {


    loadCurrentLang();

    super.initState();
  }

  String lang;
  void loadCurrentLang()async{

    var prefs = await SharedPreferences.getInstance();

     this.setState(() {
       lang = prefs.getString("LANG")??"en";
     });

     print(lang);

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      appBar: AppBar(
        backgroundColor: DataProvider().baseColor,
      ),

      body: SingleChildScrollView(

        child: Column(

          children: [

            SizedBox(
              height: 20.0,
            ),

            ListTile(

              onTap: () {
                updateInfo(flag: 0 , controller: TextEditingController(text: auth.currentUser.displayName) , title: "${AppLocalizations.of(context).translate('fullName')}");
              },

              leading: Icon(Icons.person  ),
              title: Text("${AppLocalizations.of(context).translate('fullName')}" , ),
              subtitle: Text("${auth.currentUser.displayName}" ,style: TextStyle(fontSize: 17.0 ),),


            ),

            SizedBox(height: 10.0,),

            ListTile(
              onTap: () {
                updateInfo(flag: 1 , controller: TextEditingController(text: auth.currentUser.phoneNumber) , title: "${AppLocalizations.of(context).translate('numberPhone')}");
              },

              leading: Icon(Icons.phone ,),
              title: Text("${AppLocalizations.of(context).translate('numberPhone')}" ),
              subtitle: Text("${auth.currentUser.phoneNumber}" ,style: TextStyle(fontSize: 17.0 ),),

            ),

            SizedBox(height: 10.0,),

            ListTile(

              leading: Icon(Icons.email ),
              title: Text("${AppLocalizations.of(context).translate('email')}" ,),
              subtitle: Text("${auth.currentUser.email??""}" ,style: TextStyle(fontSize: 17.0 ),),
            ),

            SizedBox(height: 10.0,),

            // ListTile(
            //   onTap: () {
            //     updateInfo(flag: 3 , controller: TextEditingController() , title: "${AppLocalizations.of(context).translate('changePassword')}");
            //   },
            //
            //   leading: Icon(Icons.lock  ),
            //   title: Text("${AppLocalizations.of(context).translate('changePassword')}" ),
            //
            // ),
            //
            // SizedBox(height: 10.0,),


            Divider(
              color: Colors.grey,
            ),

            SizedBox(height: 10.0,),


            ListTile(

              onTap: () => dialogChangeLanguage(),
              leading: Icon(Icons.language  ),
              title: Text("${AppLocalizations.of(context).translate('language')}" ),
              subtitle: Text(
                "${lang == "en" ?
                "${AppLocalizations.of(context).translate('english')}" : "${AppLocalizations.of(context).translate('arabic')}"}" ,style: TextStyle(fontSize: 17.0 ),),

            ),

            SizedBox(height: 10.0,),


            // ListTile(
            //
            //   leading: Icon(Icons.star  ),
            //   title: Text("${AppLocalizations.of(context).translate('ratingApplication')}" ),
            //
            // ),
            //
            // SizedBox(height: 10.0,),

          ],

        ),
      ),

    );
  }

  dialogChangeLanguage()async{


    print(lang);

    dialog(Container(

      width: 300,
      height: 135,
      child: SetupLanguage(lang),

    ), context ,title: Text("${AppLocalizations.of(context).translate('changeLanguage')}") ,
        padding: EdgeInsets.all(5),
        
        widgets: [

      MaterialButton(onPressed: () => Navigator.pop(context), child: Text("${AppLocalizations.of(context).translate('done')}" , style: TextStyle(fontWeight: FontWeight.bold , color: DataProvider().baseColor),),)
    ]);

  }

dialog(Widget child,context,
    {List<Widget> widgets, barrierDismissible = true , Widget title , EdgeInsets padding =const EdgeInsets.all(16.0)  }) async {
  await showDialog<String>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => new AlertDialog(
            title: title,
            contentPadding: padding,
            content: child,
            actions: widgets),
      ));
}


  updateInfo({String title , TextEditingController controller , flag = 0 }) async {
    await showDialog<String>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => new AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
              ),
              actions: [

                MaterialButton(onPressed: () {

                  if(controller.text.isEmpty )
                    return;

                  FirebaseFirestore.instance
                      .collection("Users")
                      .doc(auth.currentUser.uid)
                      .update({
                        if(flag == 0)
                          'fullName' : controller.text
                       });

                  if(flag == 0)
                    auth.currentUser.updateProfile(displayName: controller.text  , photoURL: "");

                  if(flag == 1)
                    {

                      Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneVerification(controller.text , updateNumberPhone: true,),));
                    }

                  if(flag == 3)
                    auth.currentUser.updatePassword(controller.text);

                    if(flag != 1)
                      Navigator.pop(context);

                },
                child: Text("${AppLocalizations.of(context).translate('save')}"),
                )

              ]),
        ));
  }

}


