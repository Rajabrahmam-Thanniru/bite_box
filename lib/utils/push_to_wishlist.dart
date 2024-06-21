import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Push_to_wishlist {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> Pushtowishlist(
    BuildContext context,
    List order,
  ) async {
    try {
      // Get the currently authenticated user
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated");
      }

      DocumentReference userDocRef =
          _firestore.collection('Users').doc(user.email);
      CollectionReference ordersCollection = userDocRef.collection('wishList');

      for (var item in order) {
        await ordersCollection.add({
          'Images': item['Images'],
          'Item Name': item['Item Name'],
          'Item Category': item['Item Category'],
          'Price': item['Price'],
          'Type': item['Type'],
          'Item Description': item['Item Description'],
          'Consists Of': item['Consists Of'],
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

  Future<void> delete_item_wishlist(
    BuildContext context,
    String item,
  ) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated");
    }
    DocumentReference userDocRef =
        _firestore.collection('Users').doc(user.email);
    CollectionReference cartCollection = userDocRef.collection('wishList');

    QuerySnapshot<Object?> cartItems = await cartCollection.get();

    for (var doc in cartItems.docs) {
      if (doc['Item Name'].toString().replaceAll(' ', '').toLowerCase() ==
          item.replaceAll(' ', '').toLowerCase()) {
        await doc.reference.delete();
      }
    }
  }
}
