import 'package:alpha_ride/Enum/StateTrip.dart';
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Enum/TypeTrip.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Login.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:alpha_ride/UI/Common/TripInfoScreen.dart';

class TripsScreen extends StatefulWidget {
  TypeAccount typeAccount;

  TripsScreen({this.typeAccount = TypeAccount.customer});

  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<Trip> trips;

  @override
  void initState() {
    trips = List();

    getTrips("", "");
  }

  String fromDate = "", toDate = "";

  void getTrips(String from, String to) {
    () {
      if (from.isEmpty && to.isNotEmpty)
        return FirebaseFirestore.instance
            .collection("Trips")
            .where(
                widget.typeAccount == TypeAccount.driver
                    ? "idDriver"
                    : "idCustomer",
                isEqualTo: auth.currentUser.uid)
            .where('state', isNotEqualTo: StateTrip.active.toString())
            .where('date', isEqualTo: to)
            .get();
      else if (to.isEmpty && from.isNotEmpty)
        return FirebaseFirestore.instance
            .collection("Trips")
            .where(
                widget.typeAccount == TypeAccount.driver
                    ? "idDriver"
                    : "idCustomer",
                isEqualTo: auth.currentUser.uid)
            .where('state', isNotEqualTo: StateTrip.active.toString())
            .where('date', isEqualTo: from)
            .get();
      else if (to.isNotEmpty && from.isNotEmpty)
        return FirebaseFirestore.instance
            .collection("Trips")
            .where(
                widget.typeAccount == TypeAccount.driver
                    ? "idDriver"
                    : "idCustomer",
                isEqualTo: auth.currentUser.uid)
            .where('state', isNotEqualTo: StateTrip.active.toString())
            .where('date', isGreaterThanOrEqualTo: from)
            .where('date', isLessThanOrEqualTo: to)
            .get();
      else
        return FirebaseFirestore.instance
            .collection("Trips")
            .where('state', isNotEqualTo: StateTrip.active.toString())
            .where(
                widget.typeAccount == TypeAccount.driver
                    ? "idDriver"
                    : "idCustomer",
                isEqualTo: auth.currentUser.uid)
            .get();
    }()
        .then((list) {
      if (this.mounted)
        this.setState(() {
          trips.clear();
          list.docs.forEach((trip) {
            Trip item = new Trip(
                locationDriver: LatLng(trip.get("locationDriver.lat"),
                    trip.get("locationDriver.lng")),
                locationCustomer: LatLng(trip.get("locationCustomer.lat"),
                    trip.get("locationCustomer.lng")),
                totalPrice: double.parse('${trip.get('totalPrice')??0}'),
                startDate:
                    DateTime.parse(trip.get('dateStart').toDate().toString()),
                idCustomer: trip.get("idCustomer"),
                idDriver: trip.get("idDriver"),
                hourTrip: trip.get("hours"),
                typeTrip: trip.get("typeTrip") == TypeTrip.distance.toString()
                    ? TypeTrip.distance
                    : TypeTrip.hours,
                stateTrip: () {
                  final state = trip.get("state");

                  if (state == StateTrip.active.toString())
                    return StateTrip.active;
                  else if (state == StateTrip.started.toString())
                    return StateTrip.started;
                  else if (state == StateTrip.done.toString())
                    return StateTrip.done;
                  else if (state == StateTrip.cancelByCustomer.toString())
                    return StateTrip.cancelByCustomer;
                  else
                    return StateTrip.cancelByDriver;
                }());

            _getAddressFromLatLng(trip.get("locationCustomer.lat"),
                    trip.get("locationCustomer.lng"))
                .then((value) {
              item.addressStart = value;
            });
            _getAddressFromLatLng(trip.get("locationDriver.lat"),
                    trip.get("locationDriver.lng"))
                .then((value) {
              item.addressEnd = value;
            });

            trips.add(item);
          });
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DataProvider().baseColor,
        title: Text("Your trips"),
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30),
              child: DateTimePicker(
                decoration: InputDecoration(
                  labelText: "From",
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                ),
                initialValue: '',
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                dateLabelText: 'Date',
                onChanged: (val) {
                  print(val);
                  fromDate = val.replaceAll("-", "/");
                  getTrips(fromDate, toDate);
                },
                validator: (val) {
                  print(val);
                  return null;
                },
                onSaved: (val) => print(val),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 20),
              child: DateTimePicker(
                decoration: InputDecoration(
                  labelText: "To",
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
                  getTrips(fromDate, toDate);
                },
                validator: (val) {
                  print(val);
                  return null;
                },
                onSaved: (val) => print(val),
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: trips.length,
                itemBuilder: (context, index) => InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TripInfoScreen(
                                    trips[index],
                                    typeAccount: widget.typeAccount,
                                  ))),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  () {
                                    // "${trips[index].totalPrice}"

                                    if (trips[index].stateTrip ==
                                        StateTrip.cancelByCustomer)
                                      return "قمت بالغاء الرحلة";
                                    else
                                      return "${trips[index].totalPrice}";
                                  }(),
                                  style: TextStyle(
                                      color: trips[index].stateTrip ==
                                                  StateTrip.cancelByCustomer ||
                                              trips[index].stateTrip ==
                                                  StateTrip.cancelByDriver
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${DateFormat('yyyy/MM/dd hh:mm').format(trips[index].startDate)}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 15,
                                      color: DataProvider().baseColor,
                                    ),
                                    Text("|"),
                                    Icon(
                                      Icons.circle,
                                      size: 25,
                                      color: DataProvider().baseColor,
                                    ),
                                  ],
                                ),
                                Flexible(
                                    child: Column(
                                  children: [
                                    Text(
                                      "${trips[index].addressStart}",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(""),
                                    Text(
                                      "${trips[index].addressEnd}",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Divider()
                          ],
                        ),
                      ),
                    ))
          ],
        ),
      ),
    );
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    String address = "";

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks[0];

      address =
          "${place.street} ${place.locality}, ${place.name}, ${place.country}";
    } catch (e) {
      print("EEEEE $e");
    }

    return address;
  }
}
