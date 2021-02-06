import 'package:flutter/material.dart';
class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
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
              subtitle: Text("hamza helow" ,style: TextStyle(fontSize: 17.0 ),),


            ),

            SizedBox(height: 10.0,),

            ListTile(

              leading: Icon(Icons.phone  ,),
              title: Text("Phone number" ),
              subtitle: Text("+962 788051422" ,style: TextStyle(fontSize: 17.0 ),),

            ),

            SizedBox(height: 10.0,),

            ListTile(

              leading: Icon(Icons.email ),
              title: Text("Email" ,),
              subtitle: Text("hamzahelow3@gmail.com" ,style: TextStyle(fontSize: 17.0 ),),

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

              leading: Icon(Icons.language  ),
              title: Text("language" ),
              subtitle: Text("English" ,style: TextStyle(fontSize: 17.0 ),),

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
}


