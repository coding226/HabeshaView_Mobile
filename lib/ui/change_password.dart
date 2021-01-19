import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:http/http.dart' as http;

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController _editNewPasswordController = new TextEditingController();
  TextEditingController _editNewConfirmPasswordController = new TextEditingController();
  final formKey = new GlobalKey<FormState>();
  bool _isOldHidden = true;
  bool _isNewHidden = true;
  bool _isConfirmNewHidden = true;
  bool isShowIndicator = false;
  var sEmail;
  var sPass;
  var sOldPass;

  Widget appBar(){
    return AppBar(
      title: Text("Change Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0, color: whiteColor),),
      centerTitle: true,
      leading: IconButton(icon: Icon(Icons.arrow_back, color: whiteColor), onPressed: (){
        Navigator.pop(context);
      }),
      backgroundColor: Color.fromRGBO(20, 20, 20, 1.0),
    );
  }

//  Visibility toggle for old password
  void _toggleVisibility1() {
    setState(() {
      _isOldHidden = !_isOldHidden;
    });
  }

//  Visibility toggle for new password
  void _toggleVisibility2() {
    setState(() {
      _isNewHidden = !_isNewHidden;
    });
  }

//  Visibility toggle for confirm password
  void _toggleVisibility3() {
    setState(() {
      _isConfirmNewHidden = !_isConfirmNewHidden;
    });
  }


//  TextField for new password
  Widget buildNewPasswordTextField(String hintText) {
    return TextFormField(
      controller: _editNewPasswordController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.all(5.0),
        prefixIcon: Icon(Icons.lock_outline),
        suffixIcon: hintText == "New Password" ?
        IconButton(
          onPressed: _toggleVisibility2,
          icon: _isNewHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),) : null,),

      obscureText: hintText == "New Password" ? _isNewHidden : false,

      validator: (val) {
        if (val.length < 6) {
          if(val.length==0){
            return "Enter Password!";
          }else{
            return "Password too short!";
          }
        } else {
          return null;
        }
      },
      onSaved: (val) => _editNewPasswordController.text = val,
    );
  }

//  Confirmation of new password field
  Widget buildNewConfirmPasswordTextField(String hintText) {
    return TextFormField(
      controller: _editNewConfirmPasswordController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.all(5.0),
        prefixIcon: Icon(Icons.lock),
        suffixIcon: hintText == "Confirm New Password" ?
        IconButton(
          onPressed: _toggleVisibility3,
          icon: _isConfirmNewHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),) : null,
      ),
      obscureText: hintText == "Confirm New Password" ? _isConfirmNewHidden : false,

//      Validation for password
      validator: (val) {
        if (val.length < 6) {
          if(val.length==0){
            return 'Enter Password!';
          }else{
            return 'New Password too short!';
          }
        } else {
          if(_editNewPasswordController.text == val){
            return null;
          }else{
            return 'New Password & Confirm new password does not match.';
          }

        }
      },
      onSaved: (val) => _editNewConfirmPasswordController.text = val,
    );
  }

//  Form that containing text fields to update profile
  Widget form(){
    return Container(
      padding: EdgeInsets.only(
          top: 10.0, right: 20.0, left: 20.0, bottom: 20.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            buildNewPasswordTextField("New Password"),
            SizedBox(
              height: 20.0,
            ),
            buildNewConfirmPasswordTextField("Confirm New Password"),
            SizedBox(
              height: 30.0,
            ),
            updateButtonContainer(),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  //  Update button container
  Widget updateButtonContainer() {
    return InkWell(
      child: Container(
        height: 50.0,
        width: MediaQuery.of(context).size.width,
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
                  255, 165, 0, 0.4)
                  .withOpacity(0.4),
              Color.fromRGBO(
                  255, 165, 0, 0.3)
                  .withOpacity(0.5),
              Color.fromRGBO(
                  255, 165, 0, 0.2)
                  .withOpacity(0.6),
              Color.fromRGBO(
                  255, 165, 0, 0.1)
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
        child: Center(
          child: isShowIndicator == true ? CircularProgressIndicator(
            backgroundColor: Colors.white,
          ) : Text(
            "Change Password",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ),
      ),

      onTap: (){
//     To remove keypad on tapping button
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        setState(() {
          isShowIndicator = true;
        });
        final form = formKey.currentState;
        form.save();
        if (form.validate() == true) {
          writeToFile("pass", _editNewPasswordController.text);
         sPass= fileContent['pass'];
          updatePass();
        }else{
          setState(() {
            isShowIndicator = false;
          });
        }
      },
    );
  }

//  Show a dialog after updating password
  Future<void> _profileUpdated(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(5.0),
            content: Container(
              height: 100.0,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  Text('Your password updated.',style: TextStyle(color: textColor.withOpacity(0.8)),),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text('Ok',style: TextStyle(fontSize: 16.0,color: greenPrime),),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          onWillPop: () async => false,
        );
      },
    );
  }

  Future <String> updatePass() async {
    final updateResponse = await http.post( APIData.userProfileUpdate, body: {
      "email" : sEmail,
      "current_password": sOldPass,
      "new_password": sPass,
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: fullData
    });
    print(updateResponse.statusCode);
    setState(() {
      isShowIndicator = false;
    });
    if(updateResponse.statusCode == 200){
      _editNewPasswordController.text = '';
      _editNewConfirmPasswordController.text = '';
      _profileUpdated(context);
    }else{
      Fluttertoast.showToast(msg: "Password updating failed.");
      setState(() {
        isShowIndicator = false;
      });
    }
  }

  void writeToFile(String key, String value) {
    Map<String, String> content = {key: value};
      Map<dynamic, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));

    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists)
        this.setState(
                () => fileContent = json.decode(jsonFile.readAsStringSync()));
      sEmail = fileContent['user'];
      sOldPass = fileContent['pass'];
      print(sOldPass);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Theme(data: ThemeData(
          primaryColor: greenPrime,
          primaryColorDark: greenPrime,
          scaffoldBackgroundColor: Color.fromRGBO(34, 34, 34, 1.0),
          backgroundColor: Color.fromRGBO(34, 34, 34, 1.0),
          brightness: Brightness.dark,
          accentColor: greenPrime,
          canvasColor: greenPrime,

      ),
        child: Scaffold(
          appBar: appBar(),
          body: form(),
    ));
  }
}
