import 'package:bite_box/utils/Notifications.dart';
import 'package:bite_box/utils/cart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class User_home extends StatefulWidget {
  const User_home({super.key});

  @override
  State<User_home> createState() => _User_homeState();
}

class _User_homeState extends State<User_home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: FaIcon(
                    FontAwesomeIcons.bars,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notifications()),
                );
              },
              child: FaIcon(
                FontAwesomeIcons.solidBell,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 13),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Cart()),
                );
              },
              child: const FaIcon(
                FontAwesomeIcons.cartShopping,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Container(),
    );
  }
}
