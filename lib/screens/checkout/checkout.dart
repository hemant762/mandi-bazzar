
import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:custom_radio_grouped_button/CustomButtons/ButtonTextStyle.dart';
import 'package:custom_radio_grouped_button/CustomButtons/CustomRadioButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart';
import 'package:paytm/paytm.dart';
import 'package:responsive_flutter_ui/Dialog/dialog_helpers.dart';
import 'package:responsive_flutter_ui/Encryption/enc.dart';
import 'package:responsive_flutter_ui/components/rounded_button.dart';
import 'package:responsive_flutter_ui/components/text_field_container.dart';
import 'package:responsive_flutter_ui/screens/home/home_screen.dart';
import 'package:responsive_flutter_ui/services/http_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import '../../constants.dart';
import 'package:flutter/services.dart';

class Checkout extends StatefulWidget {

  final Position currentPosition;

  const Checkout({Key key, this.currentPosition}) : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {

  BuildContext ctx;
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  String payment_method = "";
  bool _loading = true;
  int sbtotal = 0;
  int total_item = 0;
  int delivery_charge = 20;
  String shop_id;
//  bool isLocationSet = false;
//  Position _currentPosition;
//  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

//  success(pos) {
//    try {
//      print(pos.coords.latitude);
//      print(pos.coords.longitude);
//    } catch (ex) {
//      print("Exception thrown : " + ex.toString());
//    }
//  }

//  error(error){
//    if(error.code == 1){
//      showOkAlertDialog(context: ctx,title: "Error",barrierDismissible: false,message: "Permission Denied Please allow location permission to proceed this order.");
//    }else{
//      showOkAlertDialog(context: ctx,title: "Error",barrierDismissible: false,message: "Your device or browser is not support GPS please try a diffrent device or browser");
//    }
//  }

//  setCurrentLocation() async{
//
//    if(await geolocator.isLocationServiceEnabled()){
//      await geolocator
//          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
//          .then((Position position) {
//            setState(() {
//              _currentPosition = position;
//              isLocationSet = true;
//              orderNow(context);
//            });
//          }).catchError((e) {
//            print("error");
//            print(e);
//          });
//      }
//      else{
//        showOkAlertDialog(context: context,title: "Turn On Location",message: "Your device location or gps is off. Please turn it on and try again.",barrierDismissible: false);
//      }
//  }


  Future<void> checkAddress() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _addressController.text = prefs.getString(userContactAddress) ?? "";
    _numberController.text = prefs.getString(userContactNo) ?? "";
  }

  Future<void> getCartProducts() async{
    try{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      HttpPost httpPost = HttpPost(
          type: getCheckoutDetailsPost,
          context: context,
          voids: [preferences.getString(userId) ?? "0",widget.currentPosition.latitude.toString(),widget.currentPosition.longitude.toString()]
      );
      Response response = await httpPost.postNow();
      Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
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
        Navigator.pop(context);
      }else{
        sbtotal = data['sub_total'];
        total_item = data['total_item'];
        if(data['is_delivery_available']) {
          delivery_charge = data['delivery_charge'];
          shop_id = data['shop_id'];
        }else{
          var future = await showOkAlertDialog(context: context,title: "Service Not Available",message: "Delivery service is not available in your area. We will notify you when we start service in your area",barrierDismissible: false,okLabel: "Ok");
          Navigator.pop(context);
        }
        setState(() {
          _loading = false;
        });
      }
    }catch(e){
      print("Error : $e");
      Navigator.pop(context);
      showToast('Something is wrong',
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
    }
  }

  void orderNow(ctx) async{

    switch(payment_method){
      case "cod":
        DialogHelper.loadingDialog(ctx);
        SharedPreferences preferences = await SharedPreferences.getInstance();
        HttpPost httpPost = HttpPost(
            type: placeOrderPost,
            context: context,
            voids: [
              preferences.getString(userId) ?? "0"
              ,shop_id,
              _addressController.text.toString()+", "+_numberController.text.toString(),
              (sbtotal+delivery_charge).toString(),
              '0',
              payment_method,
              '0'
            ]
        );
        try{
          Response response = await httpPost.postNow();
          Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
          Navigator.of(ctx).pop();
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
          }
          else{
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
                backgroundColor: Colors.green,
                textStyle: TextStyle(color: Colors.white),
                reverseCurve: Curves.fastOutSlowIn);
            SharedPreferences preferences = await SharedPreferences.getInstance();
            await preferences.remove(cartProductCache);
            await showOkAlertDialog(context: context,title: "Order Placed Successful",message: "Your Order has been placed successful. Check our order status in your my order section.",barrierDismissible: false,okLabel: "Ok");
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder:(context) =>  HomeScreen(),
            ), (route) => false);
          }
        }
        catch(e){
          print("Error : $e");
          showToast("Please Retry",
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
          Navigator.of(ctx).pop();
        }
        break;
      case "paytm":
        DialogHelper.loadingDialog(ctx);
        SharedPreferences preferences = await SharedPreferences.getInstance();
        String orderId = DateTime.now().millisecondsSinceEpoch.toString();
        HttpPost httpPost = HttpPost(
            type: getPaytmToken,
            context: context,
            voids: [orderId,preferences.getString(userId) ?? "0",(sbtotal+delivery_charge).toString()]
        );

        try{
          Response response = await httpPost.postNow();
          Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));

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
            Navigator.of(ctx).pop();
          }
          else {
//            const platform = const MethodChannel("samples.flutter.dev/allInOne");
//            var arguments = <String, dynamic>{
//              "mid": "kJSWaw76146242379134",
//              "orderId": orderId,
//              "amount": (sbtotal+delivery_charge).toString(),
//              "txnToken":jsonDecode(data['result'])['body']['txnToken'].toString(),
//              "isStaging": true
//            };
//            Navigator.of(ctx).pop();
//            var result = await platform.invokeMethod("startTransaction", arguments);
//            print("Paytm responce : "+result.toString());

            var paytmResponse = Paytm.payWithPaytm(
                "kJSWaw76146242379134", orderId, jsonDecode(data['result'])['body']['txnToken'].toString(), (sbtotal+delivery_charge).toString(), "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId", true);

            paytmResponse.then((value) async{
              print("Paytm responce : "+value.toString());
              if(value['error'] ?? false){
                await showOkAlertDialog(context: context,title: "Payment Cancel",message: "Your payment has been canceled because of this error - ${value['errorMessage']}",barrierDismissible: false,okLabel: "Ok");
                Navigator.of(ctx).pop();
              }else{
                //paytm response
                if(value['STATUS'] == 'TXN_SUCCESS'){

                  HttpPost httpPost = HttpPost(
                      type: placeOrderPost,
                      context: context,
                      voids: [
                        preferences.getString(userId) ?? "0"
                        ,shop_id,
                        _addressController.text.toString()+", "+_numberController.text.toString(),
                        (sbtotal+delivery_charge).toString(),
                        '1',
                        payment_method+"-"+value['PAYMENTMODE'].toString()+"-"+value['GATEWAYNAME'].toString(),
                        value['TXNID'].toString()
                      ]
                  );

                  Response response = await httpPost.postNow();
                  Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
                  Navigator.of(ctx).pop();
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
                  }
                  else{
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
                        backgroundColor: Colors.green,
                        textStyle: TextStyle(color: Colors.white),
                        reverseCurve: Curves.fastOutSlowIn);
                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    await preferences.remove(cartProductCache);
                    await showOkAlertDialog(context: context,title: "Order Placed Successful",message: "Your Order has been placed successful. Check our order status in your my order section.",barrierDismissible: false,okLabel: "Ok");
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                      builder:(context) =>  HomeScreen(),
                    ), (route) => false);
                  }

                }else{
                  await showOkAlertDialog(context: context,title: "Payment Cancel",message: "${value['errorMessage'] ?? "Your payment hase been canceled please retry."}",barrierDismissible: false,okLabel: "Ok");
                  Navigator.of(ctx).pop();
                }
              }
            });

          }

        }catch(e){
          print("Error : $e");
          showToast("Please Retry",
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
          Navigator.of(ctx).pop();
        }
        break;
      case "upi":
        break;
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAddress();
    getCartProducts();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                        padding: const EdgeInsets.only(top: 18),
                        child: Text("Checkout",
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
            Divider(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    _loading
                        ?
                    Container(
                      child: Column(
                        children: [
                          kIsWeb ?
                          Container(
                            color:kShimmerColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                              child: Container(
                                height: 205,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ) :
                          Shimmer.fromColors(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                              child: Container(
                                height: 205,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            baseColor: kShimmerColor,
                            highlightColor: Colors.grey[100],
                            period: Duration(seconds: 3),
                          ),
                        ],
                      ),
                    )
                        :
                    Container(
                        child : Column(
                          children: [
                            SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(width: 15,),
                                  Expanded(flex:1,child: Text("Total Items",textAlign: TextAlign.center,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400),)),
                                  Expanded(flex:1,child: Text("$total_item",textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold),)),
                                  SizedBox(width: 15,),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(width: 15,),
                                  Expanded(flex:1,child: Text("SubTotal",textAlign: TextAlign.center,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400),)),
                                  Expanded(flex:1,child: Text("$rupee $sbtotal",textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold),)),
                                  SizedBox(width: 15,),
                                ],
                              ),
                            ),

                            SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(width: 15,),
                                  Expanded(flex:1,child: Text("Delivery Charge",textAlign: TextAlign.center,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400),)),
                                  Expanded(flex:1,child: Text("$rupee $delivery_charge",textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold),)),
                                  SizedBox(width: 15,),
                                ],
                              ),
                            ),
                            SizedBox(height: 5,),
                            Divider(),
                            SizedBox(height: 5,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(width: 15,),
                                  Expanded(flex:1,child: Text("Total Charge",textAlign: TextAlign.center,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)),
                                  Expanded(flex:1,child: Text("$rupee ${sbtotal+delivery_charge}",textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold),)),
                                  SizedBox(width: 15,),
                                ],
                              ),
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 5,),
                    Divider(),
                    SizedBox(height: 5,),
                    Padding(
                      padding: const EdgeInsets.only(left: 20,top: 10),
                      child: Text("Delivery Address",style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                      ],
                    ),
                    SizedBox(height: 5,),
                    Divider(),
                    SizedBox(height: 5,),
                    Padding(
                      padding: const EdgeInsets.only(left: 20,top: 10),
                      child: Text("Payment Method",style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),),
                    ),
                    SizedBox(height: 15,),
                    CustomRadioButton(
                      elevation: 0,
                      absoluteZeroSpacing: false,
                      unSelectedColor: Colors.white,
                      padding: 5,
                      enableButtonWrap: true,
                      buttonLables: [
                        'COD',
                        'Paytm',
                      ],
                      buttonValues: [
                        "cod",
                        "paytm",
                      ],
                      buttonTextStyle: ButtonTextStyle(
                          selectedColor: Colors.white,
                          unSelectedColor: kPrimaryColor,
                          textStyle: TextStyle(fontSize: 16)),
                      radioButtonValue: (value) {
                        payment_method = value;
                      },
                      selectedColor: kPrimaryColor,
                    ),

                    SizedBox(height: 5,),
                    Divider(),
                    SizedBox(height: 10,),
                    RoundedButton(
                      text: "Proceed To Pay",
                      press: (){
                        if(_addressController.text.trim().length == 0){
                          showToast('Enter Valid Address',
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
                        }else if(_numberController.text.trim().length < 10){
                          showToast('Enter Valid Phone No.',
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
                        }else if(payment_method.length == 0){
                          showToast('Select Payment Method',
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
                              backgroundColor: Colors.amber,
                              textStyle: TextStyle(color: Colors.white),
                              reverseCurve: Curves.fastOutSlowIn);
                        }else if(_loading){
                          showToast('Pleas Wait',
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
                              backgroundColor: Colors.amber,
                              textStyle: TextStyle(color: Colors.white),
                              reverseCurve: Curves.fastOutSlowIn);
                        }
                        else{
                          orderNow(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
