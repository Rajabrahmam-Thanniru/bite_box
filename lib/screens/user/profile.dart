import 'package:bite_box/screens/Admin/adminhome.dart';
import 'package:bite_box/screens/user/editprofiledetails.dart';
import 'package:bite_box/screens/user/mainHome.dart';
import 'package:bite_box/screens/user/user_home.dart';
import 'package:bite_box/utils/signOut.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? username;
  String? image;
  void initState() {
    super.initState();
    getusername();
  }

  Future<void> getusername() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    _firestore
        .collection('Users')
        .doc(user?.email)
        .collection('userinfo')
        .doc('userinfo')
        .get()
        .then((value) {
      setState(() {
        username = value.data()?['Full Name'];
        image = value.data()?['Profile Image'][0];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Container(
                            width: 70,
                            height: 70,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  )
                                ]),
                            child: Image.network(
                              image ??
                                  "https://imgs.search.brave.com/Jr4F26FmavL_arvWQ51hTUtcX3UgHOWlH0F9fqfo5Cc/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9mcmVl/c3ZnLm9yZy9pbWcv/YWJzdHJhY3QtdXNl/ci1mbGF0LTQucG5n",
                              fit: BoxFit.cover,
                            ),
                          )),
                      Column(
                        children: [
                          Align(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 8, top: 8),
                              child: Text(username ?? "",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 8, bottom: 8),
                            child: Text(
                                FirebaseAuth.instance.currentUser?.email ?? "",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black38)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfileDetails()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 26,
                                color: Colors.black38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 8, top: 8, bottom: 8),
                              child: Text(
                                "Edit Details",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.black12,
                      thickness: 0.5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => User_home(
                                      initialSelectedIndex: 2,
                                    )));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: Icon(
                                Icons.paste_outlined,
                                size: 26,
                                color: Colors.black38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 8, top: 8, bottom: 8),
                              child: Text(
                                "Your Orders",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.black12,
                      thickness: 0.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Icon(
                              Icons.help_outline,
                              size: 26,
                              color: Colors.black38,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 8, top: 8, bottom: 8),
                            child: Text(
                              "FAQ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.black12,
                      thickness: 0.5,
                    ),
                    GestureDetector(
                      onTap: () {
                        handleSignOut(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 15),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: Icon(
                                Icons.logout,
                                size: 26,
                                color: Colors.red,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 8, top: 8, bottom: 8),
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
