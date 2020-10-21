import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_flutter_ui/screens/home/components/body.dart';
import 'package:responsive_flutter_ui/screens/wellcome/wellcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../../size_config.dart';

class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<SliderMenuContainerState> _key =
  new GlobalKey<SliderMenuContainerState>();
  String menu = "assets/icons/menu.svg";

  Future<void> logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    showToast("Logout Success",
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
        backgroundColor: Colors.green,
        textStyle: TextStyle(color: Colors.white),
        reverseCurve: Curves.fastOutSlowIn);
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(
          builder: (context) {
            return WellcomeScreen();
          },
        ),
            (route) => false
    );
  }

  void menuClickListner(id){
    _key.currentState.closeDrawer();
    switch(id){
      case 4:
        logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    // It help us to  make our UI responsive
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
//      appBar: buildAppBar(),
        body: SliderMenuContainer(
          appBarColor: Colors.white,
          key: _key,
          sliderOpen: SliderOpen.LEFT_TO_RIGHT,
          appBarPadding: const EdgeInsets.only(top: 10),
          sliderMenuOpenOffset: 250,
          appBarHeight: 60,
          trailing: Wrap(
            children: [
              IconButton(
                icon: kIsWeb ?
                WebsafeSvg.asset(
                  "assets/icons/search.svg",
                  height: SizeConfig.defaultSize * 2.4, //24
                ) :
                SvgPicture.asset(
                  "assets/icons/search.svg",
                  height: SizeConfig.defaultSize * 2.4, //24
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: kIsWeb ?
                WebsafeSvg.asset(
                  "assets/icons/bag.svg",
                  height: SizeConfig.defaultSize * 2.4, //24
                ) :
                SvgPicture.asset(
                  "assets/icons/bag.svg",
                  height: SizeConfig.defaultSize * 2.4, //24
                ),
                onPressed: () {},
              ),
            ],
          ),
          drawerIcon: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: kIsWeb ?
              WebsafeSvg.asset(
                menu,
                height: SizeConfig.defaultSize * 2.4, //24
              ) :
              SvgPicture.asset(
                menu,
                height: SizeConfig.defaultSize * 2, //20
              ),
              onPressed: () {
                _key.currentState.toggle();
                setState(() {
                  if(_key.currentState.isDrawerOpen){
                    menu = "assets/icons/close.svg";
                  }else{
                    menu = "assets/icons/menu.svg";
                  }
                });
              },
            ),
          ),
          sliderMenu: MenuWidget(
            onItemClick: menuClickListner,

          ),
          sliderMain: Body(),
      ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: kIsWeb ?
          WebsafeSvg.asset(
            "assets/icons/menu.svg",
            height: SizeConfig.defaultSize * 2.4, //24
          ) :
          SvgPicture.asset(
            "assets/icons/menu.svg",
            height: SizeConfig.defaultSize * 2, //20
          ),
          onPressed: () {},
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: kIsWeb ?
          WebsafeSvg.asset(
            "assets/icons/search.svg",
            height: SizeConfig.defaultSize * 2.4, //24
          ) :
          SvgPicture.asset(
            "assets/icons/search.svg",
            height: SizeConfig.defaultSize * 2.4, //24
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: kIsWeb ?
          WebsafeSvg.asset(
            "assets/icons/cart.svg",
            height: SizeConfig.defaultSize * 2.4, //24
          ) :
          SvgPicture.asset(
            "assets/icons/cart.svg",
            height: SizeConfig.defaultSize * 2.4, //24
          ),
          onPressed: () {},
        ),

        SizedBox(width: SizeConfig.defaultSize),
      ],
    );
  }
}


class MenuWidget extends StatelessWidget {
  final Function(int) onItemClick;

  const MenuWidget({Key key, this.onItemClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.only(top: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/boy.png'),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '+91 7415251523',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  fontFamily: 'BalsamiqSans'),
            ),
            SizedBox(
              height: 30,
            ),
            Divider(),
            sliderItem(0,'Home', "assets/icons/home.svg"),
            Divider(),
            sliderItem(1,'Cart', "assets/icons/bag.svg"),
            Divider(),
            sliderItem(2,'My Order', "assets/icons/my_orders.svg"),
            Divider(),
            sliderItem(3,'My Profile', "assets/icons/user_black.svg"),
            Divider(),
            sliderItem(4,'Logout', "assets/icons/logout.svg"),
            Divider(),
//            sliderItem('Add Post', Icons.add_circle),
//            sliderItem('Notification', Icons.notifications_active),
//            sliderItem('Likes', Icons.favorite),
//            sliderItem('Setting', Icons.settings),
//            sliderItem('LogOut', Icons.arrow_back_ios)
          ],
        ),
      ),
    );
  }

  Widget sliderItem(int id,String title, String icon) =>
      GestureDetector(
        onTap: (){
          onItemClick(id);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 30,),
            kIsWeb ?
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: WebsafeSvg.asset(
                icon,
                height: SizeConfig.defaultSize * 2.5,
              ),
            ) :
            SvgPicture.asset(
              icon,
              height: SizeConfig.defaultSize * 2.5, //20
            ),
            SizedBox(width: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
              child: Text(title,style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600
              ),),
            )
          ],
        ),
      );
}