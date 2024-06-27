import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Order_screen extends StatefulWidget {
  const Order_screen({super.key});
  @override
  State<Order_screen> createState() => _OrderState();
}

class _OrderState extends State<Order_screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double productRating = 0;
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
          .orderBy('orderDate', descending: true)
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
      body: RefreshIndicator(
        onRefresh: () async {
          await getOrders();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
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

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: width * 0.9,
                    height: 260,
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
                        Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, top: 5),
                              child: Text(
                                "Order Id: ${item['OrderId']}",
                                style: TextStyle(
                                  color: Colors.black26,
                                  fontSize: 15,
                                ),
                              ),
                            )),
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
                            Text(
                              item['Item Name'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                          right: 10,
                                          left: 10),
                                      child: Center(
                                        child: Text(
                                          item['Status'],
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 10),
                                        ),
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
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black12,
                          thickness: 0.4,
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
                                  item['quantity'].toString() + ' x',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  item['Item Name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                          thickness: 0.4,
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
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      "₹ ${item['Price'] ?? 'N/A'}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                          thickness: 0.4,
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
                              item['Rating Given']
                                  ? Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: RatingBar(
                                            initialRating: item['Stars'],
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            ratingWidget: RatingWidget(
                                              full: Icon(Icons.star,
                                                  color: Colors.amber),
                                              half: Icon(
                                                  Icons.star_half_outlined,
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
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Text("(${item['Stars']})"))
                                      ],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Row(
                                        children: [
                                          RatingBar(
                                            initialRating: 0,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            ratingWidget: RatingWidget(
                                              full: Icon(Icons.star,
                                                  color: Colors.amber),
                                              half: Icon(
                                                  Icons.star_half_outlined,
                                                  color: Colors.amber),
                                              empty: Icon(
                                                  Icons.star_border_outlined,
                                                  color: Colors.grey),
                                            ),
                                            itemSize: 18,
                                            onRatingUpdate: (rating) {
                                              setState(() {
                                                productRating = rating;
                                              });
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0, right: 8),
                                            child: GestureDetector(
                                              onTap: () async {
                                                final FirebaseAuth _auth =
                                                    FirebaseAuth.instance;

                                                User? user = _auth.currentUser;
                                                if (productRating != 0) {
                                                  await _firestore
                                                      .collection('Users')
                                                      .doc(user?.email)
                                                      .collection('orders')
                                                      .doc(item.id)
                                                      .update({
                                                    'Rating Given': true,
                                                    'Stars': productRating,
                                                  });
                                                  await _firestore
                                                      .collection('Menu')
                                                      .doc(item['Item Name'])
                                                      .update({
                                                    'Total Rating':
                                                        FieldValue.increment(
                                                            productRating),
                                                    'Rating Count':
                                                        FieldValue.increment(1),
                                                  });
                                                  await getOrders();
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Please rate the product'),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text('Submit'),
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                              ),
                                            ),
                                          ),
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
      ),
    );
  }
}
