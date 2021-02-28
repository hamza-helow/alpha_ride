import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:alpha_ride/Helper/FirebaseHelper.dart';
import 'package:alpha_ride/Models/Trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../Login.dart';

class ResultTrip extends StatelessWidget {

  double rating = 3.0 ;

  Function onFinish ;

  Trip currentTrip ;

  TypeAccount typeUser ;

  ResultTrip(this.onFinish , this.currentTrip , {this.typeUser = TypeAccount.driver});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 15,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: 10),
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[

              Padding(
                padding: EdgeInsets.only(top: 20.0) ,

                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 10, offset: Offset(3.0, 4.0))
                    ],
                    borderRadius: new BorderRadius.all(new Radius.circular(5)),
                    border: new Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),

                  width: MediaQuery.of(context).size.width -30 ,


                  child: Container(

                    color: Colors.white,


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [


                        SizedBox(height: 20,),

                        Text( typeUser == TypeAccount.driver ?"Your earnings for this trip" :"price" ,
                          style: TextStyle(fontSize: 22.0  , fontWeight: FontWeight.bold), textAlign: TextAlign.center,),

                        SizedBox(height: 10,),

                        Text("${DataProvider().calcPriceTotal(currentTrip)} JD" ,style: TextStyle(color: Colors.green ,fontSize: 22.0  , fontWeight: FontWeight.bold), textAlign: TextAlign.center,),

                        SizedBox(height: 20,)
                      ],
                    ),
                  ),

                ),


              ) ,

              Padding(
                padding: EdgeInsets.only(top: 10.0) ,

                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 11, offset: Offset(3.0, 4.0))
                    ],
                    borderRadius: new BorderRadius.all(new Radius.circular(5)),
                    border: new Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),

                  width: MediaQuery.of(context).size.width -30 ,


                  child: Container(

                    color: Colors.white,


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [


                        SizedBox(height: 20,),

                        Text("Rate ${ typeUser == TypeAccount.customer?  currentTrip.nameDriver : currentTrip.nameCustomer}" ,
                          style: TextStyle(fontSize: 22.0  , fontWeight: FontWeight.bold), textAlign: TextAlign.center,),

                        SizedBox(height: 10,),

                        RatingBar.builder(
                          initialRating: 3,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: DataProvider().baseColor,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                            rating = rating;
                          },
                        ),

                        SizedBox(height: 20,)
                      ],
                    ),
                  ),

                ),


              ) ,

              SizedBox(
                height: 60,
                width: MediaQuery.of(context).size.width - 30,
                child: MaterialButton(
                  color: DataProvider().baseColor,
                  onPressed: () {

                     print(currentTrip.idCustomer);

                    FirebaseHelper().ratingUser( typeUser == TypeAccount.driver ?  currentTrip.idCustomer : currentTrip.idDriver  , rating).then((_){

                      onFinish();

                      // this.setState(() {
                      //   exitTrip = false ;
                      //   showResultTrip = false ;
                      // });

                    });

                  },
                  child: Text("DONE" , style: TextStyle(color: Colors.white),),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
