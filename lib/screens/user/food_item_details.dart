import 'dart:math';

import 'package:bite_box/utils/Notifications.dart';
import 'package:bite_box/utils/cart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final List data;
  final String cat;

  const Details({Key? key, required this.data, required this.cat})
      : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final FocusNode _searchFocusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late int val = 0;
  List _searchResults = [];
  List _allMenu = [];

  @override
  void initState() {
    super.initState();
    val = 0; // Initialize val
    getMenu();
  }

  Future<void> getMenu() async {
    try {
      QuerySnapshot<Map<String, dynamic>> data =
          await _firestore.collection('Menu').orderBy('Item Name').get();
      setState(() {
        _allMenu = data.docs;
      });
    } catch (e) {
      print('Error fetching menu data: $e');
    }
  }

  void _search(String value) {
    _searchResults.clear();
    for (var i = 0; i < _allMenu.length; i++) {
      if (_allMenu[i]['Item Name']
          .toString()
          .toLowerCase()
          .contains(value.toLowerCase())) {
        _searchResults.add(_allMenu[i]);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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
      body: Column(
        children: [
          Container(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CupertinoSearchTextField(
                    focusNode: _searchFocusNode,
                    placeholder: 'Search',
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    onChanged: (value) {
                      setState(() {
                        val = value.length;
                      });
                      _search(value);
                    },
                  ),
                ),
              ),
            ),
          ),
          (widget.data.length != 0 || val != 0)
              ? Expanded(
                  child: ListView.builder(
                    itemCount: val == 0
                        ? widget.data.length
                        : min(4, _searchResults.length),
                    itemBuilder: (context, index) {
                      var item =
                          val == 0 ? widget.data[index] : _searchResults[index];

                      return Card(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          width: width * 0.9,
                          height: 100,
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
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 100,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: item['Images'] != null &&
                                        item['Images'].isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: item['Images'][0],
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      )
                                    : Icon(Icons.image_not_supported),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 8.0, right: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['Item Name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.black12,
                                        thickness: 0.5,
                                      ),
                                      Text(
                                        "₹ ${item['Price'] ?? 'N/A'}",
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: width * 0.8),
                    child: Text(
                      "No items related to ${widget.cat}",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
