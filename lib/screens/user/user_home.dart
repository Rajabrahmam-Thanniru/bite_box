// ignore_for_file: deprecated_member_use

import 'package:bite_box/screens/user/liked.dart';
import 'package:bite_box/screens/user/mainHome.dart';
import 'package:bite_box/screens/user/orders.dart';
import 'package:bite_box/screens/user/profile.dart';
import 'package:bite_box/screens/user/search.dart';
import 'package:bite_box/utils/Notifications.dart';
import 'package:bite_box/utils/cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
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
              child: Icon(
                Icons.notifications_none,
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
              child: const Icon(
                Icons.shopping_cart_outlined,
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
          Order_screen(),
          Liked(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clipboard),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[600],
        onTap: _onItemTapped,
      ),
      drawer: CustomDrawer(
        handleNavigation: handleNavigation,
      ),
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

class CustomDrawer extends StatelessWidget {
  final Function(int) handleNavigation;

  CustomDrawer({required this.handleNavigation});
  // ignore: non_constant_identifier_names
  final User = FirebaseAuth.instance.currentUser;
  Future<String?> getUsername() async {
    String? email;
    try {
      var userDocument = await FirebaseFirestore.instance
          .collection('Users')
          .doc(User!.email)
          .collection('userinfo')
          .doc('userinfo')
          .get();

      if (userDocument.exists) {
        // If the document exists, retrieve the username
        email = userDocument.get('email');
      }
    } catch (e) {
      print("Error getting username: $e");
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      width: width * 0.80,
      child: FutureBuilder<String?>(
        future: getUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: FaIcon(
                              FontAwesomeIcons.close,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Profile(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.amber,
                              size: 60,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' Welcome,',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '  ${snapshot.data}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.houseChimney,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    handleNavigation(
                        0); // Navigate to the first page (MainBuilderHome)
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  color: Colors.black,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.clipboard,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Orders',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    handleNavigation(2);
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.cartShopping,
                    color: Colors.black,
                  ),
                  title: Text(
                    'My Cart',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Cart(),
                      ),
                    );
                  },
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.solidHeart,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Wishlist',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Liked(),
                      ),
                    );
                  },
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
