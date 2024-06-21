import 'package:bite_box/screens/user/food_item_details.dart';
import 'package:bite_box/screens/user/show_item_details.dart';
import 'package:bite_box/utils/push_to_cart.dart';
import 'package:bite_box/utils/push_to_wishlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchSomething {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> searchSomethingFun(
      BuildContext context, String category, int val) async {
    List _cat = [];

    Push_to_cart p = Push_to_cart();
    Push_to_wishlist pw = Push_to_wishlist();
    int a = 0;
    try {
      if (val == 0) {
        QuerySnapshot<Map<String, dynamic>> data = await _firestore
            .collection('Menu')
            .where('Item Category', isEqualTo: category)
            .orderBy('Item Name')
            .get();
        _cat = data.docs;
      } else {
        QuerySnapshot<Map<String, dynamic>> data =
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
    } else if (val == 1 || val == 2 || val == 4) {
      List _order = [];
      for (var i = 0; i < _cat.length; i++) {
        if (_cat[i]['Item Name']
            .toString()
            .toLowerCase()
            .contains(category.toLowerCase())) {
          _order.add(_cat[i].data() as Map<String, dynamic>);
          a = 1;
        } else {
          a = 0;
        }
      }
      if (val == 1) {
        p.PushtoCart(context, _order);
      } else if (val == 2) {
        pw.Pushtowishlist(context, _order);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Item_details(item: _order[0], a: a)),
        );
      }
    }
  }

  Future<void> delete_item_Cart(BuildContext context, String category) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated");
    }
    DocumentReference userDocRef =
        _firestore.collection('Users').doc(user.email);
    CollectionReference cartCollection = userDocRef.collection('Cart');

    QuerySnapshot<Object?> cartItems = await cartCollection.get();

    for (var doc in cartItems.docs) {
      if (doc['itemName'].toString().toLowerCase() == category.toLowerCase()) {
        await doc.reference.delete();
      }
    }

    QuerySnapshot<Object?> updatedCartItems = await cartCollection.get();
    if (updatedCartItems.docs.isEmpty) {
      await cartCollection.doc().delete();
    }
  }
}
