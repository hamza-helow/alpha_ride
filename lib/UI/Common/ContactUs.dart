import 'dart:io';

import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatelessWidget {

  String urlWhatsApp() {
    if (Platform.isAndroid) {

      return "https://wa.me/+9620798024797/"; //
    } else {
      // add the [https]
      return "https://api.whatsapp.com/send?phone=+9620798024797"; // new line
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DataProvider().baseColor,
      ),

      body: Column(

        children: [

          ListTile(
            leading: Icon(FontAwesomeIcons.whatsapp),
            title: Text("Whatsapp"),
            subtitle: Text("+9620798024797"),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () {
              launch(urlWhatsApp());
            },
          ),


          ListTile(
            onTap: () {

              launch("tel://+9620798024797");

            },
            leading: Icon(FontAwesomeIcons.phone),
            title: Text("Phone number"),
            subtitle: Text("+9620798024797"),
            trailing: Icon(Icons.arrow_forward_ios_sharp),

          ),
        ],
      ),
    );
  }
}
