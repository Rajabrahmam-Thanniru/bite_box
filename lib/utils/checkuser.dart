import 'package:bite_box/screens/Admin/adminhome.dart';
import 'package:bite_box/screens/signup.dart';
import 'package:bite_box/screens/user/user_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckUser extends StatefulWidget {
  const CheckUser({Key? key}) : super(key: key);

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => checkUserType());
  }

  void checkUserType() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.email == "biteboxcanteen@gmail.com") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AdminHome(
                    initialSelectedIndex: 0,
                  )),
        );
      } else {
        try {
          var snapshot = await FirebaseFirestore.instance
              .collection("Users")
              .doc(user.email)
              .collection('userinfo')
              .doc('userinfo')
              .get();
          if (snapshot.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const User_home(
                  initialSelectedIndex: 0,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignUp()),
            );
          }
        } catch (e) {
          print("Error checking user type: $e");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUp()),
          );
        }
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 100,
          height: 100,
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }
}
