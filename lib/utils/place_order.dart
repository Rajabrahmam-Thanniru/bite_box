import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Place_order {
  Future<void> PlaceOrder(
      BuildContext context, List<Map<String, dynamic>> orderData) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated");
      }

      DocumentReference userDocRef =
          _firestore.collection('Users').doc(user.email);
      CollectionReference ordersCollection = userDocRef.collection('orders');
      CollectionReference adminDocRef = _firestore
          .collection('Admin')
          .doc('biteboxcanteen@gmail.com')
          .collection("Order Requests");

      for (var item in orderData) {
        await ordersCollection.add({
          'ItemImage': item['Images'],
          'itemName': item['Item Name'],
          'category': item['Item Category'],
          'price': item['Price'],
          'quantity': item['Quantity'],
          'orderDate': Timestamp.now(),
          'Status': 'Not Accepted',
        });
        await adminDocRef.add({
          'ItemImage': item['Images'],
          'itemName': item['Item Name'],
          'category': item['Item Category'],
          'price': item['Price'],
          'quantity': item['Quantity'],
          'orderDate': Timestamp.now(),
          'Status': 'Not Accepted',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully')),
      );
    } catch (e) {
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }
}
