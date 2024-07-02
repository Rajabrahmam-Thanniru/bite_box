import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewItem extends StatefulWidget {
  final dynamic item;
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
  double productRating = 0;

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
        final userinfo = _firestore
            .collection('Users')
            .doc(user?.email)
            .collection('userinfo')
            .doc('userinfo')
            .get();
        String Fullname = "";
        String image = "";
        await userinfo.then((value) {
          Fullname = value.data()!['Full Name'];
          image = value.data()!['Profile Image'][0];
        });
        if (productRating != 0) {
          await _firestore
              .collection('Users')
              .doc(user?.email)
              .collection('orders')
              .doc(widget.item.id)
              .update({
            'Rating Given': true,
            'Stars': productRating,
          });
          await _firestore
              .collection('Menu')
              .doc(widget.item['Item Name'])
              .update({
            'Total Rating': FieldValue.increment(productRating),
            'Rating Count': FieldValue.increment(1),
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please rate the product'),
            ),
          );
        }
        await _firestore
            .collection('Menu')
            .doc(widget.item['Item Name'])
            .collection('reviews')
            .add({
          'review': _reviewController.text,
          'orderId': widget.orderId,
          'timestamp': FieldValue.serverTimestamp(),
          'User Email': user?.email,
          'Stars': productRating,
          'Full Name': Fullname,
          'Profile Image': image,
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Write a Review for ${widget.item['Item Name']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 8.0),
            Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: Row(children: [
                  RatingBar(
                    initialRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                      full: Icon(Icons.star, color: Colors.amber),
                      half: Icon(Icons.star_half_outlined, color: Colors.amber),
                      empty:
                          Icon(Icons.star_border_outlined, color: Colors.grey),
                    ),
                    itemSize: 25,
                    onRatingUpdate: (rating) {
                      setState(() {
                        productRating = rating;
                      });
                    },
                  ),
                ])),
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
