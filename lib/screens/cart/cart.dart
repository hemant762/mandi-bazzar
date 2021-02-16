import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:responsive_flutter_ui/Dialog/dialog_helpers.dart';
import 'package:responsive_flutter_ui/Encryption/enc.dart';
import 'package:responsive_flutter_ui/components/rounded_button.dart';
import 'package:responsive_flutter_ui/constants.dart';
import 'package:responsive_flutter_ui/models/Product.dart';
import 'package:responsive_flutter_ui/screens/Tnc/tnc.dart';
import 'package:responsive_flutter_ui/screens/checkout/checkout.dart';
import 'package:responsive_flutter_ui/screens/checkout/checkout_web.dart';
import 'package:responsive_flutter_ui/screens/product_detail/details_screen.dart';
import 'package:responsive_flutter_ui/services/http_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:websafe_svg/websafe_svg.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {


  bool isLoading = true;
  List<Product> products_list = [];
  bool isLocationSet = false;
  g.Position _currentPosition;
  final g.Geolocator geolocator = g.Geolocator()..forceAndroidLocationManager;
  var location = Location();

  setCurrentLocation() async{

    if(await geolocator.isLocationServiceEnabled()){
      await geolocator
          .getCurrentPosition(desiredAccuracy: g.LocationAccuracy.best)
          .then((g.Position position) {
        setState(() {
          _currentPosition = position;
          isLocationSet = true;
          Navigator.push(context, MaterialPageRoute(builder: (ctx){
            return kIsWeb ? Checkout() : Checkout(currentPosition: _currentPosition,);
          }));
        });
      }).catchError((e) {
        print("error");
        print(e);
      });
    }
    else{

      await showOkAlertDialog(context: context,title: "Turn On Location",message: "Your device location or gps is off. Please turn it on and try again.",barrierDismissible: false);
      try{
        location.requestService();
      }catch(e){
        print("Location Error : $e");
      }
    }
  }

  Future<void> getCartProducts() async{
    try{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      HttpPost httpPost = HttpPost(
          type: getUserCartProductsPost,
          context: context,
          voids: [preferences.getString(userId) ?? "0"]
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
        setState(() {
          isLoading = false;
        });
      }else{
        data['products'].forEach((product) {
          Product productData = Product(
            img: product['image'],
            hindiName: product['hindi_name'],
            engName: product['english_name'],
            heName: product["hinglish_name"],
            description: product["description"],
            id: int.parse(product["product_id"]),
            quantity: int.parse(product["quantity"]) ,
            price: int.parse(product['price']),
            userQuantity: int.parse(product['user_quantity']),
          );
          products_list.add(productData);
        });
        setState(() {
          isLoading = false;
        });
      }
    }catch(e) {
      print("Error : $e");
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

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCartProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child :
        isLoading
            ?
            SafeArea(
          child: Container(
            color: Color(0xFFF7F7F7),
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      kIsWeb
                      ?
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: kShimmerColor,
                          ),
                        ),
                      )
                      :
                      Shimmer.fromColors(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 50,
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


                      Expanded(
                        child: ListView.builder(
                            itemCount: 6,
                            itemBuilder: (ctx, index){
                              return  Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                child: kIsWeb
                                ?
                                Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: kShimmerColor
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0) //                 <--- border radius here
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: ClipRRect(
                                            child: Container(width: 100,height: 100,color: kShimmerColor,),
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 20,),
                                              Container(width: 200,height: 20,color: kShimmerColor,),

                                              SizedBox(height: 5,),

                                              Container(width: 150,height: 20,color: kShimmerColor,),

                                              SizedBox(height: 5,),

                                              Container(width: 150,height: 20,color: kShimmerColor,),

                                              SizedBox(height: 5,),

                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                      ],
                                    )
                                )
                                :
                                Shimmer.fromColors(
                                  baseColor: kShimmerColor,
                                  highlightColor: Colors.grey[100],
                                  child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: kShimmerColor
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0) //                 <--- border radius here
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: ClipRRect(
                                              child: Container(width: 100,height: 100,color: Colors.white,),
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 20,),
                                                Container(width: 200,height: 20,color: Colors.white,),

                                                SizedBox(height: 5,),

                                                Container(width: 150,height: 20,color: Colors.white,),

                                                SizedBox(height: 5,),

                                                Container(width: 150,height: 20,color: Colors.white,),

                                                SizedBox(height: 5,),

                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                        ],
                                      )
                                  ),
                                ),
                              );
                            }
                        ),
                      ),

                    ],
                  )
              ),
            ),
          ),
        )
            :
        (
            (products_list.length > 0)
                ?
            Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 18),
                                child: Text("Your Cart",
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
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: products_list.length,
                            itemBuilder: (context,index){
                              return ProductTile(
                                data: products_list[index],
                                removeItem: (){
                                  setState(() {
                                    products_list.removeAt(index);
                                  });
                                },
                              );
                            }
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    RoundedButton(
                      text: "Proceed To Checkout",
                      press: (){
                        if(!isLocationSet){
                          setCurrentLocation();
                        }
                        else{
                          Navigator.push(context, MaterialPageRoute(builder: (ctx){
                            return kIsWeb ? Checkout() : Checkout(currentPosition: _currentPosition,);
                          }));
                        }

                      },
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
            )
                :
            Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text("Your Cart",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
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
                              color: Colors.black,
                            ),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          kIsWeb ? WebsafeSvg.asset("assets/svg/cart.svg",width: 100,height: 100,) : SvgPicture.asset("assets/svg/cart.svg",width: 100,height: 100,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                            child: Text("There is no product in cart.\nAdd products to cart and proceed",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black
                              ),),
                          ),
                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(color: Colors.black)
                              ),

                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    SizedBox(width: 15,),
                                    kIsWeb ? WebsafeSvg.asset("assets/svg/shopping_bag.svg",height: 22,width: 22,) : SvgPicture.asset("assets/svg/shopping_bag.svg",height: 22,width: 22,),
                                    SizedBox(width: 5,),
                                    Text("Add Products",style: TextStyle(color: Colors.black,fontSize: 17),),
                                    SizedBox(width: 15,),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
        )

    );
  }
}

Future<bool> productMinus(context,productId) async{
  try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    HttpPost httpPost = HttpPost(
        type: cartProductMinusPost,
        context: context,
        voids: [prefs.getString(userId) ?? "0",productId.toString()]
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
      return false;
    }else{
      prefs.remove(cartProductCache);
      await prefs.setStringList(cartProductCache,data["cart_products"].cast<String>() );
      return true;
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
    Navigator.of(context).pop();
    return false;
  }
}
Future<bool> productPlus(context,productId) async{
  try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    HttpPost httpPost = HttpPost(
        type: cartProductPlusPost,
        context: context,
        voids: [prefs.getString(userId) ?? "0",productId.toString()]
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
      return false;
    }else{
      prefs.remove(cartProductCache);
      await prefs.setStringList(cartProductCache,data["cart_products"].cast<String>() );
      return true;
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
    Navigator.of(context).pop();
    return false;
  }
}
Future<bool> productDelete(context,productId) async{
  try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    HttpPost httpPost = HttpPost(
        type: cartProductDeletePost,
        context: context,
        voids: [prefs.getString(userId) ?? "0",productId.toString()]
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
      return false;
    }else{
      prefs.remove(cartProductCache);
      await prefs.setStringList(cartProductCache,data["cart_products"].cast<String>() );
      return true;
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
    Navigator.of(context).pop();
    return false;
  }
}

class ProductTile extends StatefulWidget {

  final Product data;
  final Function removeItem;

  const ProductTile({Key key, this.data, this.removeItem}) : super(key: key);

  @override
  _ProductTileState createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
          MaterialPageRoute(
            builder: (ctx) => DetailsScreen(product: widget.data)
          ));
        },
        child: Ink(
            decoration: BoxDecoration(
              color: kSecondaryColor,

              borderRadius: BorderRadius.all(
                  Radius.circular(
                      10.0) //                 <--- border radius here
              ),
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: IconButton(onPressed: () async{
                    DialogHelper.loadingDialog(context);
                    bool res = await productDelete(context, widget.data.id);
                    Navigator.of(context).pop();
                    if (res) {
                      widget.removeItem.call();
                    }
                  },icon: Icon(Icons.delete,size: 30)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: ClipRRect(
                        child: Hero(
                          tag: widget.data.id,
                          child: FadeInImage(
                            placeholder: AssetImage("assets/spinner.gif"),
                            image: CachedNetworkImageProvider(widget.data.img),
                            width: 110,
                            height: 110,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                    ),
                    SizedBox(width: 15,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10,),

                          Text(widget.data.engName+" ("+widget.data.hindiName+")",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15.5,

                            ),),

                          SizedBox(height: 8,),

                          Row(
                            children: [
                              Text(rupee + " " +
                                  widget.data.price.toString(),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600
                                ),),

                              SizedBox(width: 6,),

                              Text("/ "+widget.data.quantity.toString()+"Kg",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                ),),
                            ],
                          ),

                          SizedBox(height: 8,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                height: 30.0,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  children: [
                                    SizedBox(width: 15,),
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: GestureDetector(
                                            onTap: () async {
                                              DialogHelper.loadingDialog(context);
                                              bool res = await productMinus(context, widget.data.id);
                                              Navigator.of(context).pop();
                                              if (res) {
                                                if (widget.data.userQuantity ==
                                                    1) {
                                                  widget.removeItem.call();
                                                } else {
                                                  setState(() {
                                                    widget.data.userQuantity = (widget.data.userQuantity) - 1;
                                                  });
                                                }
                                              }
                                            },
                                            child: Icon(
                                              Icons.remove, size: 20,
                                              color: Colors.white,)
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius: BorderRadius.circular(
                                              25)
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      widget.data.userQuantity.toString(), style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),),
                                    SizedBox(width: 10,),
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: GestureDetector(
                                            onTap: () async {
                                              DialogHelper.loadingDialog(
                                                  context);
                                              bool res = await productPlus(
                                                  context, widget.data.id);
                                              Navigator.of(context).pop();
                                              if (res) {
                                                setState(() {
                                                  widget.data.userQuantity = widget.data.userQuantity +1;
                                                });
                                              }
                                            },
                                            child: Icon(Icons.add, size: 20,
                                              color: Colors.white,)
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius: BorderRadius.circular(
                                              25)
                                      ),
                                    ),
                                    SizedBox(width: 15,),
                                  ],
                                ),
                              ),
                            ],
                          ),


                          SizedBox(height: 5,),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                  ],
                ),

              ],
            ),
        ),
      ),
    );
  }
}
