import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:flutter/material.dart';

class PromoCodeBottomSheet extends StatefulWidget {


  Function()  hide;




  PromoCodeBottomSheet(this.hide  );

  @override
  _PromoCodeBottomSheetState createState() => _PromoCodeBottomSheetState();
}

class _PromoCodeBottomSheetState extends State<PromoCodeBottomSheet> {

  final code = TextEditingController();

  String errText ;

  @override
  Widget build(BuildContext context) {
   return  DraggableScrollableSheet(
        expand: true,
        initialChildSize: 0.26,
        minChildSize: 0.25,
        maxChildSize: 0.26,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      padding: EdgeInsets.all(20.0),
                      child:  new TextField(
                        controller: code,
                        decoration: new InputDecoration(
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.deepOrange)),
                            hintText: 'Enter promo code',
                            labelText: 'promo code',
                            errorText:errText ,
                            suffixStyle: const TextStyle(color: Colors.deepOrange)),
                      ),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.20,

                          child:  MaterialButton(
                            height: 50.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(color: Colors.red)
                            ),
                            onPressed: () {

                              widget.hide();

                            },
                            color: Colors.deepOrange,
                            child: Icon(Icons.clear , color: Colors.white,),
                          ),
                        ),

                        SizedBox(width: 20.0, ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.60,

                          child:  MaterialButton(
                            height: 50.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(color: Colors.red)
                            ),
                            onPressed: () {

                              FirebaseHelper().checkPromoCode(code.text).then((value){

                                if(value == 0)
                                 this.setState(() {
                                   errText = "Not found";
                                 });
                                else{

                                  DataProvider().promoCodePercentage = value;

                                  DataProvider().promoCode = code.text;

                                  widget.hide();

                                }

                                print("$value");

                              });

                            },
                            color: Colors.deepOrange,
                            child: Text("ADD" , style: TextStyle(color: Colors.white),),
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
