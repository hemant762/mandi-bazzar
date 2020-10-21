
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
    print(decrypt(response.body));
    return response;
  }


  dynamic getBody(type){
    switch (type){
      case getSuperProductsPost:
        return <String, String>{
          type : encrypt(access_key),
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
    }
  }

}