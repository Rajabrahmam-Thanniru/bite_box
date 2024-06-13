import 'package:bite_box/screens/user/food_item_details.dart';
import 'package:bite_box/utils/place_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchSomething {
  Future<void> searchSomethingFun(
      BuildContext context, String category, int val) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List _cat = [];
    Place_order po = Place_order();
    try {
      if (val == 0) {
        QuerySnapshot<Map<String, dynamic>> data = await _firestore
            .collection('Menu')
            .where('Item Category', isEqualTo: category)
            .orderBy('Item Name')
            .get();
        _cat = data.docs;
      } else {
        QuerySnapshot<Map<String, dynamic>>
            data = /*await _firestore
            .collection('Menu')
            .where('Item Name', isEqualTo: category)
            .orderBy('Item Name')
            .get();*/
            await _firestore.collection('Menu').orderBy('Item Name').get();
        _cat = data.docs;
      }
    } catch (e) {
      print('Error fetching menu data: $e');
    }

    if (val == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Details(
            data: _cat,
            cat: category,
          ),
        ),
      );
    } else {
      List _order = [];
      for (var i = 0; i < _cat.length; i++) {
        if (_cat[i]['Item Name']
            .toString()
            .toLowerCase()
            .contains(category.toLowerCase())) {
          _order.add(_cat[i]);
        }
      }
      po.PlaceOrder(context, _order);
    }
  }
}
