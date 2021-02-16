import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_flutter_ui/models/Product.dart';

import '../../../size_config.dart';
import 'counter_with_fav.dart';
import 'product_description.dart';
import 'product_info.dart';

class Body extends StatefulWidget {
  final Product product;

  const Body({Key key, this.product}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        height: SizeConfig.orientation == Orientation.landscape
            ? SizeConfig.screenWidth
            : SizeConfig.screenHeight-AppBar().preferredSize.height,
        child: SingleChildScrollView(
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Hero(
                        tag: widget.product.id,
                        child : CachedNetworkImage(
                          placeholder: (context, url) => Image.asset("assets/spinner.gif"),
                          imageUrl: widget.product.img,
                          height: defaultSize * 25.8, //378
                          width: defaultSize * 25.4,
                        )
                      ),
                    ],
                  ),
                  ProductInfo(product: widget.product),
                ],
              ),
              ProductDescription(
                product: widget.product,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
