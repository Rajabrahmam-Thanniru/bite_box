import 'package:bite_box/screens/Admin/Adminorderrequests.dart';
import 'package:bite_box/utils/push_notification_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _orderList = [];
  List<DocumentSnapshot> _filteredOrderList = [];
  Map<String, String> _statusMap = {};
  bool loading = false;
  // ignore: unused_field
  String _searchQuery = '';

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
          .collection('Admin')
          .doc(user?.email)
          .collection('Orders')
          .orderBy('orderDate')
          .get();
      setState(() {
        _orderList = data.docs;
        _filteredOrderList = _orderList;
        for (var doc in _orderList) {
          _statusMap[doc.id] = doc['Status'];
        }
      });
    } catch (e) {
      print('Error fetching orders data: $e');
    }
  }

  void _searchOrders(String query) {
    setState(() {
      _searchQuery = query;
      _filteredOrderList = _orderList.where((order) {
        return order['OrderId'].toString().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await getOrders();
              },
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 20, right: 20),
                    child: Row(
                      children: [
                        Text(
                          "Orders",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AdminOrderRequests()));
                          },
                          child: Text(
                            "Order Requests",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by Order ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            _searchOrders(_searchController.text);
                          },
                        ),
                      ),
                      onChanged: _searchOrders,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredOrderList.length,
                      itemBuilder: (context, index) {
                        var item = _filteredOrderList[index];
                        var orderDate =
                            (item['orderDate'] as Timestamp).toDate();
                        var formattedDate = DateFormat('dd-MM-yy \'at\' h:mm a')
                            .format(orderDate);

                        var itemId = item.id;
                        // ignore: unused_local_variable
                        var currentStatus = _statusMap[itemId] == "Accepted"
                            ? "Preparing"
                            : _statusMap[itemId] == "Preparing"
                                ? "Out For Delivery"
                                : _statusMap[itemId] == "Out For Delivery"
                                    ? "Delivered"
                                    : _statusMap[itemId];

                        return Padding(
                          padding: index == _filteredOrderList.length - 1
                              ? EdgeInsets.only(bottom: width * 0.3)
                              : EdgeInsets.only(bottom: 0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: width * 0.9,
                            height: item['Status'] != 'Delivered' ? 270 : 230,
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
                                      padding: const EdgeInsets.only(
                                          right: 8.0, top: 5),
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
                                    Text(
                                      item['Item Name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.grey),
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
                                                      color: Colors.grey,
                                                      fontSize: 10),
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
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .chevronRight,
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
                                          borderRadius:
                                              BorderRadius.circular(2),
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
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              "₹ ${item['Price'] ?? 'N/A'}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 3, right: 10),
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
                                Row(
                                  children: [
                                    item['Status'] == "Accepted"
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: DropdownButton<String>(
                                              hint: Text('Select an option'),
                                              value: "Preparing",
                                              items: [
                                                DropdownMenuItem<String>(
                                                  value: 'Preparing',
                                                  child: Text('Preparing'),
                                                ),
                                              ],
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _statusMap[itemId] =
                                                      newValue!;
                                                });
                                              },
                                            ),
                                          )
                                        : item['Status'] == "Preparing"
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: DropdownButton<String>(
                                                  hint:
                                                      Text('Select an option'),
                                                  value: "Out For Delivery",
                                                  items: [
                                                    DropdownMenuItem<String>(
                                                      value: 'Out For Delivery',
                                                      child: Text(
                                                          'Out For Delivery'),
                                                    ),
                                                  ],
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _statusMap[itemId] =
                                                          newValue!;
                                                    });
                                                  },
                                                ),
                                              )
                                            : item['Status'] ==
                                                    'Out For Delivery'
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child:
                                                        DropdownButton<String>(
                                                      hint: Text(
                                                          'Select an option'),
                                                      value: "Delivered",
                                                      items: [
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: 'Delivered',
                                                          child:
                                                              Text('Delivered'),
                                                        ),
                                                      ],
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          _statusMap[itemId] =
                                                              newValue!;
                                                        });
                                                      },
                                                    ),
                                                  )
                                                : Container(),
                                    Spacer(),
                                    item['Status'] != 'Delivered'
                                        ? Padding(
                                            padding: EdgeInsets.all(8),
                                            child: GestureDetector(
                                              onTap: () async {
                                                final FirebaseAuth _auth =
                                                    FirebaseAuth.instance;
                                                User? user = _auth.currentUser;
                                                setState(() {
                                                  loading = true;
                                                });
                                                await _firestore
                                                    .collection('Admin')
                                                    .doc(user?.email)
                                                    .collection('Orders')
                                                    .doc(itemId)
                                                    .update({
                                                  'Status': _statusMap[itemId]
                                                });
                                                final userdoc = await _firestore
                                                    .collection('Users')
                                                    .doc(item['Email'])
                                                    .collection('orders')
                                                    .where('OrderId',
                                                        isEqualTo:
                                                            item['OrderId'])
                                                    .get();
                                                for (var doc in userdoc.docs) {
                                                  await _firestore
                                                      .collection('Users')
                                                      .doc(item['Email'])
                                                      .collection('orders')
                                                      .doc(doc.id)
                                                      .update({
                                                    'Status': _statusMap[itemId]
                                                  });
                                                }
                                                final fcm = await _firestore
                                                    .collection('fcmTokens')
                                                    .doc(item['Email'])
                                                    .get();
                                                final token =
                                                    fcm.data()!['token'];
                                                if (_statusMap[itemId] ==
                                                    "Preparing") {
                                                  await PushNotificationService
                                                      .sendNotificationToUser(
                                                    token,
                                                    context,
                                                    item['OrderId'],
                                                    'Order is Preparing',
                                                    'Your Order is Preparing',
                                                  );
                                                } else if (_statusMap[itemId] ==
                                                    "Out For Delivery") {
                                                  await PushNotificationService
                                                      .sendNotificationToUser(
                                                    token,
                                                    context,
                                                    item['OrderId'],
                                                    'Out For Delivery',
                                                    'Your Order is Out For Delivery',
                                                  );
                                                } else if (_statusMap[itemId] ==
                                                    "Delivered") {
                                                  await PushNotificationService
                                                      .sendNotificationToUser(
                                                    token,
                                                    context,
                                                    item['OrderId'],
                                                    'Order Delivered',
                                                    'Your Order is Delivered',
                                                  );
                                                }
                                                await getOrders();
                                                setState(() {
                                                  loading = false;
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.amber,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Text("Update"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ],
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
            ),
    );
  }
}
