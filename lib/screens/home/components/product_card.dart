import 'package:flutter/material.dart';
import 'package:responsive_flutter_ui/components/title_text.dart';
import 'package:responsive_flutter_ui/models/Product.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key key,
    this.product,
    this.press,
  }) : super(key: key);

  final Product product;
  final Function press;

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: press,
      child: Container(
        width: defaultSize * 14.5, //145
        decoration: BoxDecoration(
          color: kSecondaryColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: AspectRatio(
          aspectRatio: 0.793,
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: Hero(
                  tag: product.id,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/spinner.gif",
                      image: product.img,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Text(product.engName,style: TextStyle(fontWeight: FontWeight.w200),),
              ),
              Text("${product.hindiName}"),
              SizedBox(height: defaultSize / 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TitleText(title:"$rupee ${product.price}"),
                  Text("/${product.quantity}kg",style: TextStyle(fontSize: 13),),
                ],
              ),
              SizedBox(height: defaultSize / 2),
              Spacer(),

            ],
          ),
        ),
      ),
    );
  }
}
