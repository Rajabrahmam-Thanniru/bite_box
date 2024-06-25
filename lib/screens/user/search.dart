import 'dart:math';
import 'package:bite_box/screens/user/show_item_details.dart';
import 'package:bite_box/utils/Search_something.dart';
import 'package:bite_box/utils/cart.dart';
import 'package:bite_box/utils/place_order.dart';
import 'package:bite_box/utils/push_to_cart.dart';
import 'package:bite_box/utils/push_to_wishlist.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  Push_to_cart p = Push_to_cart();
  SearchSomething ss = SearchSomething();
  List _cartnames = [];
  Push_to_wishlist pw = Push_to_wishlist();

  @override
  void initState() {
    super.initState();
    getMenu();
    getsearchhistory();
  }

  Stream<List<DocumentSnapshot>> getMenu() {
    fetchCartNames();
    return _firestore
        .collection('Menu')
        .orderBy('Item Name')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<DocumentSnapshot>> getsearchhistory() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    return _firestore
        .collection('Users')
        .doc(user?.email)
        .collection('Search History')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> fetchCartNames() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> data = await _firestore
          .collection('Users')
          .doc(user?.email)
          .collection('Cart')
          .get();
      setState(() {
        _cartnames = data.docs
            .map((doc) => (doc['Item Name'] as String).toLowerCase())
            .toList();
      });
    } catch (e) {
      print('Error fetching cart data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int searchLength = _searchResults.length;
    int recentLength = _recentSearches.length;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Column(
        children: [
          Container(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: CupertinoSearchTextField(
                  focusNode: _searchFocusNode,
                  placeholder: 'Search',
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  onChanged: (value) {
                    _search(value);
                  },
                  onSubmitted: (value) {
                    final FirebaseAuth _auth = FirebaseAuth.instance;
                    User? user = _auth.currentUser;
                    _firestore
                        .collection('Users')
                        .doc(user?.email)
                        .collection('Search History')
                        .add({
                      'Search': value,
                      'Date': Timestamp.now(),
                    });
                  },
                ),
              ),
            ),
          ),
          _searchResults.isEmpty
              ? Expanded(
                  child: StreamBuilder(
                    stream: getsearchhistory() as Stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      _recentSearches = snapshot.data ?? [];
                      return ListView.builder(
                        itemCount: min(4, recentLength),
                        itemBuilder: (context, index) {
                          var item = _recentSearches[index];
                          return GestureDetector(
                            onTap: () {
                              _search(item['Search']);
                            },
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  width: width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.history),
                                        const SizedBox(width: 10),
                                        Text(
                                          item['Search'] ?? 'No Name',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Spacer(),
                                        GestureDetector(
                                            onTap: () async {
                                              final FirebaseAuth _auth =
                                                  FirebaseAuth.instance;
                                              User? user = _auth.currentUser;
                                              await _firestore
                                                  .collection('Users')
                                                  .doc(user?.email)
                                                  .collection('Search History')
                                                  .doc(item.id)
                                                  .delete();
                                              getsearchhistory();
                                            },
                                            child: Icon(Icons.close)),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 0.5,
                                  thickness: 0.5,
                                  color: Colors.black12,
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              : Expanded(
                  child: StreamBuilder(
                    stream: getMenu() as Stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      _allMenu = snapshot.data ?? [];
                      return ListView.builder(
                        itemCount: searchLength != 0
                            ? min(3, searchLength)
                            : min(4, recentLength),
                        itemBuilder: (context, index) {
                          var item = searchLength != 0
                              ? _searchResults[index]
                              : _recentSearches[index];
                          bool inCart = _cartnames.contains(
                              item['Item Name'].toString().toLowerCase());

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Item_details(
                                          item: item.data()
                                              as Map<String, dynamic>,
                                          a: 1,
                                        )),
                              );
                            },
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
                                            placeholder: (context, url) =>
                                                Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
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
                                          Row(
                                            children: [
                                              Text(
                                                item['Item Name'] ?? 'No Name',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Spacer(),
                                              Container(
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  border: Border.all(
                                                      color: (item['Type']
                                                                  .toString()
                                                                  .replaceAll(
                                                                      ' ', '')
                                                                  .toLowerCase() ==
                                                              'non-veg')
                                                          ? Colors.red
                                                          : Colors.green),
                                                ),
                                                child: Center(
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .solidCircle,
                                                    size: 10,
                                                    color: (item['Type']
                                                                .toString()
                                                                .replaceAll(
                                                                    ' ', '')
                                                                .toLowerCase() ==
                                                            'non-veg')
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.black12,
                                            thickness: 0.5,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "₹ ${item['Price'] ?? 'N/A'}",
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Spacer(),
                                              GestureDetector(
                                                onTap: () async {
                                                  if (inCart) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Cart(),
                                                      ),
                                                    );
                                                  } else {
                                                    await ss.searchSomethingFun(
                                                        context,
                                                        item['Item Name'],
                                                        1);
                                                    await fetchCartNames();
                                                  }
                                                },
                                                child: Container(
                                                  width: inCart ? 90 : 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                        color: Colors
                                                            .orangeAccent),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 20,
                                                            top: 5,
                                                            bottom: 5),
                                                    child: Center(
                                                      child: Text(
                                                        inCart
                                                            ? 'Added'
                                                            : 'Add +',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .orangeAccent),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
    _recentSearches.clear();
    if (value.isNotEmpty) {
      for (var i = 0; i < _allMenu.length; i++) {
        if (_allMenu[i]['Item Name']
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase())) {
          _searchResults.add(_allMenu[i]);
          _recentSearches.add(_allMenu[i]);
        }
      }
    }
    setState(() {});
  }
}
