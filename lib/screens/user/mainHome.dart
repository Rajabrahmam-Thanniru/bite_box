import 'package:flutter/material.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                child: Container(
                  width: width,
                  height: width * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/mainPic.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 10),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: width,
                height: width * 0.35,
                //color: Colors.yellow,
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: SizedBox(
                                width: 60,
                                height: 40,
                                child: Image.asset(
                                  'assets/images/coke.png',
                                ),
                              ),
                            ),
                            // Tab()
                            Text(
                              'Cool Drinks',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Container(
                                width: 50,
                                height: 40,
                                child: Image.asset(
                                  'assets/images/briyani.png',
                                ),
                              ),
                            ),
                            Text(
                              'Biriyani',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Container(
                                width: 50,
                                height: 40,
                                child: Image.asset(
                                  'assets/images/noodles.png',
                                ),
                              ),
                            ),
                            Text(
                              'Noodles',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Container(
                                width: 50,
                                height: 40,
                                child: Image.asset(
                                  'assets/images/fired rice.png',
                                ),
                              ),
                            ),
                            Text(
                              'Fried Rice',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
