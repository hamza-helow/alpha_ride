import 'package:alpha_ride/Helper/SharedPreferencesHelper.dart';
import 'package:alpha_ride/Models/user_location.dart';
import 'package:alpha_ride/UI/Common/Settings.dart';
import 'package:alpha_ride/UI/Login.dart';
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

  String _fullName ="" , _email ="" ;

  @override
  void initState() {


    SharedPreferencesHelper().getEmail().then((value) {

      if(this.mounted)
        this.setState(() {
          _email= value;
        });

    });

    SharedPreferencesHelper().getFullName().then((value) {

      if(this.mounted)
        this.setState(() {
          _fullName= value;
        });

    });


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

          // UberBottomSheet(),

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
            left: 35,
            bottom: 20,
            right: 35,
            child:  Container(

              color: Colors.deepOrange,
              height: 60,

              width: 40,

              child: MaterialButton(
                onPressed: () => {},

                child:Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    Text("GO" , style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ,fontSize: 22.0),),
                    Icon(Icons.arrow_right_alt ,color: Colors.white,size: 50,),
                    Icon(Icons.location_on_sharp ,color: Colors.white,size: 25,),
                  ],
                ),
              ),

            ),
          ),

          // Positioned(
          //   left: 5,
          //   top: 10,
          //   right: 0,
          //   child: Column(
          //     children: <Widget>[
          //       AppBar(
          //         backgroundColor: Colors.transparent,
          //         elevation: 0.0,
          //         leading: FlatButton(
          //           onPressed: () {
          //             _scaffoldKey.currentState.openDrawer();
          //           },
          //           child: Icon(
          //             Icons.menu,
          //             color: Colors.deepOrange,
          //             size: 30,
          //           ),
          //         ),
          //       ),
          //       Padding(
          //         padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          //       )
          //     ],
          //   ),
          // ),



          buildAppBar()



        ],

      ),

    );
  }


  Positioned buildAppBar() {
    return Positioned(
      top: 27,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[



              SizedBox(width: 15,),

              GestureDetector(
                onTap: () => {
                  _scaffoldKey.currentState.openDrawer()
                },
                child: Icon(Icons.menu ,size: 30.0, color: Colors.deepOrange,) ,
              ),

              SizedBox(width: 20,),


              Expanded(

                child: Container(

                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey, blurRadius: 11, offset: Offset(3.0, 4.0))
                      ],
                      borderRadius: new BorderRadius.all(new Radius.circular(10)),
                      border: new Border.all(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),

                    width: MediaQuery.of(context).size.width - 100,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 60.5,
                            color: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Where to?',
                                  style: TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 60.5,
                            color: Colors.grey[200],
                            child: Padding(
                              padding: EdgeInsets.only(right: 14.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Chip(
                                  avatar: Icon(
                                    Icons.watch_later,
                                    color: Colors.deepOrange,
                                    size: 21,
                                  ),
                                  backgroundColor: Colors.white,
                                  label: TimeSelectorWidget(),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                ),

              ),



              SizedBox(width: 30,),

            ],
          ),
        ),
      ),
    );
  }




  Drawer buildDrawer() {
    return Drawer(


      child: Container(

        color: Colors.white,
        child: ListView(

          children: <Widget>[

            GestureDetector(

              onTap: () => {

              } ,

              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),

                accountName: Text("$_fullName" ,style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold) ),
                accountEmail: Text("$_email" , style: TextStyle(color: Colors.black54)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.deepOrange ,
                  child: Icon(FontAwesomeIcons.user , color: Colors.white,),
                ),

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
              onTap: () {

                Navigator.push(context, MaterialPageRoute(builder: (context) => Settings(),));


              },
              leading: Icon(Icons.settings),
              title: Text("Settings" ,),
            ),


            Divider(),

            ListTile(
              onTap: () {

                auth.signOut() ;

                Navigator.of(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  Login(),));

              },
              leading: Icon(Icons.logout),
              title: Text("Log out" ,),
            ),

          ],
        ),
      ),
    );
  }
}
