import 'package:flutter/material.dart';
import 'package:responsive_flutter_ui/models/Product.dart';

import '../../../size_config.dart';
import 'product_description.dart';
import 'product_info.dart';

class Body extends StatelessWidget {
  final Product product;

  const Body({Key key, this.product}) : super(key: key);
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
                  ProductInfo(product: product),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Hero(
                        tag: product.id,
                        child: Image.network(
                          product.img,
                          height: defaultSize * 30.8, //378
                          width: defaultSize * 30.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ProductDescription(
                product: product,
                press: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
