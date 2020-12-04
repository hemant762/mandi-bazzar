import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:responsive_flutter_ui/Dialog/dialog_helpers.dart';
import 'package:responsive_flutter_ui/Encryption/enc.dart';
import 'package:responsive_flutter_ui/components/rounded_button.dart';
import 'package:responsive_flutter_ui/components/rounded_input_field.dart';
import 'package:responsive_flutter_ui/services/http_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../../constants.dart';
import '../home/home_screen.dart';

class OtpVerifyWeb extends StatefulWidget {


  final ConfirmationResult confirmationResult;
  final String phone_number;
  final String password;


  const OtpVerifyWeb({
    Key key,
    this.confirmationResult,
    this.phone_number,
    this.password,
  }) : super(key: key);


  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerifyWeb> {

  final _otpController = TextEditingController();


  Future<bool> postuserData(phone_number,password) async{
    try{
      HttpPost httpPost = HttpPost(context: context,type: registerUserPost,voids: [phone_number,password,"none"]);
      Response response = await httpPost.postNow();
      Map<String,dynamic> data = jsonDecode(decrypt(response.body));
      if(data["error"]){
        showToast(data['message'],
            context: context,
            animation: StyledToastAnimation.slideFromBottom,
            reverseAnimation: StyledToastAnimation.slideToBottom,
            startOffset: Offset(0.0, 3.0),
            reverseEndOffset: Offset(0.0, 3.0),
            position: StyledToastPosition.bottom,
            duration: Duration(seconds: 4),
            //Animation duration   animDuration * 2 <= duration
            animDuration: Duration(seconds: 1),
            curve: Curves.elasticOut,
            backgroundColor: Colors.red,
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);
        return false;
      }else{

        SharedPreferences prefs = await SharedPreferences.getInstance();
        Map<dynamic,dynamic> row = jsonDecode(data["data"]);

        prefs.setBool(isUserLogin, true);
        prefs.setString(userId,row["id"]);
        prefs.setString(userPhone,row["user_phone"]);
        prefs.setString(userPassword,row["user_password"]);
        return true;
      }
    }catch(e){
      print("Error Main : $e");
      showToast("Something Is Wrong",
          context: context,
          animation: StyledToastAnimation.slideFromBottom,
          reverseAnimation: StyledToastAnimation.slideToBottom,
          startOffset: Offset(0.0, 3.0),
          reverseEndOffset: Offset(0.0, 3.0),
          position: StyledToastPosition.bottom,
          duration: Duration(seconds: 4),
          //Animation duration   animDuration * 2 <= duration
          animDuration: Duration(seconds: 1),
          curve: Curves.elasticOut,
          backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white),
          reverseCurve: Curves.fastOutSlowIn);
      return false;
    }
  }

  Future<void> signUpUser() async{
    String code = _otpController.text.toString().trim();
    try{

      UserCredential result = await widget.confirmationResult.confirm(code);

      if( result.user != null){

        showToast("Otp Verified",
            context: context,
            animation: StyledToastAnimation.slideFromBottom,
            reverseAnimation: StyledToastAnimation.slideToBottom,
            startOffset: Offset(0.0, 3.0),
            reverseEndOffset: Offset(0.0, 3.0),
            position: StyledToastPosition.bottom,
            duration: Duration(seconds: 4),
            //Animation duration   animDuration * 2 <= duration
            animDuration: Duration(seconds: 1),
            curve: Curves.elasticOut,
            backgroundColor: Colors.green,
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);

        bool isDataPosted = await postuserData(widget.phone_number, widget.password);
        if(isDataPosted){
          Navigator.of(context).pop();
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(
                builder: (context) {
                  return HomeScreen();
                },
              ),
                  (route) => false
          );
        }else{
          Navigator.of(context).pop();
        }
      }else{
        showToast("Invalid Otp",
            context: context,
            animation: StyledToastAnimation.slideFromBottom,
            reverseAnimation: StyledToastAnimation.slideToBottom,
            startOffset: Offset(0.0, 3.0),
            reverseEndOffset: Offset(0.0, 3.0),
            position: StyledToastPosition.bottom,
            duration: Duration(seconds: 4),
            //Animation duration   animDuration * 2 <= duration
            animDuration: Duration(seconds: 1),
            curve: Curves.elasticOut,
            backgroundColor: Colors.red,
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);
        Navigator.of(context).pop();
      }
    }catch(e){
      print("Error : $e");
      showToast("Something Is Wrong",
          context: context,
          animation: StyledToastAnimation.slideFromBottom,
          reverseAnimation: StyledToastAnimation.slideToBottom,
          startOffset: Offset(0.0, 3.0),
          reverseEndOffset: Offset(0.0, 3.0),
          position: StyledToastPosition.bottom,
          duration: Duration(seconds: 4),
          //Animation duration   animDuration * 2 <= duration
          animDuration: Duration(seconds: 1),
          curve: Curves.elasticOut,
          backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white),
          reverseCurve: Curves.fastOutSlowIn);
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 100,),
              Text(
                "Enter Otp",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.05),
              WebsafeSvg.asset(
                "assets/icons/shop_icon3.svg",
                height: size.height * 0.35,
              ),
              SizedBox(height: size.height * 0.05),

              Padding(
                padding: EdgeInsets.fromLTRB(50,0,50,0),
                child: Text(
                  "Otp has been send to your Mobile Number +91"+widget.phone_number,
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: size.height * 0.03),

              RoundedInputField(
                hintText: "Enter Otp",
                controller: _otpController,
                type: TextInputType.number,
                icon: Icons.verified_user,
                onChanged: (value) {},
              ),

              RoundedButton(
                text: "Signup",
                press: () {
                  if(_otpController.text.toString().trim().length != 6){
                    showToast("Enter 6 Digit Otp",
                        context: context,
                        animation: StyledToastAnimation.slideFromBottom,
                        reverseAnimation: StyledToastAnimation.slideToBottom,
                        startOffset: Offset(0.0, 3.0),
                        reverseEndOffset: Offset(0.0, 3.0),
                        position: StyledToastPosition.bottom,
                        duration: Duration(seconds: 4),
                        //Animation duration   animDuration * 2 <= duration
                        animDuration: Duration(seconds: 1),
                        curve: Curves.elasticOut,
                        backgroundColor: Colors.red,
                        textStyle: TextStyle(color: Colors.white),
                        reverseCurve: Curves.fastOutSlowIn);
                  }else{
                    DialogHelper.loadingDialog(context);
                    signUpUser();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
