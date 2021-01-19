import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:next_hour/loading/loading_page.dart';
import 'package:http/http.dart' as http;
import 'package:next_hour/widget/password_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:next_hour/utils/wavy_header_image.dart';
import 'package:sticky_headers/sticky_headers.dart';

File jsonFile;
Directory dir;
String fileName = "userJSON.json";
bool fileExists = false;
Map<dynamic, dynamic> fileContent;
var acct;

class ForgotPassword extends StatefulWidget {
  ForgotPassword(this.email);
  final email;
  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  bool _isSelected = false;
  String pass;
  final TextEditingController _newPasswordController = new TextEditingController();
  final TextEditingController _confirmNewPasswordController = new TextEditingController();
  bool _isButtonDisabled;
  String msg = '';
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = false;
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        this.setState(
                () => fileContent = json.decode(jsonFile.readAsStringSync()));
      }
    });
  }

  Future <String> resetPassword() async {
    final sendOtpResponse = await http.post(APIData.resetPasswordApi, body: {
      "email": widget.email,
      "password": _newPasswordController.text,
      "password_confirmation": _confirmNewPasswordController.text,
    });

    print(sendOtpResponse.statusCode);
    if(sendOtpResponse.body == 'ok'){
      Fluttertoast.showToast(msg: "Your password has been updated.");
      var route = MaterialPageRoute(
          builder: (context) => LoadingPage(isSelected: true, useremail: widget.email, userpass: _newPasswordController.text,));
      Navigator.push(context, route);
    }
    else {
      Fluttertoast.showToast(msg: "Invalid OTP");
    }
    return null;
  }
  
//  logo
  Widget logoImage(){
    return Padding(
      padding: EdgeInsets.only(top: 15.0, left: 20.0),
      child: Container(
        child: Image.network(
          '${APIData.logoImageUri}${loginConfigData['logo']}',
          scale: 0.9,
        ),
      ),
    );
  }

//Reset password heading text
  Widget resetPasswordHeadingText(){
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Reset Password!",
            style: TextStyle(
                color: primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w800),
            textAlign: TextAlign.start,
          )
        ],
      ),
    );
  }

// Header reset password page
  Widget headerResetPass(){
    return Stack(
      children: <Widget>[
        Container(
          margin: new EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
          child: WavyHeaderImage2(),
        ),
        Container(
          margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: WavyHeaderImage(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            logoImage(),
          ],
        ),
      ],
    );
  }

// Label new password
  Widget labelTextNewPassword(){
    return Padding(
      padding: EdgeInsets.only(
          left: 25.0, right: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Password",
            style: TextStyle(
                color: primaryColor.withOpacity(0.5),
                fontSize: 18,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

// Label confirm password
  Widget labelTextConfirmNewPass(){
    return Padding(
      padding: EdgeInsets.only(
          left: 25.0, right: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Confirm Password",
            style: TextStyle(
                color: primaryColor.withOpacity(0.5),
                fontSize: 18,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

// Confirm new password
  Widget confirmNewPassField(){
    return Material(
        elevation: 0.0,
        color: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: Offset(0, 2.0),
              blurRadius: 4.0,
            )
          ]),
          child: Padding(
              padding: EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      hintText: "Confirm password",
                      hintStyle: TextStyle(
                          color: primaryColor.withOpacity(0.4), fontSize: 18),
                    ),
                    style: TextStyle(
                        color: primaryColor.withOpacity(0.7), fontSize: 18),
                    validator: (val) {
                      if (val.length < 6) {
                        if (val.length == 0) {
                          return 'Confirm Password can not be empty';
                        } else {
                          return 'Password too short';
                        }
                      } else {
                        if(_newPasswordController.text == val){
                          return null;
                        }else{
                          return 'Password & Confirm Password does not match';
                        }

                      }
                    },
                    onSaved: (val) => _confirmNewPasswordController.text = val,
                    obscureText: true,
                  ),

                ],
              )
          ),
        )
    );
  }

// Reset Button
  Widget resetButton(){
    return ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: new InkWell(


                child: Material(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius:
                      new BorderRadius.circular(5.0),
                      // Box decoration takes a gradient
                      gradient: LinearGradient(
                        // Where the linear gradient begins and ends
                        begin: Alignment.topCenter,
                        end: Alignment.bottomRight,
                        // Add one stop for each color. Stops should increase from 0 to 1
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          // Colors are easy thanks to Flutter's Colors class.
                          Color.fromRGBO(
                              72, 163, 198, 0.4)
                              .withOpacity(0.4),
                          Color.fromRGBO(
                              72, 163, 198, 0.3)
                              .withOpacity(0.5),
                          Color.fromRGBO(
                              72, 163, 198, 0.2)
                              .withOpacity(0.6),
                          Color.fromRGBO(
                              72, 163, 198, 0.1)
                              .withOpacity(0.7),
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        new BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 10.0,
                          offset: new Offset(1.0, 10.0),
                        ),
                      ],
                    ),

                    child: new MaterialButton(
                        height: 50.0,
                        splashColor: Color.fromRGBO(125,183,91, 1.0),

                        child: Text(
                          "Reset Password",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                          // ignore: unnecessary_statements
                          _isButtonDisabled ? null : _submit();
                        }
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

//    Validate the form and and start loading home page
  void _submit() {
    final form = formKey.currentState;
    form.save();
    if (form.validate() == true) {
      resetPassword();
    }
  }

//  Sticky header content
  Widget stickyHeaderContent(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        resetPasswordHeadingText(),
        SizedBox(
          height: 30.0,
        ),
        Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              labelTextNewPassword(),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding:
                EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: HiddenPasswordField(_newPasswordController,"Enter password"),
              ),
              SizedBox(
                height: 20.0,
              ),
              labelTextConfirmNewPass(),

              Padding(
                padding:
                EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: confirmNewPassField(),
              ),
              SizedBox(
                height: 30.0,
              ),

              resetButton(),
              SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

//  Scaffold body
  Widget scaffoldBody(){
    return Form(
      onWillPop: () async {
        return true;
      },
      key: formKey,
      child: Container(
        color: Colors.white.withOpacity(0.95),
        alignment: Alignment.center,
        child: Center(
          child: new ListView(
            children: <Widget>[
              StickyHeader(
                header: headerResetPass(),
                content: stickyHeaderContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: scaffoldBody(),
      )
    );
  }
}
