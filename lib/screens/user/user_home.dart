import 'package:bite_box/screens/user/liked.dart';
import 'package:bite_box/screens/user/mainHome.dart';
import 'package:bite_box/screens/user/orders.dart';
import 'package:bite_box/screens/user/profile.dart';
import 'package:bite_box/screens/user/search.dart';
import 'package:bite_box/utils/Notifications.dart';
import 'package:bite_box/utils/cart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class User_home extends StatefulWidget {
  final int initialSelectedIndex;
  const User_home({super.key, required this.initialSelectedIndex});

  @override
  State<User_home> createState() => _User_homeState();
}

class _User_homeState extends State<User_home> {
  late PageController _pageController;
  int _selectedIndex = 0;
  late final int initialSelectedIndex;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.initialSelectedIndex;
    });
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
      body: PageView(
        controller: _pageController,
        physics: AlwaysScrollableScrollPhysics(),
        onPageChanged: (index) {
          handleNavigation(index);
        },
        children: [
          MainUserHome(),
          Search(),
          Order(),
          Liked(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Liked',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      endDrawer: Drawer(),
    );
  }

  void handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _pageController.jumpToPage(0);
          break;
        case 1:
          _pageController.jumpToPage(1);
          break;
        case 2:
          _pageController.jumpToPage(2);
          break;
        case 3:
          _pageController.jumpToPage(3);
          break;
        default:
          break;
      }
    });
  }
}
