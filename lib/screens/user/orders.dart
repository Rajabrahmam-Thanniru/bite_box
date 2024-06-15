import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Order_screen extends StatefulWidget {
  const Order_screen({super.key});
  @override
  State<Order_screen> createState() => _OrderState();
}

class _OrderState extends State<Order_screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List _orderList = [];

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  Future<void> getOrders() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> data = await _firestore
          .collection('Users')
          .doc(user?.email)
          .collection('orders')
          .orderBy('orderDate')
          .get();
      setState(() {
        _orderList = data.docs;
      });
    } catch (e) {
      print('Error fetching orders data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Text(
              'Your Orders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _orderList.length,
              itemBuilder: (context, index) {
                var item = _orderList[index];
                var orderDate = (item['orderDate'] as Timestamp).toDate();
                var formattedDate =
                    DateFormat('dd-MM-yy \'at\' h:mm a').format(orderDate);

                return Card(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: width * 0.9,
                    height: 220,
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
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: item['ItemImage'] != null &&
                                      item['ItemImage'].isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item['ItemImage'][0],
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  : Icon(Icons.image_not_supported),
                            ),
                            Spacer(),
                            Text(
                              item['itemName'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['Status'],
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        'View Menu',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      //  Spacer(),
                                      Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child: FaIcon(
                                          FontAwesomeIcons.chevronRight,
                                          size: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
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
                                  border: Border.all(color: Colors.red),
                                ),
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.solidCircle,
                                    size: 10,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  item['quantity'].toString() + ' X',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  item['itemName'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
                                formattedDate,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  Text(
                                    "₹ ${item['price'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 3, right: 10),
                                    child: FaIcon(
                                      FontAwesomeIcons.chevronRight,
                                      size: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
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
                                  fontSize: 20,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 17),
                                child: Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.star,
                                      size: 15,
                                    ),
                                    FaIcon(
                                      FontAwesomeIcons.star,
                                      size: 15,
                                    ),
                                    FaIcon(
                                      FontAwesomeIcons.star,
                                      size: 15,
                                    ),
                                    FaIcon(
                                      FontAwesomeIcons.star,
                                      size: 15,
                                    ),
                                    FaIcon(
                                      FontAwesomeIcons.star,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
}
