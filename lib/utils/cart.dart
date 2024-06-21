import 'package:bite_box/screens/user/user_home.dart';
import 'package:bite_box/utils/Hexcode.dart';
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
      int price = _cartList[i]['Price'] is int
          ? _cartList[i]['Price']
          : int.parse(_cartList[i]['Price']);
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
    if (_cartList.isEmpty || _quantities.isEmpty) {
      print('Cart is empty or quantities are not initialized properly.');
      return;
    }

    List<Map<String, dynamic>> orderData = [];

    try {
      for (int i = 0; i < _cartList.length; i++) {
        var item = _cartList[i];
        int quantity = _quantities[i] ?? 1;
        int price =
            item['Price'] is int ? item['Price'] : int.parse(item['Price']);
        orderData.add({
          'Images': item['Images'],
          'Item Name': item['Item Name'],
          'Item Category': item['Item Category'],
          'Price': price * quantity,
          'Quantity': quantity,
          'Address': selectedAddress,
          'Type': item['Type'],
          'Item Description': item['Item Description'],
          'Consists Of': item['Consists Of'],
        });
      }

      Place_order placeOrder = Place_order();
      await placeOrder.PlaceOrder(context, orderData);

      await _clearCart();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => User_home(initialSelectedIndex: 0)),
      );
    } catch (e) {
      print('Error creating order data or placing order: $e');
    }
  }

  Future<void> _clearCart() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    try {
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
      backgroundColor: HexColor('#F5F6FB'),
      bottomNavigationBar: (_cartList.length == 0)
          ? Container(
              height: 100,
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          width: width * 0.55,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 174, 0),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _proceedToCheckout();
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        '₹$_totalPrice',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        'TOTAL',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w100,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Place order',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
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
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            'Cart',
                            style: TextStyle(
                              fontSize: 20,
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
                'No Items In The Cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 10, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _cartList.length,
                            itemBuilder: (context, index) {
                              var item = _cartList[index];
                              int price = item['Price'] is int
                                  ? item['Price']
                                  : int.parse(item['Price']);
                              int quantity = _quantities[index] ?? 1;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
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
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['Item Name'] ?? 'No Name',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(item['Type']),
                                              SizedBox(height: 5),
                                              Text(
                                                "₹${item['Price'] ?? 'N/A'}",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          children: [
                                            Container(
                                              width: 90,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    25, 255, 193, 7),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.orangeAccent),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        if (quantity > 1) {
                                                          _quantities[index] =
                                                              quantity - 1;
                                                          _calculateBasePrice();
                                                        } else {
                                                          _firestore
                                                              .collection(
                                                                  'Users')
                                                              .doc(FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .email)
                                                              .collection(
                                                                  'Cart')
                                                              .doc(item.id)
                                                              .delete();
                                                          getCartItems();
                                                          _quantities[index] =
                                                              0;
                                                          _calculateBasePrice();
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.remove,
                                                          color: Colors
                                                              .orangeAccent,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "$quantity",
                                                    style: TextStyle(
                                                      fontSize: quantity
                                                                  .toString()
                                                                  .length <=
                                                              2
                                                          ? 18
                                                          : 16,
                                                      color:
                                                          Colors.orangeAccent,
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
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.add,
                                                          color: Colors
                                                              .orangeAccent,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "₹${price * quantity}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddressSelectionBottomSheet,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.amber[500],
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Deliver to:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    selectedAddress.isEmpty
                                        ? 'Select your address'
                                        : selectedAddress,
                                    style: TextStyle(
                                      color: selectedAddress.isEmpty
                                          ? Colors.grey[600]
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: s == 1,
                          child: Row(
                            children: [
                              GestureDetector(
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
                                    padding: const EdgeInsets.all(10.0),
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
                                        SizedBox(height: 5),
                                        Text(
                                          'Your usual preparation time',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
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
                                  padding: const EdgeInsets.only(left: 10.0),
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
                                      padding: const EdgeInsets.all(10.0),
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
                                              Text(
                                                '₹ $deliveryCharge ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'We will deliver the item to your location ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orangeAccent),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Add a note to canteen',
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 5, right: 10),
                                child: Icon(Icons.content_paste_rounded),
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                            ),
                            controller: note,
                            maxLines: 3,
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

  void _showAddressSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select an Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.amber[500]),
                title: Text('Block 1'),
                onTap: () {
                  _checkAddress('Block 1');
                  Navigator.pop(context);
                },
                selected: selectedAddress == 'Block 1',
                selectedTileColor:
                    Colors.amber[100], // Highlight color when selected
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.amber[500]),
                title: Text('Block 2'),
                onTap: () {
                  _checkAddress('Block 2');
                  Navigator.pop(context);
                },
                selected: selectedAddress == 'Block 2',
                selectedTileColor:
                    Colors.amber[100], // Highlight color when selected
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.amber[500]),
                title: Text('Block 3'),
                onTap: () {
                  _checkAddress('Block 3');
                  Navigator.pop(context);
                },
                selected: selectedAddress == 'Block 3',
                selectedTileColor:
                    Colors.amber[100], // Highlight color when selected
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.amber[500]),
                title: Text('Block 4'),
                onTap: () {
                  _checkAddress('Block 4');
                  Navigator.pop(context);
                },
                selected: selectedAddress == 'Block 4',
                selectedTileColor:
                    Colors.amber[100], // Highlight color when selected
              ),
            ],
          ),
        );
      },
    );
  }
}
