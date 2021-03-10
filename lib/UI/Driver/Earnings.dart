import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/UI/Common/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

class Earnings extends StatefulWidget {
  @override
  _EarningsState createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {

  double totalTrips = 0 , earningsTotal  = 0;
  int numberOfTrips = 0;

  int p ;

  String fromDate='' , toDate ='';

  @override
  void initState() {

   // getEarnings('2021/03/01' ,'2021/03/07');
    super.initState();
  }

  void getEarnings(String to , String from)async{

   final settingApp =   await FirebaseHelper().getSettingApp();

   CollectionReference reference = FirebaseFirestore.instance.collection("Trips") ;

   (){
     if(to.isEmpty && from.isEmpty)
       return reference.where('idDriver' , isEqualTo: auth.currentUser.uid);
    else if(to.isEmpty)
       return reference.where('idDriver' , isEqualTo: auth.currentUser.uid).where('date'  , isEqualTo: from);
     else if (from.isEmpty)
       return reference.where('idDriver' , isEqualTo: auth.currentUser.uid).where('date'  , isEqualTo: to);
     else
       return reference.where('idDriver' , isEqualTo: auth.currentUser.uid).where('date'  , isEqualTo: from);
   }()  .get().then((value) {

      totalTrips = 0 ;
      numberOfTrips = 0 ;
      earningsTotal = 0 ;
      setState(() {});

      if(value.docs.length == 0)
        return;

      numberOfTrips = value.docs.length ;

      value.docs.forEach((element) {
        
        totalTrips+= element.get('totalPrice')??0;
        earningsTotal += (element.get('totalPrice')??0)-  ((element.get('totalPrice')??0) *double.parse('0.${settingApp.percentageDriver}'));

      });



      setState(() {});

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: DataProvider().baseColor,
        title: Text("${AppLocalizations.of(context).translate('earnings')}"),
      ),

      body: SingleChildScrollView(

        child: Column(

          children: [

            SizedBox(height: 40.0,),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width /2 -25,

                  child:  DateTimePicker(


                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.date_range_outlined),
                      labelText: "${AppLocalizations.of(context).translate('from')}",
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                    initialValue: '',
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    dateLabelText: 'Date',
                    onChanged: (val) {
                      print(val);
                    },
                    validator: (val) {
                      print(val);

                      fromDate = val.replaceAll("-", "/");

                      getEarnings(fromDate, toDate);

                      return null;
                    },
                    onSaved: (val) => print(val),
                  ),
                ),
                SizedBox(width: 10.0,),

                SizedBox(
                  width: MediaQuery.of(context).size.width /2 -25,

                  child:  DateTimePicker(


                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.date_range_outlined),
                      labelText: "${AppLocalizations.of(context).translate('to')}",
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                    initialValue: '',
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    dateLabelText: 'Date',
                    onChanged: (val) {
                      print(val);
                      toDate = val.replaceAll("-", "/");
                      getEarnings(fromDate, toDate);
                    },
                    validator: (val) {
                      print(val);
                      return null;
                    },
                    onSaved: (val) => print(val),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.0,),
            Divider(),

            SizedBox(height: 20.0,),

            ListTile(
              title: Text("${AppLocalizations.of(context).translate('numberTrips')}"),
              leading: Icon(Icons.format_list_numbered),
              subtitle: Text("${numberOfTrips == 0 ? '-' : numberOfTrips}"),
            ) ,
            SizedBox(height: 10.0,),
            ListTile(
              title: Text("${AppLocalizations.of(context).translate('totalTrips')}"),
              leading: Icon(Icons.monetization_on_rounded),
              subtitle: Text("${totalTrips == 0 ? '-' : totalTrips.toStringAsFixed(2)}"),
            ) ,
            SizedBox(height: 10.0,),
            ListTile(
              title: Text("${AppLocalizations.of(context).translate('earningsTrips')}"),
              leading: Icon(Icons.monetization_on_rounded),
              subtitle: Text("${earningsTotal == 0 ? '-' : earningsTotal.toStringAsFixed(2)}"),
            ) ,
            SizedBox(height: 10.0,),

          ],

        ),
      ),

    );
  }
}
