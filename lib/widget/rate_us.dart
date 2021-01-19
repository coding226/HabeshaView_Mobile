import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:http/http.dart' as http;

class RateUs extends StatefulWidget {
  RateUs(this.type, this.id,);
  final type;
  final id;

  @override
  _RateUsState createState() => _RateUsState();
}

class _RateUsState extends State<RateUs> {
  var _rating;
  var s = 0;
  Widget rateText(){
    return Text(
      "Rate",
      style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
          color: Colors.white
        // color: Colors.white
      ),
    );
  }

  Widget rateUsTabColumn(){
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.star_border,
          size: 30.0,
          color: Colors.white,
        ),
        new Padding(
          padding:
          const EdgeInsets.fromLTRB(
              0.0, 0.0, 0.0, 10.0),
        ),
        rateText(),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        child: new InkWell(
          onTap: () {
            checkRating();
          },
          child: rateUsTabColumn(),
        ),
        color: Colors.transparent,
      ),
    );
  }
  Widget ratingVideosSheet(){

    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 5.0, right: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.close),
                onTap: (){
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RatingBar(
              onRatingChanged: (rating) {
                setState(() {
                  _rating = rating;
                }
                );
                postRating();
//                print(_rating);
                Navigator.pop(context);
              },
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              halfFilledIcon: Icons.star_half,
              isHalfAllowed: true,
              filledColor: greenPrime,
              emptyColor: bluePrime,
              halfFilledColor: Colors.amberAccent,
              size: 40,
            ),
          ],
        ),
      ],
    );
  }

  Future <String> postRating() async{
    final postRatingResponse = await http.post(APIData.postVideosRating, body: {
      "type": '${widget.type}',
      "id": '${widget.id}',
      "rating": '$_rating',
    },
        headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: fullData,
        });
    if(postRatingResponse.statusCode == 200){
      Fluttertoast.showToast(msg: "Rated Successfully");
    }else{
      Fluttertoast.showToast(msg: "Error in rating");
    }

    return null;
  }

  Future <String> checkRating() async{
    final checkRatingResponse = await http.get(APIData.checkVideosRating+'/'+'${widget.type}'+'/'+'${widget.id}',
        headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: fullData,
        });

    var checkRate = json.decode(checkRatingResponse.body);
    print(checkRate.length);
    var mRate;
    List s = List.generate(checkRate.length == null ? 0 : checkRate.length, (int index){
      mRate = checkRate[0];
        return Text(checkRate[0]);
    });
    if(mRate == "0"){
      _onRatingPressed();

    }else{
      Fluttertoast.showToast(msg: "Already Rated");
    }
    return null;
  }

  void _onRatingPressed() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0))
            ),
            height: 80.0,
            child: Container(
                decoration: new BoxDecoration(
                    color: cardColor
                ),
                child: ratingVideosSheet()),
          );
        });
  }
}
