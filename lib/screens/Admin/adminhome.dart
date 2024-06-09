import 'package:bite_box/screens/Admin/Uploadfood.dart';
import 'package:bite_box/screens/Admin/adminorders.dart';
import 'package:bite_box/screens/Admin/adminprofile.dart';
import 'package:bite_box/screens/Admin/adminrevenue.dart';
import 'package:bite_box/screens/Admin/mainadminhome.dart';
import 'package:bite_box/utils/Hexcode.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminHome extends StatefulWidget {
  final int initialSelectedIndex;
  const AdminHome({super.key, required this.initialSelectedIndex});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;
  late PageController _pageController;
  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.initialSelectedIndex;
    });
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
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
            icon: FaIcon(FontAwesomeIcons.clipboard),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_rupee),
            label: 'Revenue',
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
      floatingActionButton: Container(
        width: 100,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => UploadFood()));
          },
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: width * 0.05),
                child: Icon(Icons.add),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: width * 0.02,
                ),
                child: Text("New",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                    )),
              )
            ],
          ), // Replace with your desired icon
          backgroundColor: HexColor('#242424'),
          foregroundColor: Colors.white,
          // Customize button color
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: AlwaysScrollableScrollPhysics(),
        onPageChanged: (index) {
          handleNavigation(index);
        },
        children: [
          MainAdminHome(),
          AdminOrders(),
          AdminRevenue(),
          AdminProfile(),
        ],
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
