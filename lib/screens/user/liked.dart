import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Liked extends StatefulWidget {
  const Liked({super.key});

  @override
  State<Liked> createState() => _LikedState();
}

class _LikedState extends State<Liked> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List _orderList = [];
  List<String> _cartnames = [];
  @override
  void initState() {
    super.initState();
    getwishList();
  }

  Future<void> getwishList() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> data = await _firestore
          .collection('Users')
          .doc(user?.email)
          .collection('wishList')
          .get();
      setState(() {
        _orderList = data.docs;
      });
    } catch (e) {
      print('Error fetching orders data: $e');
    }
  }

  Future<void> cartNames() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> data = await _firestore
          .collection('Users')
          .doc(user?.email)
          .collection('Cart')
          .get();
      setState(() {
        _cartnames = data.docs.map((doc) => doc['itemName'] as String).toList();
        // _setFeaturedItems(); // Update featured items after fetching the wishlist
      });
    } catch (e) {
      print('Error fetching wishlist data: $e');
    }
    //print(_likedItemNames.length);
  }

  bool cheak_item_contains_cart(String item) {
    return _cartnames.contains(item);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _orderList.isEmpty
          ? AppBar(
              title: Text("Your Wishlist",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center),
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
            )
          : AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
            ),
      body: _orderList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No items in your wishlist',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your Wishlist',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _orderList.length,
                    itemBuilder: (context, index) {
                      var item = _orderList[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        width: width * 0.9,
                        height: 190,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  margin: const EdgeInsets.all(10),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: item['Images'] != null &&
                                          item['Images'].isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: item['Images'][0],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : Icon(Icons.image_not_supported),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    item['Item Name'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: FaIcon(
                                    FontAwesomeIcons.solidHeart,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.black12,
                              thickness: 0.5,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                          color: (item['Type']
                                                      .toString()
                                                      .replaceAll(' ', '')
                                                      .toLowerCase() ==
                                                  'non-veg')
                                              ? Colors.red
                                              : Colors.green),
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.solidCircle,
                                        size: 10,
                                        color: (item['Type']
                                                    .toString()
                                                    .replaceAll(' ', '')
                                                    .toLowerCase() ==
                                                'non-veg')
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      item['Item Category'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      "₹ ${item['Price'] ?? 'N/A'}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Divider(
                              color: Colors.black12,
                              thickness: 0.5,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  Text(
                                    'Rate',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      children: [
                                        RatingBar(
                                          initialRating: item['Total Rating'] /
                                              item['Rating Count'],
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          ratingWidget: RatingWidget(
                                            full: Icon(Icons.star,
                                                color: Colors.amber),
                                            half: Icon(Icons.star_half_outlined,
                                                color: Colors.amber),
                                            empty: Icon(
                                                Icons.star_border_outlined,
                                                color: Colors.grey),
                                          ),
                                          itemSize: 18,
                                          ignoreGestures: true,
                                          onRatingUpdate: (rating) {
                                            print(rating);
                                          },
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Text(item['Total Rating'] ==
                                                    0
                                                ? " 0 "
                                                : "(${(item['Total Rating'] / item['Rating Count']).toStringAsFixed(1)})"))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
