import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_flutter_ui/models/Product.dart';
import 'package:websafe_svg/websafe_svg.dart';


import '../../constants.dart';
import '../../size_config.dart';
import 'components/body.dart';

class DetailsScreen extends StatelessWidget {
  final Product product;
// Thats means we have to  pass it
  const DetailsScreen({Key key, @required this.product}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: kSecondaryColor,
        appBar: buildAppBar(context),
        body: Body(product: product),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: kIsWeb ? WebsafeSvg.asset("assets/icons/arrow-long-left.svg") : SvgPicture.asset("assets/icons/arrow-long-left.svg"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),

    );
  }
}
