import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Push_to_cart {
  Future<void> PushtoCart(
    BuildContext context,
    List order,
  ) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      // Get the currently authenticated user
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated");
      }

      DocumentReference userDocRef =
          _firestore.collection('Users').doc(user.email);
      CollectionReference ordersCollection = userDocRef.collection('Cart');

      for (var item in order) {
        await ordersCollection.add({
          'ItemImage': item['Images'],
          'itemName': item['Item Name'],
          'category': item['Item Category'],
          'price': item['Price'],
          'orderDate': Timestamp.now(),
          'Status': 'doing',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(order.length.toString())),
      );
    } catch (e) {
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }
}
