import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

Future<void> handleSignOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(context, "/LoginPage/", (route) => false);
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error signing out: $error')),
    );
  }
}
