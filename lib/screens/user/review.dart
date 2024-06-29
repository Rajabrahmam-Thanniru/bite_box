import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewItem extends StatefulWidget {
  final String item;
  final String orderId;

  const ReviewItem({
    Key? key,
    required this.item,
    required this.orderId,
  }) : super(key: key);

  @override
  State<ReviewItem> createState() => _ReviewItem();
}

class _ReviewItem extends State<ReviewItem> {
  final TextEditingController _reviewController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.isNotEmpty) {
      // Save the review to Firestore
      try {
        final FirebaseAuth _auth = FirebaseAuth.instance;
        User? user = _auth.currentUser;
        await _firestore
            .collection('Menu')
            .doc(widget.item)
            .collection('reviews')
            .add({
          'review': _reviewController.text,
          'orderId': widget.orderId,
          'timestamp': FieldValue.serverTimestamp(),
          'User Email': user?.email,
        });

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit review: $e')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a review')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context)
          .viewInsets, // This will help to adjust for keyboard
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Write a Review for ${widget.item}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(hintText: 'Enter your review here'),
              maxLines: 3,
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _submitReview,
                  child: Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
