import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/UI/widgets/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  //32.5661186,35.8420676
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(32.5661186, 35.8420676),
    zoom: 16.4746,
  );


  LatLng _lastMapPosition ;
  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;

    print(_lastMapPosition);
  }

  @override
  Widget build(BuildContext context) {




    var userLocation = Provider.of<UserLocation>(context);

    var cameraPosition = userLocation != null
        ? CameraPosition(
      target: LatLng(userLocation.latitude, userLocation.longitude),
      zoom: 14,
    )
        : null;

    return Scaffold(

      key: _scaffoldKey,
      drawer: buildDrawer(),

      body: Stack(

        children: [

          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            compassEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            buildingsEnabled: true,
            myLocationButtonEnabled: false,
            minMaxZoomPreference: MinMaxZoomPreference(12, 20),
            mapToolbarEnabled: false,
            rotateGesturesEnabled: false,
            onCameraMove: _onCameraMove,

          ),

          // Positioned(
          //   left: 0,
          //   bottom: 0,
          //   right: 0,
          //   child: Column(
          //     children: <Widget>[
          //       Container(
          //
          //         height: 60,
          //         color: Color(0xF2FFFFFF),
          //
          //       ),
          //
          //     ],
          //   ),
          // ),

          UberBottomSheet(),

          Positioned(
            left: 0,
            top: (MediaQuery.of(context).size.height/2)-50,
            right: 0,
            child: Column(
              children: <Widget>[

                Icon(Icons.location_on_sharp , size: 50, color: Colors.deepOrange,)
              ],
            ),
          ),


          Positioned(
            left: 5,
            top: 10,
            right: 0,
            child: Column(
              children: <Widget>[
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  leading: FlatButton(
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    child: Icon(
                      Icons.menu,
                      color: Colors.deepOrange,
                      size: 30,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                )
              ],
            ),
          ),

        ],

      ),

    );
  }

  Drawer buildDrawer() {
    return Drawer(

      child: Container(

        color: Colors.white,
        child: ListView(

          children: <Widget>[

            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),

              accountName: Text("Hamza helow" ,style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold) ),
              accountEmail: Text("hamzihelow3@gmail.com" , style: TextStyle(color: Colors.black54)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.deepOrange ,
                child: Icon(FontAwesomeIcons.user , color: Colors.white,),
              ),

            ),

            Row(

              children: [
                Container(
                  height: 50.5,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(left: 14.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: Icon(
                          FontAwesomeIcons.gift,
                          color: Colors.deepOrange,
                          size: 21,
                        ),
                        backgroundColor: Colors.grey[200],
                        label: Text("300 point"),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50.5,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(left: 14.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: Icon(
                          Icons.star,
                          color: Colors.deepOrange,
                          size: 21,
                        ),
                        backgroundColor: Colors.grey[200],
                        label: Text("4.8"),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            ListTile(
              leading: Icon(Icons.time_to_leave_sharp),
              title: Text("You trips" ,),
              trailing: Padding(padding: EdgeInsets.only(right: 10), child: Text("10+" ,  style: TextStyle(color: Colors.deepOrange),),),
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings" ,),
            ),


            Divider(),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Log out" ,),
            ),

          ],
        ),
      ),
    );
  }
}
