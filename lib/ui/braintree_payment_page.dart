import 'package:flutter/material.dart';
import 'package:braintree_payment/braintree_payment.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:next_hour/ui/subscription.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:next_hour/loading/loading_screen.dart';
import 'package:next_hour/widget/success_ticket.dart';

class BraintreePaymentPage extends StatefulWidget {
  final int index;

  BraintreePaymentPage({Key key, this.index}) : super(key: key);

  @override
  _BraintreePaymentPageState createState() => _BraintreePaymentPageState();
}

class _BraintreePaymentPageState extends State<BraintreePaymentPage> {
  var nonceStatus;
  var noncePayment;
  var msgResponse;
  String createdDate ='';
  String createdTime = '';
  var paymentResponse;
  var subscriptionResponse;
  bool isShowing = false;
  bool isBack = true;
  var ind;

//  Generating client nonce from braintree to access payment services
  Future<String> getClientNonce() async {
    setState(() {
      isBack = false;
    });
    setState(() {
      isShowing = true;
    });

    Fluttertoast.showToast(msg: "Don't press back button.");

    final clientTokenResponse =
    await http.get(Uri.encodeFull(APIData.clientNonceApi), headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: fullData
    });
    var resBody = json.decode(clientTokenResponse.body);
    if (clientTokenResponse.statusCode == 200) {
      braintreeClientNonce = resBody['client'];
      payNow(braintreeClientNonce);
      print("Client Token: $resBody");
    }
    return null;
  }

  // Alert dialog to save show progress
  Widget alertUploadingDetails(){
    return WillPopScope(
        child: AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            height: 100.0,
            width: 200.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Uploading Details...", style: TextStyle(color: textColor),),
                SizedBox(height: 15.0,),
                CircularProgressIndicator(),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
        ), onWillPop: () async => false);
  }

  goToDialog2() {
    if(isShowing == true) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return alertUploadingDetails();
          }
      );
    }
  }

//  Creating payment and send the require details to server
  payNow(String clientNonce) async {
    BraintreePayment braintreePayment = new BraintreePayment();
    var data = await braintreePayment.showDropIn(
        nonce: clientNonce,
        amount: "${plan_details[widget.index]['amount']}",
        enableGooglePay: true);
    print("Payyment: $data");
    nonceStatus = data['status'];
    noncePayment = data['paymentNonce'];
    if (data['status'] == 'success') {
      sendPaymentNonce();
    }
  }

//  Saving payment details to your server so that user details can be updated either user is subscribed or not subscribed.
  Future<String> sendPaymentNonce() async {
    goToDialog2();
    final sendNonceResponse =
    await http.post(APIData.sendPaymentNonceApi, body: {
      "amount": "${plan_details[widget.index]['amount']}",
      "nonce": noncePayment,
      "plan_id": "${plan_details[widget.index]['id']}",
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: fullData
    });
    paymentResponse = json.decode(sendNonceResponse.body);
    msgResponse = paymentResponse['message'];
    subscriptionResponse = paymentResponse['subscription'];
    var date  = subscriptionResponse['created_at'];
    var time = subscriptionResponse['created_at'];
    createdDate = DateFormat('d MMM y').format(DateTime.parse(date));
    createdTime = DateFormat('HH:mm a').format(DateTime.parse(time));

    if (sendNonceResponse.statusCode == 200) {
      setState(() {
        isShowing = false;
      });
      goToDialog(createdDate, createdTime);
    } else{
      setState(() {
        isShowing = false;
      });
      Fluttertoast.showToast(msg: "Your transaction failed");
    }
    return null;
  }

  /*
  After creating successful payment and saving details to server successfully.
  Create a successful dialog
*/
  Widget appBar() => AppBar(
    title: Text(
      "Subscription Plans",
      style: TextStyle(fontSize: 16.0),
    ),
    centerTitle: true,
    backgroundColor: primaryDarkColor.withOpacity(0.98),
  );

  Widget closeFloatingButton() => FloatingActionButton(
    backgroundColor: Colors.black,
    child: Icon(
      Icons.clear,
      color: Colors.white,
    ),
    onPressed: () {
      var router = new MaterialPageRoute(
          builder: (BuildContext context) => new LoadingScreen());
      Navigator.of(context).push(router);
    },
  );

  Widget goToDialog(subdate, time) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) =>
            WillPopScope(child: GestureDetector(
              child: Container(
                color: primaryColor.withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SuccessTicket(msgResponse, subdate, name, time, ind),
                    SizedBox(
                      height: 10.0,
                    ),
                    closeFloatingButton(),
                  ],
                ),
              ),
            ), onWillPop: () async => false)
    );
    return null;
  }

  Widget makeListTile1(){
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: EdgeInsets.only(right: 20.0),
        decoration: new BoxDecoration(
            border: new Border(
                right: new BorderSide(width: 1.0, color: Colors.white24))),
        child: Icon(FontAwesomeIcons.sortAmountDownAlt, color: Colors.white, size: 20.0,),
      ),
      title: Padding(padding: EdgeInsets.only(top: 10.0),
        child: Text(
          '${plan_details[widget.index]['name']}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),
        ),),
      subtitle:
      Container(
        height: 40.0,
        child:  Column(
          children: <Widget>[
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text('Min duration '+ '${plan_details[widget.index]['interval_count']}'+' days', style: TextStyle(color: Colors.white, fontSize: 12.0)),
                ),
              ],
            ),
          ],
        ),
      ),
      trailing:
      Column(
          children:<Widget>[
            Text("Amount: "+'\n' +
                '${plan_details[widget.index]['amount']} ' + '${plan_details[widget.index]['currency']}'),
          ]
      ),
    );
  }

  Widget braintreeLogoContainer(){
    return Container(
      decoration: BoxDecoration(
          color: primaryDarkColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10.0)
      ),
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          Padding(padding: EdgeInsets.all(50.0),
            child: Image.asset("assets/braintree_logo.png", scale: 1.0, width: 150.0,),
          )
        ],
      ),
    );
  }

  Widget paymentDetailsCard(){
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
            color: primaryDarkColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10.0)
        ),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            makeListTile1()
          ],
        ),
      ),
    );
  }

  Widget _body(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 20.0,
          ),
          Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: braintreeLogoContainer(),
          ),

          SizedBox(
            height: 30.0,
          ),
          paymentDetailsCard(),

          SizedBox(
            height: 20.0,
          ),
          isShowing == true
              ? CircularProgressIndicator()
              : Padding(padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: payButtonRow(),
          )
        ],
      ),
    );
  }

  Widget payButtonRow(){
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            onPressed: getClientNonce,
            color: Color.fromRGBO(72, 163, 198, 1.0),
            child: Text(
              "Continue Pay",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isBack = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    ind = widget.index;
    return WillPopScope(
        child: Scaffold(
          appBar: appBar(),
          body: _body(),
          backgroundColor: primaryColor,
        ), onWillPop: ()async => isBack);
  }
}

