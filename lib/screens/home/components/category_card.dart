import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_flutter_ui/components/title_text.dart';
import 'package:responsive_flutter_ui/models/Product.dart';
import 'package:responsive_flutter_ui/screens/product_detail/details_screen.dart';


import '../../../constants.dart';
import '../../../size_config.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key key,
    // It means we have  to add category
    @required this.category,
  }) : super(key: key);

  final Product category;

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                product: category,
              ),
            ));
      },
      child: Padding(
        padding: EdgeInsets.all(defaultSize * 2), //20
        child: SizedBox(
          width: defaultSize * 20.5, //205
          child: AspectRatio(
            aspectRatio: 0.83,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                // This is custom Shape thats why we need to use ClipPath
                ClipPath(
                  clipper: CategoryCustomShape(),
                  child: AspectRatio(
                    aspectRatio: 1.025,
                    child: Container(
                      padding: EdgeInsets.all(defaultSize * 2),
                      color: kSecondaryColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TitleText(title: category.engName),
                          SizedBox(height: defaultSize),
                          Text(
                            "${category.hindiName}",
                            style: TextStyle(
                              color: kTextColor.withOpacity(0.6),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FadeInImage(
                        placeholder: AssetImage("assets/spinner.gif"),
                        image: CachedNetworkImageProvider(category.img),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double height = size.height;
    double width = size.width;
    double cornerSize = 30;

    path.lineTo(0, height - cornerSize);
    path.quadraticBezierTo(0, height, cornerSize, height);
    path.lineTo(width - cornerSize, height);
    path.quadraticBezierTo(width, height, width, height - cornerSize);
    path.lineTo(width, cornerSize);
    path.quadraticBezierTo(width, 0, width - cornerSize, 0);
    path.lineTo(cornerSize, cornerSize * 0.75);
    path.quadraticBezierTo(0, cornerSize, 0, cornerSize * 2);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
