import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart';
import 'package:responsive_flutter_ui/Encryption/enc.dart';
import 'package:responsive_flutter_ui/components/title_text.dart';
import 'package:responsive_flutter_ui/models/Product.dart';
import 'package:responsive_flutter_ui/services/http_post.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants.dart';
import '../../../size_config.dart';
import 'categories.dart';
import 'recommond_products.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  List<Product> products_list = [];
  List<Product> top_products_list = [];
  bool _isLoading = true;
  bool _isLoadingTop = true;

  Future<void> initView() async{
    HttpPost httpPost = HttpPost(
      voids: [],
      type: getSuperProductsPost,
      context: context
    );
    Response response = await httpPost.postNow();
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      try{
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
        }else{
          products_list.clear();
          data['products'].forEach((product) {
            Product productData = Product(
              img: product['image'],
              hindiName: product['hindi_name'],
              engName: product['english_name'],
              heName: product["hinglish_name"],
              id: int.parse(product["id"]),
              quantity: int.parse(product["quantity"]) ,
              price: int.parse(product['price']),
              description: product['description'],
              isAvailable: int.parse(product['is_available']),
            );
            products_list.add(productData);
          });

          setState(() {
            _isLoading = false;
          });
        }
      }catch(e){
        print(e);
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

      // Return list of products
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      showToast('Server Not Responding',
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

  Future<void> initTopView() async{
    HttpPost httpPost = HttpPost(
        voids: [],
        type: getSuperTopProductPost,
        context: context
    );
    Response response = await httpPost.postNow();
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      try{
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
        }else{
          top_products_list.clear();
          data['products'].forEach((product) {
            Product productData = Product(
              img: product['image'],
              hindiName: product['hindi_name'],
              engName: product['english_name'],
              heName: product["hinglish_name"],
              id: int.parse(product["id"]),
              quantity: int.parse(product["quantity"]) ,
              price: int.parse(product['price']),
              description: product['description'],
              isAvailable: int.parse(product['is_available']),
            );
            top_products_list.add(productData);
          });

          setState(() {
            _isLoadingTop = false;
          });
        }
      }catch(e){
        print(e);
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

      // Return list of products
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      showToast('Server Not Responding',
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initView();
    initTopView();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    // It enables scrolling
    return RefreshIndicator(
        onRefresh: () async  {
          setState(() {
            initView();
            initTopView();
            _isLoading = true;
            _isLoadingTop = true;
          });
        },
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(defaultSize * 2), //20
                child: TitleText(
                  title: "Top Products Of The Day",
                ),
              ),
              _isLoadingTop ?
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    4, (index) => kIsWeb ? Padding(
                    padding: EdgeInsets.all(defaultSize * 2), //20
                    child: SizedBox(
                      width: defaultSize * 20.5, //205
                      child: AspectRatio(
                        aspectRatio: 0.83,
                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.0),color: kSecondaryColor),),
                      ),
                    ),
                  ) : Shimmer.fromColors(
                    baseColor: Color(0xFFebeff2),
                    highlightColor: Colors.white,
                      child: Padding(
                      padding: EdgeInsets.all(defaultSize * 2), //20
                      child: SizedBox(
                        width: defaultSize * 20.5, //205
                        child: AspectRatio(
                          aspectRatio: 0.83,
                          child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.0),color: kSecondaryColor),),
                        ),
                      ),
                  ),
                    ),
                  ),
                ),
              )
              :
              Categories(categories: top_products_list),
              Divider(height: 5),
              Padding(
                padding: EdgeInsets.all(defaultSize * 2), //20
                child: TitleText(title: "Fresh Natural Items"),
              ),
              // Right Now product is our demo product
              _isLoading ? Padding(
                  padding: EdgeInsets.all(defaultSize * 2), //20
                  child: GridView.builder(
                    // We just turn off grid view scrolling
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    // just for demo
                    itemCount: 8,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      SizeConfig.orientation == Orientation.portrait ? 2 : 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.693,
                    ),
                    itemBuilder: (context, index) => kIsWeb ? Container(
                      width: defaultSize * 14.5, //145
                      decoration: BoxDecoration(
                        color: kSecondaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ) : Shimmer.fromColors(
                        baseColor: Color(0xFFebeff2),
                        highlightColor: Colors.white,
                        child: Container(
                          width: defaultSize * 14.5, //145
                          decoration: BoxDecoration(
                            color: kSecondaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                    ),
                  ),
                )
                  :
                  RecommandProducts(products: products_list),
            ],
          ),
        ),
      ),
    );
  }
}
