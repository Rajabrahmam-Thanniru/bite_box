import 'package:bite_box/utils/Hexcode.dart';
import 'package:bite_box/utils/signOut.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainUserHome extends StatefulWidget {
  const MainUserHome({super.key});

  @override
  State<MainUserHome> createState() => _MainUserHomeState();
}

class _MainUserHomeState extends State<MainUserHome> {
  List<String> categories = [];
  List<String> categoriesImages = [];

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
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: getCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  categories = snapshot.data!.keys.toList();
                  categoriesImages =
                      snapshot.data!.values.cast<String>().toList();
                  return Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              width: 80,
                              height: 100,
                              decoration: BoxDecoration(
                                color: HexColor('#EEEEEE'),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  categoriesImages[index],
                                  fit: BoxFit.contain,
                                ),
                              )),
                            ),
                            Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                } else {
                  return Text('No categories found.');
                }
              },
            )
          ],
        )));
  }

  Future<Map<String, dynamic>> getCategories() async {
    final categorySnapshot = await FirebaseFirestore.instance
        .collection('Categories')
        .doc('Categories Images')
        .get();
    final categoriesData = categorySnapshot.data();
    return categoriesData ?? {};
  }
}
