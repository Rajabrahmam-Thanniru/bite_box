import 'package:bite_box/screens/user/user_home.dart';
import 'package:bite_box/utils/place_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List _cartList = [];
  Map<int, int> _quantities = {};
  int _totalPrice = 0;
  int _basePrice = 0;
  late int tapVal = 0;
  final int deliveryCharge = 5;
  TextEditingController note = TextEditingController();
  String selectedAddress = "";
  late int s = 0;

  @override
  void initState() {
    super.initState();
    getCartItems();
  }

  Future<void> getCartItems() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> data = await _firestore
          .collection('Users')
          .doc(user?.email)
          .collection('Cart')
          .orderBy('orderDate')
          .get();
      setState(() {
        _cartList = data.docs;
        // Initialize quantities for each item
        for (int i = 0; i < _cartList.length; i++) {
          _quantities[i] = 1;
        }
        _calculateBasePrice();
      });
    } catch (e) {
      print('Error fetching orders data: $e');
    }
  }

  void _calculateBasePrice() {
    int totalPrice = 0;
    for (int i = 0; i < _cartList.length; i++) {
      int price = _cartList[i]['price'] is int
          ? _cartList[i]['price']
          : int.parse(_cartList[i]['price']);
      totalPrice += price * _quantities[i]!;
    }
    setState(() {
      _basePrice = totalPrice;
      _totalPrice = _basePrice + (tapVal == 1 ? deliveryCharge : 0);
    });
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  void _proceedToCheckout() async {
    // Check if _cartList and _quantities are populated
    if (_cartList.isEmpty || _quantities.isEmpty) {
      print('Cart is empty or quantities are not initialized properly.');
      return;
    }

    List<Map<String, dynamic>> orderData = [];

    try {
      // Loop through _cartList and create orderData
      for (int i = 0; i < _cartList.length; i++) {
        var item = _cartList[i];
        int quantity = _quantities[i] ?? 1;
        int price =
            item['price'] is int ? item['price'] : int.parse(item['price']);
        orderData.add({
          'Images': item['ItemImage'],
          'Item Name': item['itemName'],
          'Item Category': item['category'],
          'Price': price * quantity,
          'Quantity': quantity,
          'Address': selectedAddress, // Add selected address to orderData
        });
      }

      Place_order placeOrder = Place_order();
      await placeOrder.PlaceOrder(context, orderData);

      await _clearCart();

      // Navigate to the next screen or perform any other action after checkout
      // For example, navigate back to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => User_home(initialSelectedIndex: 0)),
      );
    } catch (e) {
      print('Error creating order data or placing order: $e');
      // Handle any errors that occur during order creation or placement
    }
  }

  Future<void> _clearCart() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    try {
      // Delete all documents in the Cart collection for the current user
      QuerySnapshot<Map<String, dynamic>> cartSnapshot = await _firestore
          .collection('Users')
          .doc(user?.email)
          .collection('Cart')
          .get();

      for (DocumentSnapshot doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      print('Cart deleted successfully.');
    } catch (e) {
      print('Error deleting cart: $e');
      // Handle any errors that occur while deleting the cart
    }
  }

  void _checkAddress(String? address) {
    if (address != null &&
        (address.toLowerCase() == 'block 1' ||
            address.toLowerCase() == 'block 2' ||
            address.toLowerCase() == 'block 3' ||
            address.toLowerCase() == 'block 4')) {
      setState(() {
        selectedAddress = address;
        s = 1;
      });
    } else {
      setState(() {
        selectedAddress = "";
        s = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int n = 4;
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            User_home(initialSelectedIndex: 0),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.chevronLeft,
                          size: 18,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            'Cart',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
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
          Spacer(),
        ],
      ),
      body: (_cartList.length == 0)
          ? Center(
              child: Text(
                'no items add to cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Container(
                  width: width,
                  height: (_cartList.length == 1)
                      ? 150
                      : (_cartList.length == 2)
                          ? width * 0.7
                          : width * 0.9,
                  child: ListView.builder(
                    itemCount: _cartList.length,
                    itemBuilder: (context, index) {
                      var item = _cartList[index];
                      int price = item['price'] is int
                          ? item['price']
                          : int.parse(item['price']);
                      int quantity = _quantities[index] ?? 1;

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
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Container(
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
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['itemName'] ?? 'No Name',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: Text(
                                                "₹ ${item['price'] ?? 'N/A'}",
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 90,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.orangeAccent),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        if (quantity > 1) {
                                                          _quantities[index] =
                                                              quantity - 1;
                                                          _calculateBasePrice();
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      '-',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color:
                                                            Colors.orangeAccent,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Text(
                                                      "$quantity",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color:
                                                            Colors.orangeAccent,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _quantities[index] =
                                                            quantity + 1;
                                                        _calculateBasePrice();
                                                      });
                                                    },
                                                    child: Text(
                                                      '+',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color:
                                                            Colors.orangeAccent,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: Text(
                                                "₹ ${price * quantity}",
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
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
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                  child: DropdownButtonFormField<String>(
                    value: selectedAddress.isEmpty ? null : selectedAddress,
                    decoration: const InputDecoration(
                      hintText: 'Select your address',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 5, right: 10),
                        child: FaIcon(FontAwesomeIcons.locationDot),
                      ),
                      border: InputBorder.none,
                    ),
                    items: ['Block 1', 'Block 2', 'Block 3', 'Block 4']
                        .map((address) => DropdownMenuItem<String>(
                              value: address,
                              child: Text(address),
                            ))
                        .toList(),
                    onChanged: _checkAddress,
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      (s == 1)
                          ? Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 10, left: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tapVal = 0;
                                        _totalPrice = _basePrice;
                                      });
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: (tapVal == 0)
                                                ? Colors.orangeAccent
                                                : Colors.grey),
                                      ),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 10, top: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Standard',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Text(
                                                'Your usual preparation time',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tapVal = 1;
                                      _totalPrice = _basePrice + deliveryCharge;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, left: 10),
                                    child: Container(
                                      width: 150,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: (tapVal == 1)
                                                ? Colors.orangeAccent
                                                : Colors.grey),
                                      ),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 10, top: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Delivery',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: Text(
                                                    '₹ $deliveryCharge ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Text(
                                                'We will deliver the item to your location ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              height: s == 1
                                  ? 0
                                  : 50, // Adjust the height based on visibility
                            ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orangeAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Add a note to canteen',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 5, right: 10),
                              child: FaIcon(FontAwesomeIcons.clipboard),
                            ),
                            border: InputBorder.none,
                          ),
                          controller: note,
                          maxLines: 3,
                        ),
                      ),
                      Text(
                        "Total Price: ₹$_totalPrice",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          onPressed: _proceedToCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 100, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Proceed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
