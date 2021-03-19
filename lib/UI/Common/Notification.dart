import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

class Notification extends StatefulWidget {

  final TypeAccount typeAccount ;


  Notification({this.typeAccount = TypeAccount.driver});

  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: DataProvider().baseColor,),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("Notifications").where("typeUser" ,  isEqualTo: widget.typeAccount.toString()).limit(10).get(),
        builder: (context, snapshot) =>
            ListView.builder(
              itemCount:snapshot.hasData ? snapshot.data.size : 0,
              itemBuilder: (context, index) => ListTile(
              title: Text("${snapshot.data.docs[index].get("title")}"),
              subtitle: Text("${snapshot.data.docs[index].get("body")}"),
             trailing: Text("${DateFormat("yyyy/MM/dd").format(snapshot.data.docs[index].get("createdAt").toDate())}"),
            ),),
      ),
    );
  }
}
