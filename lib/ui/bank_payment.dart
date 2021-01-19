import 'package:flutter/material.dart';
import 'package:next_hour/global.dart';

class BankPaymentPage extends StatefulWidget {
  @override
  _BankPaymentPageState createState() => _BankPaymentPageState();
}

class _BankPaymentPageState extends State<BankPaymentPage> {

  Widget appBar(){
    return AppBar(
      title: Text("Bank Details", style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),),
      backgroundColor: primaryDarkColor.withOpacity(0.98),
      centerTitle: true,
    );
  }


  Widget _buildCard() => Column(
    children: [
      Padding(padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: Text("Bank"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Text("$bankName"),
              ),
            ),
          ],
        ),
      ),
      Padding(padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: Text("Branch"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Text("$branchName"),
              ),
            ),
          ],
        ),
      ),
      Padding(padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: Text("IFSC Code"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Text("$bankIFSCCode"),
              ),
            ),
          ],
        ),
      ),
      Padding(padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: Text("Account No."),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Text("$accountNo"),
              ),
            ),
          ],
        ),
      ),
      Padding(padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
        child: Text("* You can transfer the subscription amount in this account. Your subscription will be active after confirming amount for respective subscription. "
            "For query send email at - $wEmail",
          style: TextStyle(fontSize: 11.0,
              height: 1.1,
              letterSpacing: 0.4,
              color: whiteColor.withOpacity(0.6),
              fontWeight: FontWeight.w400),),),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(10.0),
            child: _buildCard(),)
        ],
      ),
    );
  }
}
