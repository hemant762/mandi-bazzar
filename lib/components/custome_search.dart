
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:responsive_flutter_ui/Encryption/enc.dart';
import 'package:responsive_flutter_ui/components/title_text.dart';
import 'package:responsive_flutter_ui/models/Product.dart';
import 'package:responsive_flutter_ui/screens/home/components/product_card.dart';
import 'package:responsive_flutter_ui/screens/product_detail/details_screen.dart';
import 'package:responsive_flutter_ui/services/http_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:websafe_svg/websafe_svg.dart';
import '../constants.dart';
import '../size_config.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';


class CustomSearch extends SearchDelegate{

  SharedPreferences preferences;
  List<String> history = [];

  CustomSearch(){
    preferences = null;
  }

  Future<void> init() async{
    if(preferences == null) {
      preferences = await SharedPreferences.getInstance();
      history = preferences.getStringList(searcHistoryChche) ?? [];
      history = history.reversed.toList();
    }
  }

  Future<void> addHistory(query) async{
    if(preferences == null) {
      preferences = await SharedPreferences.getInstance();
    }
    history = preferences.getStringList(searcHistoryChche) ?? [];
    if(!history.contains(query)) {
      if(history.length > 20){
        history = history.sublist(history.length-20,history.length);
      }
      history.add(query);
    }
    preferences.setStringList(searcHistoryChche, history);
    history = history.reversed.toList();
}


  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.black),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
      hintColor: Colors.black,
      bottomAppBarColor: kPrimaryColor,
      canvasColor: Colors.white,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }


  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    if(query.isNotEmpty){
      addHistory(query);
      return SearchResult(query: query,);
    }else{
      return Container(
        color: Colors.white,
        child: Center(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                kIsWeb ?
                WebsafeSvg.asset(
                  "assets/icons/search.svg",
                  width: 80,
                  height: 80,
                ) :
                SvgPicture.asset(
                  "assets/icons/search.svg",
                  width: 80,
                  height: 80,
                ),
                SizedBox(height: 12,),
                Text("No Search Available",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(history.isEmpty){
      init();
    }

    final suggesstionList = query.isEmpty ? history : history.where((element) => element.toLowerCase().startsWith(query.toLowerCase())).toList();

    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: suggesstionList.length,
        itemBuilder: (context,index){
          return ListTile(
            onTap: (){
              query = suggesstionList[index];
              showResults(context);
            },
            leading: Icon(Icons.history,color: Colors.black54,),
            title: RichText(
              text:TextSpan(
                text: suggesstionList[index].substring(0,query.length),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                      text: suggesstionList[index].substring(query.length),
                    style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w400,fontSize: 16,  ),
                  )
                ]
              )
            ),
          );
        }
      ),
    );
  }
}

class SearchResult extends StatefulWidget {

  final String query;

  const SearchResult({Key key, this.query}) : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  bool isLoading = true;
  List<Product> products_list = [];
  int default_load = 12;
  ScrollController _scrollController;
  bool more_data_end = false;
  bool _isLoadingMore = false;

  Future<void> getMoreSearch() async{

    HttpPost httpPost = HttpPost(
        voids: [products_list.length.toString(),widget.query],
        type: getSearchProductsPost,
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
    }
    else {
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

  Future<void> initView() async{

    HttpPost httpPost = HttpPost(
        voids: ['0',widget.query],
        type: getSearchProductsPost,
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
            isLoading = false;
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
      if(!more_data_end && !_isLoadingMore && !isLoading){
        print("called");
        setState(() {
          _isLoadingMore = true;
        });
        getMoreSearch();
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
    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          onRefresh: () async  {
            setState(() {
              initView();
              isLoading = true;
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
                  Divider(height: 5),
                  Padding(
                    padding: EdgeInsets.all(defaultSize * 2), //20
                    child: TitleText(title: "Search Result For ${widget.query}"),
                  ),
                  // Right Now product is our demo product
                  isLoading ?
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
                  ((products_list.length > 0) ? Padding(
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
                  ) :
                  Padding(
                    padding: const EdgeInsets.only(top: 200),
                    child: Container(
                      child: Center(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              kIsWeb ?
                              WebsafeSvg.asset(
                                "assets/icons/search.svg",
                                width: 80,
                                height: 80,
                              ) :
                              SvgPicture.asset(
                                "assets/icons/search.svg",
                                width: 80,
                                height: 80,
                              ),
                              SizedBox(height: 12,),
                              Text("No Search Available",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),

                  (products_list.length > 0 ) ? !_isLoadingMore ? Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("No More Products"),
                  ),) : Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  )) :
                      Container(),

                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
}