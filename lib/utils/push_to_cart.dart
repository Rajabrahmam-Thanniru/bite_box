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
          'Images': item['Images'],
          'Item Name': item['Item Name'],
          'Item Category': item['Item Category'],
          'Price': item['Price'],
          'orderDate': Timestamp.now(),
          'Item Description': item['Item Description'],
          'Type': item['Type'],
          'Status': 'doing',
          'Consists Of': item['Consists Of'],
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart: ' + order[0]['Item Name'])),
      );
    } catch (e) {
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }
}
