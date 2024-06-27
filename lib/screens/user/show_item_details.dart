import 'package:bite_box/utils/Search_something.dart';
import 'package:bite_box/utils/cart.dart';
import 'package:bite_box/utils/push_to_cart.dart';
import 'package:bite_box/utils/push_to_wishlist.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Item_details extends StatefulWidget {
  final Map<String, dynamic> item;
  final int a;

  const Item_details({
    required this.item,
    Key? key,
    required this.a,
  }) : super(key: key);

  @override
  State<Item_details> createState() => _Item_detailsState();
}

class _Item_detailsState extends State<Item_details> {
  List _wishlist_item = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Push_to_wishlist pw = Push_to_wishlist();
  SearchSomething searchSomething = SearchSomething();
  Push_to_cart pc = Push_to_cart();
  @override
  void initState() {
    super.initState();

    wishList_names();
  }

  Future<void> wishList_names() async {
    _wishlist_item.clear();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> data = await _firestore
          .collection('Users')
          .doc(user?.email)
          .collection('wishList')
          .get();
      setState(() {
        _wishlist_item = data.docs
            .map((doc) =>
                (doc['Item Name'] as String).replaceAll(' ', '').toLowerCase())
            .toList();
      });
    } catch (e) {
      print('Error fetching wishlist data: $e');
    }
    print(_wishlist_item.length);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    bool isliked = _wishlist_item.contains(
        widget.item['Item Name'].toString().replaceAll(' ', '').toLowerCase());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          await pc.PushtoCart(context, [widget.item]);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Cart()),
          );
        },
        child: Container(
          height: 70,
          color: Colors.orangeAccent,
          child: Center(
            child: Text(
              'Add To Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 35,
                  height: 35,
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
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        if (isliked) {
                          await pw.delete_item_wishlist(
                              context, widget.item['Item Name']);
                        } else {
                          await searchSomething.searchSomethingFun(
                              context, widget.item['Item Name'], 2);
                        }
                        await wishList_names();
                      },
                      child: (isliked)
                          ? FaIcon(
                              FontAwesomeIcons.solidHeart,
                              color: Colors.red,
                            )
                          : FaIcon(
                              FontAwesomeIcons.heart,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: 190,
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
                child: Container(
                  width: 120,
                  height: 140,
                  margin: const EdgeInsets.all(5),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.item['Images'][0],
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    key: UniqueKey(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.item['Item Name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Text(
                          "₹${widget.item['Price']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.solidCircle,
                        size: 5,
                      ),
                      Text(
                        " Includes " + widget.item['Consists Of'],
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black12,
                    thickness: 0.5,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 15),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.solidStar,
                          size: 18,
                          color: Colors.amber,
                        ),
                        Text(
                          "${widget.item['Total Rating'] / widget.item['Rating Count']} (${widget.item['Rating Count']})",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.clock,
                                size: 16,
                              ),
                              Text(
                                ' 10 min',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, right: 15, bottom: 10),
                    child: Text(
                      widget.item['Item Description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
