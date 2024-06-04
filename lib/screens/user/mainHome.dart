import 'package:bite_box/utils/signOut.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainUserHome extends StatefulWidget {
  const MainUserHome({super.key});

  @override
  State<MainUserHome> createState() => _MainUserHomeState();
}

class _MainUserHomeState extends State<MainUserHome> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  handleSignOut(context);
                },
                child: Container(
                  width: width * 0.98,
                  height: 220,
                  color: Colors.black,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 30),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )));
  }
}
