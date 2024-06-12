import 'package:bite_box/screens/user/food_item_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchSomething {
  Future<void> searchSomethingFun(BuildContext context, String category) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List _cat = [];
    try {
      QuerySnapshot<Map<String, dynamic>> data = await _firestore
          .collection('Menu')
          .where('Item Category', isEqualTo: category)
          .orderBy('Item Name')
          .get();
      _cat = data.docs;
    } catch (e) {
      print('Error fetching menu data: $e');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Details(
          data: _cat,
          cat: category,
        ),
      ),
    );
  }
}
