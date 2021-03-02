import 'package:alpha_ride/Helper/AppLanguage.dart';
import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Login.dart';
import 'package:alpha_ride/UI/widgets/CustomWidgets.dart';
import 'package:alpha_ride/UI/widgets/setupLanguage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {


  @override
  void initState() {






    super.initState();
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

              leading: Icon(Icons.person  ),
              title: Text("Full Name" , ),
              subtitle: Text("${auth.currentUser.displayName}" ,style: TextStyle(fontSize: 17.0 ),),


            ),

            SizedBox(height: 10.0,),

            ListTile(

              leading: Icon(Icons.phone  ,),
              title: Text("Phone number" ),
              subtitle: Text("${auth.currentUser.phoneNumber}" ,style: TextStyle(fontSize: 17.0 ),),

            ),

            SizedBox(height: 10.0,),

            ListTile(

              leading: Icon(Icons.email ),
              title: Text("Email" ,),
              subtitle: Text("${auth.currentUser.email}" ,style: TextStyle(fontSize: 17.0 ),),

            ),

            SizedBox(height: 10.0,),

            ListTile(

              leading: Icon(Icons.lock  ),
              title: Text("Change password" ),

            ),

            SizedBox(height: 10.0,),


            ListTile(

              leading: Icon(Icons.person_outline_rounded  ),
              title: Text("Gender" ),
              subtitle: Text("mail" ,style: TextStyle(fontSize: 17.0 ),),

            ),

            SizedBox(height: 10.0,),


            ListTile(

              leading: Icon(Icons.calendar_today  ),
              title: Text("Birth day" ),
              subtitle: Text("2 october 1998"),

            ),

            SizedBox(height: 10.0,),

            Divider(
              color: Colors.grey,
            ),

            SizedBox(height: 10.0,),


            ListTile(

              onTap: () => dialogChangeLanguage(),
              leading: Icon(Icons.language  ),
              title: Text("language" ),
              subtitle: Text(
                "${AppLocalizations.of(context).locale.toString() == "en" ?
                "${AppLocalizations.of(context).translate('english')}" : "${AppLocalizations.of(context).translate('arabic')}"}" ,style: TextStyle(fontSize: 17.0 ),),

            ),

            SizedBox(height: 10.0,),


            ListTile(

              leading: Icon(Icons.star  ),
              title: Text("Rating application" ),

            ),

            SizedBox(height: 10.0,),

          ],

        ),
      ),

    );
  }

  dialogChangeLanguage(){

    dialog(Container(

      width: 300,
      height: 135,
      child: SetupLanguage(AppLocalizations.of(context).locale.toString()),

    ), context ,title: Text("Change Language") ,
        padding: EdgeInsets.all(5),
        
        widgets: [

      MaterialButton(onPressed: () => Navigator.pop(context), child: Text("Done" , style: TextStyle(fontWeight: FontWeight.bold , color: DataProvider().baseColor),),)
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

}


