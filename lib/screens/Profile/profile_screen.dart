import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:responsive_flutter_ui/Dialog/dialog_helpers.dart';
import 'package:responsive_flutter_ui/Encryption/enc.dart';
import 'package:responsive_flutter_ui/components/rounded_button.dart';
import 'package:responsive_flutter_ui/components/text_field_container.dart';
import 'package:responsive_flutter_ui/screens/cart/cart.dart';
import 'package:responsive_flutter_ui/screens/myorders/my_orders.dart';
import 'package:responsive_flutter_ui/services/http_post.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../../constants.dart';

class MyProfile extends StatefulWidget {


  const MyProfile({Key key}) : super(key: key);



  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {

  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  String user_number;

  Future<void> saveAddress() async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      HttpPost httpPost = HttpPost(context: context,type: saveAddressPost,voids: [prefs.getString(userId) ?? "0",_addressController.text.trim(),_numberController.text.trim()]);
      Response response = await httpPost.postNow();
      Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
      if(data["error"]){
        showToast(data["message"],
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
      }else{
        Map<dynamic,dynamic> row = jsonDecode(data["data"]);
        prefs.setString(userContactAddress,row["user_address"]);
        prefs.setString(userContactNo,row["user_contact"]);
        showToast(data["message"],
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
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }

    }catch(e){
      print("Error : $e");
      showToast("Something is wrong",
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

  Future<void> checkAddress() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _addressController.text = prefs.getString(userContactAddress) ?? "";
    _numberController.text = prefs.getString(userContactNo) ?? "";
  }

  void _addAddress(BuildContext context){
    _addressController.text = "";
    _numberController.text = "";
    checkAddress();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0),topRight: Radius.circular(25.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Text("Add Address",style: TextStyle(fontSize: 18),),
                SizedBox(height: 20,),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      children: [
                        TextFieldContainer(
                          minHeight:120,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLength: null,
                            maxLines: null,
                            controller: _addressController,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.location_on,
                                color: kPrimaryColor,
                              ),
                              hintText: "Your Address",
                              border: InputBorder.none,
                            ),

                          ),
                        ),
                        TextFieldContainer(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _numberController,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.phone,
                                color: kPrimaryColor,
                              ),
                              hintText: "Contact Number",
                              border: InputBorder.none,
                            ),

                          ),
                        ),
                        RoundedButton(
                          text: "Save Address",
                          press: () {
                            if (_addressController.text.toString().trim().length == 0){
                              showToast("Enter Valid Address",
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
                              if (_numberController.text.toString().trim().length != 10) {
                                showToast("Enter Valid Contact Detail",
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
                                saveAddress();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<void> init() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    user_number = preferences.getString(userPhone) ?? "Loading...";
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text("My Profile",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8,top: 8),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 30,
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                    ),
                  ),
                ],
              ),



              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      SizedBox(
                        height: 25.0,
                      ),

                      Center(
                        child: Image.asset("assets/boy.png",height: 90,),
                      ),

                      SizedBox(height: 10.0,),

                      Center(
                        child: Text(
                          "Welcome",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 13.0
                          ),
                        ),
                      ),

                      SizedBox(height: 1.0,),

                      Center(
                        child: Text(
                          "+91 "+user_number,
                          style: TextStyle(
                              fontSize: 17.0
                          ),
                        ),
                      ),

                      SizedBox(height: 20.0,),



                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Divider(
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 20.0,),


                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                        child: GestureDetector(

                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Cart()));
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0) //                 <--- border radius here
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                              child: Row(
                                children: [

                                  kIsWeb ?
                                  WebsafeSvg.asset(
                                    "assets/svg/cart.svg",
                                    height: 40,
                                    width: 40,
                                  ) :
                                  SvgPicture.asset(
                                    "assets/svg/cart.svg",
                                    height: 40,
                                    width: 40,
                                  ),

                                  SizedBox(width: 10,),

                                  Expanded(
                                    child: Text("Your Cart",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                      ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                        child: GestureDetector(

                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyOrders()));
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0) //                 <--- border radius here
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                              child: Row(
                                children: [

                                  kIsWeb ?
                                  WebsafeSvg.asset(
                                    "assets/svg/shopping_bag.svg",
                                    height: 40,
                                    width: 40,
                                  ) :
                                  SvgPicture.asset(
                                    "assets/svg/shopping_bag.svg",
                                    height: 40,
                                    width: 40,
                                  ),

                                  SizedBox(width: 10,),

                                  Expanded(
                                    child: Text("Your Order History",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                      ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                        child: GestureDetector(

                          onTap: () {
                            _addAddress(context);
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0) //                 <--- border radius here
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                              child: Row(
                                children: [

                                  kIsWeb ?
                                  WebsafeSvg.asset(
                                    "assets/svg/map.svg",
                                    height: 40,
                                    width: 40,
                                  ) :

                                  SvgPicture.asset(
                                    "assets/svg/map.svg",
                                    height: 40,
                                    width: 40,
                                  ),

                                  SizedBox(width: 10,),

                                  Expanded(
                                    child: Text("Add Default Address",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                      ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),





            ],
          ),
        ),
      ),
    );
  }
}
