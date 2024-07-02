import 'package:bite_box/screens/Admin/EditFood.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MainAdminHome extends StatefulWidget {
  const MainAdminHome({super.key});

  @override
  State<MainAdminHome> createState() => _MainAdminHomeState();
}

class _MainAdminHomeState extends State<MainAdminHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List _orderRequestList = [];
  Future<void> getorderrequests() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> data =
          await _firestore.collection('Menu').get();
      setState(() {
        _orderRequestList = data.docs;
      });
    } catch (e) {
      print('Error fetching orders data: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    DefaultCacheManager().emptyCache();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 15),
                child: Text(
                  'Inventory',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: getorderrequests().asStream(),
                builder: (context, snapshot) => ListView.builder(
                  itemCount: _orderRequestList.length,
                  itemBuilder: (context, index) {
                    var item = _orderRequestList[index];

                    return Padding(
                      padding: index == _orderRequestList.length - 1
                          ? EdgeInsets.only(bottom: width * 0.3)
                          : EdgeInsets.only(bottom: 0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        width: width * 0.9,
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
                                          key: UniqueKey(),
                                        )
                                      : Icon(Icons.image_not_supported),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['Item Name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${item['Price']}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black12,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2.0,
                                                    bottom: 2,
                                                    left: 6,
                                                    right: 6),
                                                child:
                                                    Text(item['Item Category']),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Spacer(),
                                item['Type'] == 'Veg'
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            border:
                                                Border.all(color: Colors.green),
                                          ),
                                          child: Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.solidCircle,
                                              size: 10,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            border:
                                                Border.all(color: Colors.red),
                                          ),
                                          child: Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.solidCircle,
                                              size: 10,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            Row(
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text("Consists Of",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    )),
                                Spacer(),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Text('Edit Details'),
                                      value: 'edit',
                                    ),
                                    PopupMenuItem(
                                      child: Text('Delete'),
                                      value: 'delete',
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditFood(snapshot: item)));
                                    } else if (value == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Delete Item'),
                                            content: Text(
                                                'Are you sure you want to delete this item?'),
                                            actions: [
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Delete'),
                                                onPressed: () {
                                                  _firestore
                                                      .collection('Menu')
                                                      .doc(item.id)
                                                      .delete();
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Icon(Icons.more_vert_rounded),
                                  color: Colors.white,
                                  tooltip: 'Options',
                                )
                              ],
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10),
                                  child: Text(item['Consists Of'],
                                      style: TextStyle(
                                        fontSize: 15,
                                      )),
                                ))
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
