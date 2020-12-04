//
//import 'dart:convert';
//
//import 'package:adaptive_dialog/adaptive_dialog.dart';
//import 'package:custom_radio_grouped_button/CustomButtons/ButtonTextStyle.dart';
//import 'package:custom_radio_grouped_button/CustomButtons/CustomRadioButton.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_styled_toast/flutter_styled_toast.dart';
//import 'package:http/http.dart';
//import 'package:responsive_flutter_ui/Dialog/dialog_helpers.dart';
//import 'package:responsive_flutter_ui/Encryption/enc.dart';
//import 'package:responsive_flutter_ui/components/rounded_button.dart';
//import 'package:responsive_flutter_ui/components/text_field_container.dart';
//import 'package:responsive_flutter_ui/models/Product.dart';
//import 'package:responsive_flutter_ui/services/http_post.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:shimmer/shimmer.dart';
//import '../../constants.dart';
//import 'package:js/js.dart';
//import 'package:responsive_flutter_ui/services/locationJs.dart';
//
//class CheckoutWeb extends StatefulWidget {
//  @override
//  _CheckoutState createState() => _CheckoutState();
//}
//
//class _CheckoutState extends State<CheckoutWeb> {
//
//  BuildContext ctx;
//  final _addressController = TextEditingController();
//  final _numberController = TextEditingController();
//  String payment_method = "";
//  List<Product> products_list = [];
//  bool _loading = true;
//  int sbtotal = 0;
//  int delivery_charge = 30;
//  bool isLocationSet = false;
//  GeolocationPosition _currentPosition;
//
//  success(pos) {
//    try {
//      _currentPosition = pos;
//      if(!isLocationSet) {
//        isLocationSet = true;
//        orderNow(context);
//      }
//    } catch (ex) {
//      print("Exception thrown : " + ex.toString());
//    }
//  }
//
//  error(error){
//    if(error.code == 1){
//      showOkAlertDialog(context: ctx,title: "Error",barrierDismissible: false,message: "Permission Denied Please allow location permission to proceed this order.");
//    }else{
//      showOkAlertDialog(context: ctx,title: "Error",barrierDismissible: false,message: "Your device or browser is not support GPS please try a diffrent device or browser");
//    }
//  }
//
//  setCurrentLocation() async{
//
//    getCurrentPosition(allowInterop((pos) => success(pos)), allowInterop((e) => error(e)));
//  }
//
//
//  Future<void> checkAddress() async{
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    _addressController.text = prefs.getString(userContactAddress) ?? "";
//    _numberController.text = prefs.getString(userContactNo) ?? "";
//  }
//
//  Future<void> getCartProducts() async{
//    try{
//      SharedPreferences preferences = await SharedPreferences.getInstance();
//      HttpPost httpPost = HttpPost(
//          type: getUserCartProductsPost,
//          context: context,
//          voids: [preferences.getString(userId) ?? "0"]
//      );
//      Response response = await httpPost.postNow();
//      Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
//      if(data["error"]){
//        showToast(data['message'],
//            context: context,
//            animation: StyledToastAnimation.slideFromBottom,
//            reverseAnimation: StyledToastAnimation.slideToBottom,
//            startOffset: Offset(0.0, 3.0),
//            reverseEndOffset: Offset(0.0, 3.0),
//            position: StyledToastPosition.bottom,
//            duration: Duration(seconds: 4),
//            //Animation duration   animDuration * 2 <= duration
//            animDuration: Duration(seconds: 1),
//            curve: Curves.elasticOut,
//            backgroundColor: Colors.red,
//            textStyle: TextStyle(color: Colors.white),
//            reverseCurve: Curves.fastOutSlowIn);
//        Navigator.pop(context);
//      }else{
//        data['products'].forEach((product) {
//          Product productData = Product(
//            img: product['image'],
//            hindiName: product['hindi_name'],
//            engName: product['english_name'],
//            heName: product["hinglish_name"],
//            description: product["description"],
//            id: int.parse(product["product_id"]),
//            quantity: int.parse(product["quantity"]) ,
//            price: int.parse(product['price']),
//            userQuantity: int.parse(product['user_quantity']),
//          );
//          sbtotal+= int.parse(product['price'])*int.parse(product['user_quantity']);
//          products_list.add(productData);
//        });
//        setState(() {
//          _loading = false;
//        });
//      }
//    }catch(e){
//      print("Error : $e");
//      Navigator.pop(context);
//      showToast('Something is wrong',
//          context: context,
//          animation: StyledToastAnimation.slideFromBottom,
//          reverseAnimation: StyledToastAnimation.slideToBottom,
//          startOffset: Offset(0.0, 3.0),
//          reverseEndOffset: Offset(0.0, 3.0),
//          position: StyledToastPosition.bottom,
//          duration: Duration(seconds: 4),
//          //Animation duration   animDuration * 2 <= duration
//          animDuration: Duration(seconds: 1),
//          curve: Curves.elasticOut,
//          backgroundColor: Colors.red,
//          textStyle: TextStyle(color: Colors.white),
//          reverseCurve: Curves.fastOutSlowIn);
//    }
//  }
//
//  void orderNow(ctx) async{
//
//    print(_currentPosition.coords.latitude);
//    print(_currentPosition.coords.longitude);
//
//    DialogHelper.loadingDialog(ctx);
//    switch(payment_method){
//      case "cod":
//        SharedPreferences preferences = await SharedPreferences.getInstance();
////        HttpPost httpPost = HttpPost(
////            type: placeOrder,
////            context: context,
////            voids: [preferences.getString("id") ?? ""]
////        );
//        break;
//      case "paytm":
//        break;
//      case "upi":
//        break;
//    }
//    Navigator.of(ctx).pop();
//  }
//
//
//
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
//    checkAddress();
//    getCartProducts();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    ctx = context;
//    return Scaffold(
//      backgroundColor: Colors.white,
//      body: SafeArea(
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: [
//            Stack(
//              children: [
//                Row(
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  children: [
//                    Expanded(
//                      child: Padding(
//                        padding: const EdgeInsets.only(top: 18),
//                        child: Text("Checkout",
//                          textAlign: TextAlign.center,
//                          style: TextStyle(
//                            fontSize: 19,
//                            fontWeight: FontWeight.w500,
//                          ),),
//                      ),
//                    )
//                  ],
//                ),
//                Padding(
//                  padding: const EdgeInsets.only(left: 8,top: 8),
//                  child: IconButton(
//                    icon: Icon(
//                      Icons.close,
//                      size: 30,
//                    ),
//                    onPressed: () {
//                      if (Navigator.canPop(context)) {
//                        Navigator.pop(context);
//                      } else {
//                        SystemNavigator.pop();
//                      }
//                    },
//                  ),
//                ),
//              ],
//            ),
//            Divider(),
//
//            Expanded(
//              child: SingleChildScrollView(
//                child: Column(
//                  children: [
//
//                    _loading
//                        ?
//                    Container(
//                      child: Column(
//                        children: [
//                          kIsWeb ?
//                          Container(
//                            child: Padding(
//                              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
//                              child: Container(
//                                height: 205,
//                                decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.circular(8.0),
//                                  color: kShimmerColor,
//                                ),
//                              ),
//                            ),
//                          ) :
//                          Shimmer.fromColors(
//                            child: Padding(
//                              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
//                              child: Container(
//                                height: 205,
//                                decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.circular(8.0),
//                                  color: Colors.white,
//                                ),
//                              ),
//                            ),
//                            baseColor: kShimmerColor,
//                            highlightColor: Colors.grey[100],
//                            period: Duration(seconds: 3),
//                          ),
//                        ],
//                      ),
//                    )
//                        :
//                    Container(
//                        child : Column(
//                          children: [
//                            SizedBox(height: 10,),
//                            Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: Row(
//                                children: [
//                                  SizedBox(width: 15,),
//                                  Expanded(flex:1,child: Text("Total Items",textAlign: TextAlign.center,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400),)),
//                                  Expanded(flex:1,child: Text("${products_list.length}",textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold),)),
//                                  SizedBox(width: 15,),
//                                ],
//                              ),
//                            ),
//                            SizedBox(height: 10,),
//                            Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: Row(
//                                children: [
//                                  SizedBox(width: 15,),
//                                  Expanded(flex:1,child: Text("SubTotal",textAlign: TextAlign.center,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400),)),
//                                  Expanded(flex:1,child: Text("$rupee $sbtotal",textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold),)),
//                                  SizedBox(width: 15,),
//                                ],
//                              ),
//                            ),
//
//                            SizedBox(height: 10,),
//                            Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: Row(
//                                children: [
//                                  SizedBox(width: 15,),
//                                  Expanded(flex:1,child: Text("Delivery Charge",textAlign: TextAlign.center,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400),)),
//                                  Expanded(flex:1,child: Text("$rupee $delivery_charge",textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold),)),
//                                  SizedBox(width: 15,),
//                                ],
//                              ),
//                            ),
//                            SizedBox(height: 5,),
//                            Divider(),
//                            SizedBox(height: 5,),
//                            Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: Row(
//                                children: [
//                                  SizedBox(width: 15,),
//                                  Expanded(flex:1,child: Text("Total Charge",textAlign: TextAlign.center,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)),
//                                  Expanded(flex:1,child: Text("$rupee ${sbtotal+delivery_charge}",textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold),)),
//                                  SizedBox(width: 15,),
//                                ],
//                              ),
//                            ),
//                          ],
//                        )
//                    ),
//                    SizedBox(height: 5,),
//                    Divider(),
//                    SizedBox(height: 5,),
//                    Padding(
//                      padding: const EdgeInsets.only(left: 20,top: 10),
//                      child: Text("Delivery Address",style: TextStyle(
//                          fontSize: 16,
//                          fontWeight: FontWeight.w600
//                      ),),
//                    ),
//                    SizedBox(height: 10,),
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: [
//                        TextFieldContainer(
//                          minHeight:120,
//                          child: TextField(
//                            keyboardType: TextInputType.multiline,
//                            maxLength: null,
//                            maxLines: null,
//                            controller: _addressController,
//                            cursorColor: kPrimaryColor,
//                            decoration: InputDecoration(
//                              icon: Icon(
//                                Icons.location_on,
//                                color: kPrimaryColor,
//                              ),
//                              hintText: "Your Address",
//                              border: InputBorder.none,
//                            ),
//
//                          ),
//                        ),
//                      ],
//                    ),
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: [
//                        TextFieldContainer(
//                          child: TextField(
//                            keyboardType: TextInputType.number,
//                            controller: _numberController,
//                            cursorColor: kPrimaryColor,
//                            decoration: InputDecoration(
//                              icon: Icon(
//                                Icons.phone,
//                                color: kPrimaryColor,
//                              ),
//                              hintText: "Contact Number",
//                              border: InputBorder.none,
//                            ),
//
//                          ),
//                        ),
//                      ],
//                    ),
//                    SizedBox(height: 5,),
//                    Divider(),
//                    SizedBox(height: 5,),
//                    Padding(
//                      padding: const EdgeInsets.only(left: 20,top: 10),
//                      child: Text("Payment Method",style: TextStyle(
//                          fontSize: 16,
//                          fontWeight: FontWeight.w600
//                      ),),
//                    ),
//                    SizedBox(height: 15,),
//                    CustomRadioButton(
//                      elevation: 0,
//                      absoluteZeroSpacing: false,
//                      unSelectedColor: Colors.white,
//                      padding: 5,
//                      enableButtonWrap: true,
//                      buttonLables: [
//                        'COD',
//                        'Paytm',
//                        'UPI',
//                      ],
//                      buttonValues: [
//                        "cod",
//                        "paytm",
//                        "upi",
//                      ],
//                      buttonTextStyle: ButtonTextStyle(
//                          selectedColor: Colors.white,
//                          unSelectedColor: kPrimaryColor,
//                          textStyle: TextStyle(fontSize: 16)),
//                      radioButtonValue: (value) {
//                        payment_method = value;
//                      },
//                      selectedColor: kPrimaryColor,
//                    ),
//
//                    SizedBox(height: 5,),
//                    Divider(),
//                    SizedBox(height: 10,),
//                    RoundedButton(
//                      text: "Proceed To Pay",
//                      press: (){
//                        if(_addressController.text.trim().length == 0){
//                          showToast('Enter Valid Address',
//                              context: context,
//                              animation: StyledToastAnimation.slideFromBottom,
//                              reverseAnimation: StyledToastAnimation.slideToBottom,
//                              startOffset: Offset(0.0, 3.0),
//                              reverseEndOffset: Offset(0.0, 3.0),
//                              position: StyledToastPosition.bottom,
//                              duration: Duration(seconds: 4),
//                              //Animation duration   animDuration * 2 <= duration
//                              animDuration: Duration(seconds: 1),
//                              curve: Curves.elasticOut,
//                              backgroundColor: Colors.red,
//                              textStyle: TextStyle(color: Colors.white),
//                              reverseCurve: Curves.fastOutSlowIn);
//                        }else if(_numberController.text.trim().length < 10){
//                          showToast('Enter Valid Phone No.',
//                              context: context,
//                              animation: StyledToastAnimation.slideFromBottom,
//                              reverseAnimation: StyledToastAnimation.slideToBottom,
//                              startOffset: Offset(0.0, 3.0),
//                              reverseEndOffset: Offset(0.0, 3.0),
//                              position: StyledToastPosition.bottom,
//                              duration: Duration(seconds: 4),
//                              //Animation duration   animDuration * 2 <= duration
//                              animDuration: Duration(seconds: 1),
//                              curve: Curves.elasticOut,
//                              backgroundColor: Colors.red,
//                              textStyle: TextStyle(color: Colors.white),
//                              reverseCurve: Curves.fastOutSlowIn);
//                        }else if(payment_method.length == 0){
//                          showToast('Select Payment Method',
//                              context: context,
//                              animation: StyledToastAnimation.slideFromBottom,
//                              reverseAnimation: StyledToastAnimation.slideToBottom,
//                              startOffset: Offset(0.0, 3.0),
//                              reverseEndOffset: Offset(0.0, 3.0),
//                              position: StyledToastPosition.bottom,
//                              duration: Duration(seconds: 4),
//                              //Animation duration   animDuration * 2 <= duration
//                              animDuration: Duration(seconds: 1),
//                              curve: Curves.elasticOut,
//                              backgroundColor: Colors.red,
//                              textStyle: TextStyle(color: Colors.white),
//                              reverseCurve: Curves.fastOutSlowIn);
//                        }else if(_loading){
//                          showToast('Pleas Wait',
//                              context: context,
//                              animation: StyledToastAnimation.slideFromBottom,
//                              reverseAnimation: StyledToastAnimation.slideToBottom,
//                              startOffset: Offset(0.0, 3.0),
//                              reverseEndOffset: Offset(0.0, 3.0),
//                              position: StyledToastPosition.bottom,
//                              duration: Duration(seconds: 4),
//                              //Animation duration   animDuration * 2 <= duration
//                              animDuration: Duration(seconds: 1),
//                              curve: Curves.elasticOut,
//                              backgroundColor: Colors.amber,
//                              textStyle: TextStyle(color: Colors.white),
//                              reverseCurve: Curves.fastOutSlowIn);
//                        }
//                        else if(!isLocationSet){
//                          setCurrentLocation();
//                        }
//                        else{
//                          orderNow(context);
//                        }
//                      },
//                    ),
//                  ],
//                ),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//}
