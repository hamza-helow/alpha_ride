import 'package:flutter/material.dart';

class CustomerBottomSheet extends StatelessWidget {

  final Function callBack;

  const CustomerBottomSheet({
    Key key,
    this.callBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: true,
        initialChildSize: 0.37,
        minChildSize: 0.2,
        maxChildSize: 0.37,
        builder: (context, scrollController) {
          return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
              return true;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: ClampingScrollPhysics(),
              child: Container(
                color: Color(0xF2FFFFFF),
                child: Column(
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[


                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[300],
                              ),
                              height: 5,
                              width: 40,
                            ),
                          ),
                        ],
                      ),
                    ),


                    Padding(
                      padding: EdgeInsets.all(10.0),

                      child:  ListTile(

                        leading: Image.asset("Assets/enconomy.png"),
                        title: Text("Enconomy"),
                        trailing: Text("1 min"),

                      ),

                    ),

                    Divider(),


                    Padding(
                      padding: EdgeInsets.all(10.0),

                      child:  ListTile(

                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          child: Text("%" , style: TextStyle(color: Colors.white),),
                        ),
                        title: Text("Discount"),
                        trailing: Text("Add promo code"),

                      ),

                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,


                      children: [

                        Padding(
                          padding: EdgeInsets.only(
                            top: 10 ,
                            bottom: 10.0
                          ),

                          child: SizedBox(
                            width: 100.0,

                            child:  MaterialButton(
                              color: Colors.deepOrange,

                              shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(color: Colors.red)
                              ),

                              onPressed: () {

                                callBack();
                              },
                              height: 60.0,
                              child: Icon(Icons.arrow_back_ios_rounded ,color: Colors.white,),

                            ),
                          ),

                        ),

                        Padding(
                          padding: EdgeInsets.only(
                              top: 10 ,
                              bottom: 10.0 ,
                            left: 7.0
                          ),

                          child: SizedBox(
                            width: 250.0,

                            child:  MaterialButton(
                              color: Colors.deepOrange,

                              shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(color: Colors.red)
                              ),

                              onPressed: () {},
                              height: 60.0,
                              child: Text("YALLA", style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold ,fontSize: 22.0)),

                            ),
                          ),

                        ),


                      ],

                    ),


                    SizedBox(height: 20.0, )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class _ConfirmTrip extends StatelessWidget {
  const _ConfirmTrip({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
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
      ),
    );
  }
}

class TimeSelectorWidget extends StatelessWidget {
  const TimeSelectorWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: 'Now',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          WidgetSpan(
            child: SizedBox(
              width: 2.5,
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }
}

class _RecommendedTrip extends StatelessWidget {
  final String postcode;
  final String addressLine1;
  const _RecommendedTrip({
    Key key,
    String postcode,
    String addressLine1,
  })  : this.postcode = postcode,
        this.addressLine1 = addressLine1,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        leading: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: ShapeDecoration(
              color: Colors.grey[200],
              shape: CircleBorder(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.location_on,
                size: 15,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              postcode,
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            Text(
              addressLine1,
              style: TextStyle(fontSize: 14, color: Colors.deepOrange),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 17,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
