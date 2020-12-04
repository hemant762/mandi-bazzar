import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart';
import 'package:responsive_flutter_ui/Encryption/enc.dart';
import 'package:responsive_flutter_ui/components/title_text.dart';
import 'package:responsive_flutter_ui/models/Product.dart';
import 'package:responsive_flutter_ui/screens/home/components/product_card.dart';
import 'package:responsive_flutter_ui/screens/product_detail/details_screen.dart';
import 'package:responsive_flutter_ui/services/http_post.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants.dart';
import '../../../size_config.dart';
import 'categories.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  List<Product> products_list = [];
  List<Product> top_products_list = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isLoadingTop = true;
  bool more_data_end = false;
  int default_load = 12;
  ScrollController _scrollController;

  Future<void> initView() async{

    HttpPost httpPost = HttpPost(
      voids: ['0'],
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

          if(data['products'].length < default_load){
            more_data_end = true;
          } else{
            more_data_end = false;
          }

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

  Future<void> loadMoreProducts() async{
    HttpPost httpPost = HttpPost(
        voids: [products_list.length.toString()],
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

          if(data['products'].length < default_load){
            more_data_end = true;
          }else{
            more_data_end = false;
          }

          setState(() {
            _isLoadingMore = false;
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


  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent-40 && !_scrollController.position.outOfRange) {
      print('$more_data_end amd $_isLoadingMore');
      if(!more_data_end && !_isLoadingMore && !_isLoading){
        print("called");
        setState(() {
          _isLoadingMore = true;
        });
        loadMoreProducts();
      }else{
        print("not called");
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initView();
    initTopView();
    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    // It enables scrolling
    return RefreshIndicator(
      backgroundColor: Colors.white,
        onRefresh: () async  {
          setState(() {
            initView();
            initTopView();
            _isLoading = true;
            _isLoadingTop = true;
            _isLoadingMore = false;
            more_data_end = false;

          });
        },
      child: SingleChildScrollView(
        controller: _scrollController,
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
              _isLoading ?
              Padding(
                  padding: EdgeInsets.all(defaultSize * 2), //20
                  child: GridView.builder(
                    // We just turn off grid view scrolling
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    // just for demo
                    itemCount: 12,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      SizeConfig.orientation == Orientation.portrait ? 2 : 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.660,
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
              Padding(
                padding: EdgeInsets.all(defaultSize * 2), //20
                child: GridView.builder(

                  // We just turn off grid view scrolling
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  // just for demo
                  itemCount: products_list.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                    SizeConfig.orientation == Orientation.portrait ? 2 : 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.660,
                  ),
                  itemBuilder: (context, index) => ProductCard(
                      product: products_list[index],
                      press: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                product: products_list[index],
                              ),
                            ));
                      }),
                ),
              ),

              !_isLoadingMore ? Center(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("No More Products"),
              ),) : Center(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
              )),

            ],
          ),
        ),
      ),
    );
  }
}
