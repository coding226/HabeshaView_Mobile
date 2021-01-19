import 'dart:async';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:next_hour/ui/plan_text.dart';
import 'package:next_hour/utils/color_loader.dart';
import 'package:next_hour/ui/select_payment.dart';

// ignore: non_constant_identifier_names
var plan_details;

class SubscriptionPlan extends StatefulWidget {
    @override
    SubscriptionPlanState createState() => SubscriptionPlanState();
}

class SubscriptionPlanState extends State<SubscriptionPlan> {

//  Getting plan details from server
    Future<String> planDetails() async {
        final basicDetails = await http.get(
            Uri.encodeFull(APIData.homeDataApi),
        );
        homeDataResponseDetails = json.decode(basicDetails.body);
//        var priText= homeDataResponseDetails['plans'][0]['pricing_texts'];
//        print("Pricing Text: $priText");
        setState(() {
            plan_details = homeDataResponseDetails['plans'];
        });
        return null;
    }

    @override
    void initState() {
        super.initState();
        this.planDetails();
    }

//  List used to show all the plans using home API
    List<Widget> _buildCards(int count) {
        List<Widget> cards = List.generate(count, (int index) {
            var dailyAmount = plan_details[index]['amount'] /  plan_details[index]['interval_count'];

            String dailyAmountAp = dailyAmount.toStringAsFixed(2);

            //      Used to check soft delete status so that only active plan can be showed
            if(plan_details[index]['status'] == 1){
                return plan_details[index]['delete_status'] == 0 ? SizedBox.shrink() : subscriptionCards(index, dailyAmountAp);
            }else{
                return SizedBox.shrink();
            }

        });

        return cards;
    }

//  App bar
    Widget appBar() => AppBar(
        title: Text(
            "Subscription Plans",
            style: TextStyle(fontSize: 16.0),
        ),
        centerTitle: true,
        backgroundColor: primaryColor.withOpacity(0.98),
    );

//  Subscribe button
    Widget subscribeButton(index){
        return Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Material(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                            height: 50.0,
                            width: 150.0,
                            decoration: BoxDecoration(
                                borderRadius: new BorderRadius.circular(5.0),
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomRight,
                                    stops: [0.1, 0.5, 0.7, 0.9],
                                    colors: [
                                        Color.fromRGBO(255, 165, 0, 0.4)
                                            .withOpacity(0.4),
                                        Color.fromRGBO(255, 165, 0, 0.3)
                                            .withOpacity(0.5),
                                        Color.fromRGBO(255, 165, 0, 0.2)
                                            .withOpacity(0.6),
                                        Color.fromRGBO(255, 165, 0, 0.1)
                                            .withOpacity(0.7),
                                    ],
                                ),
                            ),
                            child: new MaterialButton(
                                height: 60.0,
                                splashColor: Color.fromRGBO(255, 165, 0, 0.9),
                                child: Text(
                                    "Subscribe",
                                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                                ),
                                onPressed: () {
                                    //   Working after clicking on subscribe button
                                    var router = new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                        new SelectPayment(
                                            indexPer: index,
                                        ));
                                    Navigator.of(context).push(router);
                                }),
                        ),
                    ),
                    SizedBox(height: 8.0),
                ],
            ),
        );
    }

//  Amount with currency
    Widget amountCurrencyText(index){
        return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Expanded(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Text(
                                "${plan_details[index]['amount']}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25.0),
                                textAlign: TextAlign.center,
                            ),
                            SizedBox(
                                width: 3.0,
                            ),
                            Text('${plan_details[index]['currency']}'),
                        ],
                    )),
            ]);
    }

//  Daily amount
    Widget dailyAmountIntervalText(dailyAmountAp, index){
        return Row(children: <Widget>[
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                        "$dailyAmountAp / ${plan_details[index]['interval']}",
                        style: TextStyle(
                            color: Colors.white, fontSize: 12.0),
                        textAlign: TextAlign.center,
                    ),
                ),
            ),
        ]);
    }

//  Plan Name
    Widget planNameText(index){
        return Container(
            height: 45.0,
            color: primaryDarkColor,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Expanded(
                        child: Text(
                            '${plan_details[index]['name']}',
                            style: TextStyle(
                                color: Colors.white, fontSize: 18.0,
                            ),
                            textAlign: TextAlign.center,
                        ),
                    ),
                ],
            ),
        );
    }

//  Subscription cards
    Widget subscriptionCards(index, dailyAmountAp){
        return InkWell(
            child: Card(
                elevation: 10.0,
                color: cardColor,
                clipBehavior: Clip.antiAlias,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        AspectRatio(
                            aspectRatio: 18.0 / 8.0,
                            child: Column(
                                children: <Widget>[
                                    planNameText(index),
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                    ),
                                    amountCurrencyText(index),
                                    dailyAmountIntervalText(dailyAmountAp,index),
                                    plan_details[index]['pricing_texts'] == null ?
                                    SizedBox.shrink()
                                        : Padding(
                                        padding: EdgeInsets.only(left: 30.0, right: 20.0,),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                                Icon(FontAwesomeIcons.check, color: whiteColor, size: 14.0, ),
                                                SizedBox(width: 15.0,),
                                                Text("${plan_details[index]['pricing_texts']['title1']}",
                                                    style: TextStyle(color: whiteColor, fontSize: 12.0),)
                                            ],
                                        ),
                                    ),
                                    plan_details[index]['pricing_texts'] == null ?
                                    SizedBox.shrink()
                                        : Padding(
                                        padding: EdgeInsets.only(left: 30.0, right: 20.0, top: 10.0),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                                Icon(FontAwesomeIcons.check, color: whiteColor, size: 14.0, ),
                                                SizedBox(width: 15.0,),
                                                Text("${plan_details[index]['pricing_texts']['title2']}",
                                                    style: TextStyle(color: whiteColor, fontSize: 12.0),)
                                            ],
                                        ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(left: 30.0, right: 20.0, top: 10.0),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                                Text("... Read More",
                                                    style: TextStyle(color: whiteColor, fontSize: 12.0),)
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        subscribeButton(index),
                    ],
                ),
            ),
            onTap: (){
                var router = new MaterialPageRoute(
                    builder: (BuildContext context) =>
                    new PlanTextPage(
                        index,
                    ));
                Navigator.of(context).push(router);
            },
        );
    }

// Scaffold body
    Widget scaffoldBody(){
        return plan_details == null ? Container(
            child: ColorLoader(),) : Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
                child: Column(
                    children: _buildCards(
                        plan_details == null ? 0 : plan_details.length),
                ),
            ));
    }

//  Build Method
    @override
    Widget build(BuildContext context) {
        // TODO: implement build
        return SafeArea(
            child: Scaffold(
                appBar: appBar(),
                body: scaffoldBody(),
                backgroundColor: primaryColor,
            ),
        );
    }
}







