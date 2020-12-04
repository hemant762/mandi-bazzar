
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:responsive_flutter_ui/Encryption/enc.dart';

import '../constants.dart';

class HttpPost{

  BuildContext context;
  String type;
  List<String> voids;

  HttpPost({this.context,this.type,this.voids,});

  Future<Response> postNow() async{
    Response response =  await post(
      "https://softbeta.in/mandi/api/api.php",
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: getBody(type),
      encoding: Encoding.getByName("utf-8"),
    );
    print(response.body);
    print(decrypt(response.body));
//    print(getBody(type));
    return response;
  }


  dynamic getBody(type){
    switch (type){
      case getSuperProductsPost:
        return <String, String>{
          type : encrypt(access_key),
          'i_have':encrypt(voids[0])
        };
        break;
      case getSuperTopProductPost:
        return <String, String>{
          type : encrypt(access_key),
        };
        break;
      case isNumberRegisterPost:
        return <String, String>{
          type : encrypt(access_key),
          userPhone : encrypt(voids[0]),
        };
        break;
      case registerUserPost:
        return <String, String>{
          type : encrypt(access_key),
          userPhone : encrypt(voids[0]),
          userPassword : encrypt(voids[1]),
          userNotiKey : encrypt(voids[2])
        };
        break;
      case loginUserPost:
        return <String, String>{
          type : encrypt(access_key),
          userPhone : encrypt(voids[0]),
          userPassword : encrypt(voids[1]),
        };
        break;
      case forgetPasswordPost:
        return <String, String>{
          type : encrypt(access_key),
          userPhone : encrypt(voids[0]),
          userPassword : encrypt(voids[1]),
        };
        break;
      case addProductToCartPost:
        return <String, String>{
          type : encrypt(access_key),
          userId : encrypt(voids[0]),
          productId : encrypt(voids[1]),
          'quantity' : encrypt(voids[2]),
        };
        break;
      case saveAddressPost:
        return <String, String>{
          type : encrypt(access_key),
          userContactNo : encrypt(voids[2]),
          userContactAddress : encrypt(voids[1]),
          userId : encrypt(voids[0]),
        };
        break;
      case getUserCartProductsPost:
        return <String, String>{
          type : encrypt(access_key),
          userId : encrypt(voids[0]),
        };
        break;
      case cartProductMinusPost:
        return <String, String>{
          type : encrypt(access_key),
          userId : encrypt(voids[0]),
          productId : encrypt(voids[1]),
        };
        break;
      case cartProductPlusPost:
        return <String, String>{
          type : encrypt(access_key),
          userId : encrypt(voids[0]),
          productId : encrypt(voids[1]),
        };
        break;
      case cartProductDeletePost:
        return <String, String>{
          type : encrypt(access_key),
          userId : encrypt(voids[0]),
          productId : encrypt(voids[1]),
        };
        break;
      case getSearchProductsPost:
        return <String, String>{
          type : encrypt(access_key),
          'i_have':encrypt(voids[0]),
          'search_query':encrypt(voids[1]),
        };
        break;
      case getCheckoutDetailsPost:
        return <String, String>{
          type : encrypt(access_key),
          userId : encrypt(voids[0]),
          userLat : encrypt(voids[1]),
          userLng : encrypt(voids[2]),
        };
        break;
      case placeOrderPost:
        return <String, String>{
          type : encrypt(access_key),
          userId : encrypt(voids[0]),
          'shop_id' : encrypt(voids[1]),
          'address' : encrypt(voids[2]),
          'amount' : encrypt(voids[3]),
          'payment_status' : encrypt(voids[4]),
          'payment_type' : encrypt(voids[5]),
          'payment_id' : encrypt(voids[6]),
        };
        break;
      case getMyOrdersPost:
        return <String, String>{
          type : encrypt(access_key),
          userId : encrypt(voids[0]),
        };
        break;
      case getPaytmToken:
        return <String, String>{
          type : encrypt(access_key),
          'orderId' : encrypt(voids[0]),
          userId : encrypt(voids[1]),
          "amount" : encrypt(voids[2]),
        };
    }
  }

}