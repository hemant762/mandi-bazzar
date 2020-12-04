import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:responsive_flutter_ui/Encryption/enc.dart';
import 'package:responsive_flutter_ui/components/rounded_button.dart';
import 'package:responsive_flutter_ui/models/orderdata.dart';
import 'package:responsive_flutter_ui/services/http_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../../constants.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {

  bool isLoading = true;
  List<OrderData> products_list = [];

  String decodeStatus(String s){
    switch (s){
      case "0":
        return "Panding";
        break;
      case "1":
        return "Success";
        break;
      default:
        return "Cancel";
        break;
    }
  }


  Future<void> getMyOrders() async{
    try{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      HttpPost httpPost = HttpPost(
          type: getMyOrdersPost,
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
        products_list.clear();
        data['orders'].forEach((order) {
          OrderData orderData = OrderData(
            id : order['id'],
            address: order['address'],
            amount: order['total_amount'],
            orderStatus: decodeStatus(order['order_status']),
            paymentMethod: order['payment_type'],
            paymentStatus: order['payment_status'],
            totalItems: order['total_products'],
            date: order['date']
          );
          products_list.add(orderData);
        });
        setState(() {
          isLoading = false;
        });
      }
    }catch(e){
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
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body : SafeArea(
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
                          child: Text("Your Orders",
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

              isLoading
                  ?
              Expanded(
                child: Container(
                  color: Color(0xFFF9F9F9),
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
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
              )
                  :
              (
                  (products_list.length > 0)
                      ?
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: RefreshIndicator(
                        backgroundColor: Colors.white,
                        onRefresh: () async{
                          getMyOrders();
                          setState(() {
                            isLoading = true;
                          });
                        },
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: products_list.length,
                            itemBuilder: (context,index){
                              return OrderTile(
                                data: products_list[index],
                              );
                            }
                        ),
                      ),
                    ),
                  )
                      :
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        kIsWeb ? WebsafeSvg.asset("assets/icons/basket.svg",width: 100,height: 100,) : SvgPicture.asset("assets/icons/basket.svg",width: 100,height: 100,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                          child: Text("Yoy have not order any item yet.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black
                            ),),
                        ),


                      ],
                    ),
                  )
              )
            ],
          ),
        )

    );
  }

}

class OrderTile extends StatelessWidget{

  final OrderData data;
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  final DateFormat dateFormatNew = DateFormat().add_yMMMMEEEEd();
  OrderTile({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),

      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
//          Navigator.push(context,
//              MaterialPageRoute(
//                  builder: (ctx) => DetailsScreen(product: widget.data)
//              ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: kSecondaryColor,

                borderRadius: BorderRadius.all(
                    Radius.circular(
                        10.0) //                 <--- border radius here
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      child: Hero(
                        tag: data.id,
                        child: SvgPicture.asset(
                          'assets/icons/basket.svg',
                          width: 80,
                          height: 80,
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

                        Text(data.totalItems+" Products Order",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17.5,

                          ),),

                        SizedBox(height: 5,),

                        Row(
                          children: [
                            Text(rupee + " " +
                                data.amount,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600
                              ),),

                            SizedBox(width: 6,),

                            Text("/ "+data.paymentMethod.split('-')[0].toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600
                              ),),
                          ],
                        ),

                        SizedBox(height: 5,),

                        Row(
                          children: [
                            Text(data.orderStatus ,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent
                              ),),


                            Expanded(
                              child: Text(" On "+dateFormatNew.format(dateFormat.parse(data.date)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500
                                ),),
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
            ),
          ),
          (data.orderStatus == "Success") ?
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.done,
                    color: kShimmerColor,
                    size: 20,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10)
                  )
                ),
              )
            ],
          ) : SizedBox(),

          (data.orderStatus == "Cancel") ?
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.close,
                    color: kShimmerColor,
                    size: 20,
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10)
                    )
                ),
              )
            ],
          ) : SizedBox(),
        ],
      )

    );
  }

}
