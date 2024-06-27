import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FcmToken {
  static Future<void> updateToken() async {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final email = user.email;
      var token = await FirebaseFirestore.instance
          .collection('fcmTokens')
          .doc(email)
          .get();

      if (token.exists) {
        await FirebaseFirestore.instance
            .collection('fcmTokens')
            .doc(email)
            .update({'token': fcmToken});
      } else {
        await FirebaseFirestore.instance
            .collection('fcmTokens')
            .doc(email)
            .set({'token': fcmToken});
      }
    }
  }
}
