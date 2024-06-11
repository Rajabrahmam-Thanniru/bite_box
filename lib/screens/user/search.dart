import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final FocusNode _searchFocusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List _searchResults = [];
  List _allMenu = [];
  List _recentSearches = [];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int searchLength = _searchResults.length;
    int recentLength = _recentSearches.length;

    return Scaffold(
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
                      _search(value);
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchLength != 0
                  ? min(3, searchLength)
                  : min(4, recentLength),
              itemBuilder: (context, index) {
                var item = searchLength != 0
                    ? _searchResults[index]
                    : _recentSearches[index];

                return Card(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
        ],
      ),
    );
  }

  void _search(String value) {
    _searchResults.clear();
    for (var i = 0; i < _allMenu.length; i++) {
      if (_allMenu[i]['Item Name']
          .toString()
          .toLowerCase()
          .contains(value.toLowerCase())) {
        _searchResults.add(_allMenu[i]);
        _recentSearches.add(_allMenu[i]);
      }
    }
    setState(() {});
  }
}
