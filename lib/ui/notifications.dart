import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NotificationsState();
  }
}

class NotificationsState extends State<NotificationsPage>{

  // ignore: unused_field
  String _debugLabelString = "";
  // ignore: unused_field
  bool _enableConsentButton = false;
  var notificationsLen;
  var notificationsArray;
  bool _requireConsent = true;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getAllNotifications();
    _handleConsent();
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show();
    await Future.delayed(Duration(seconds: 2));
    getAllNotifications();
  }

  Future<void> getAllNotifications() async{
    final notificationsResponse = await http.get(
        Uri.encodeFull(
            APIData.notificationsApi),
        headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: fullData
        });
    print(notificationsResponse.statusCode);
    var res = json.decode(notificationsResponse.body);
    setState(() {
      notificationsArray = res['notifications'];
    });

    notificationsLen = res['notifications'] == null ? 0 : res['notifications'].length;
    return null;
  }



  Future<void> initPlatformState() async {

    if (!mounted) return;
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        _debugLabelString =
        "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        _debugLabelString =
        "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared.setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        _debugLabelString =
        "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver(
            (OSEmailSubscriptionStateChanges changes) {
          print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
        });

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared
        .init("c6a46559-2a32-42d4-bd24-e51f4339740f", iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    this.setState(() {
      _enableConsentButton = requiresConsent;
    });

  }


//  Handle notification permission
  void _handleConsent() {
    print("Setting consent to true");
    OneSignal.shared.consentGranted(true);

    print("Setting state");
    this.setState(() {
      _enableConsentButton = false;
    });
  }

//  App bar
  Widget appBar(){
    return AppBar(
      title: Text("Notifications",style: TextStyle(fontSize: 16.0),),
      centerTitle: true,
      backgroundColor:
      Color.fromRGBO(34,34,34, 1.0).withOpacity(0.98),
    );
  }

  Widget notificationIconContainer(){
    return Container(
      child: Icon(Icons.notifications, size: 150.0, color: Color.fromRGBO(70, 70, 70, 1.0),),
    );
  }

//  Message when any notification is not available
  Widget message(){
    return  Padding(padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Text("You doesn't have any notification.",
        style: TextStyle(height: 1.5,color: Colors.white70),),);
  }

//  When doesn't have any notification.
  Widget blankNotificationContainer(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          notificationIconContainer(),
          SizedBox(
            height: 25.0,
          ),
          message(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshIndicator(
        child: Scaffold(
          appBar: appBar(),
          body: notificationsLen == null ?
          blankNotificationContainer() :
          ListView.builder(
              itemCount: notificationsArray == null ?  0 : notificationsLen,
              itemBuilder: (context, index){
                var subtitle = notificationsArray[index]['data'] ['data'];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: bluePrime,
                    child: Text("$index", style: TextStyle(
                        color: whiteColor
                    ),),
                  ),
                  title: Text("${notificationsArray[index]['title']}"),
                  subtitle: Text("$subtitle", style: TextStyle(
                    fontSize: 12.0,
                  ),
                    maxLines: 1,
                  ),
                );
              }),
        ),
        onRefresh: refreshList);
  }

}