import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Push_to_wishlist {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> Pushtowishlist(BuildContext context, List order) async {
    try {
      // Get the currently authenticated user
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated");
      }

      DocumentReference userDocRef =
          _firestore.collection('Users').doc(user.email);
      CollectionReference wishlistCollection =
          userDocRef.collection('wishList');

      for (var item in order) {
        await wishlistCollection.add({
          'Images': item['Images'],
          'Item Name': item['Item Name'],
          'Item Category': item['Item Category'],
          'Price': item['Price'],
          'Type': item['Type'],
          'Item Description': item['Item Description'],
          'Consists Of': item['Consists Of'],
          'Total Rating': item['Total Rating'],
          'Rating Count': item['Rating Count'],
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to wish list: ' + order[0]['Item Name'])),
      );
    } catch (e) {
      print("Error adding to wishlist: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to wishlist: $e')),
      );
    }
  }

  Future<void> delete_item_wishlist(
      BuildContext context, String itemName) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated");
      }

      DocumentReference userDocRef =
          _firestore.collection('Users').doc(user.email);
      CollectionReference wishlistCollection =
          userDocRef.collection('wishList');

      QuerySnapshot querySnapshot = await wishlistCollection
          .where('Item Name', isEqualTo: itemName)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from wish list: ' + itemName)),
      );
    } catch (e) {
      print("Error removing from wishlist: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing from wishlist: $e')),
      );
    }
  }
}
