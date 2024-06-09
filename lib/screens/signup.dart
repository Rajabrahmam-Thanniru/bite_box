import 'package:bite_box/provider/google_sign_in.dart';
import 'package:bite_box/screens/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool passwordvisible = true;
  bool isLoading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController reenterpassword = TextEditingController();
  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    reenterpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Image.asset(
                      'assets/images/signup.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, top: 10),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter Your Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    controller: emailcontroller,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                  child: TextField(
                      obscureText: passwordvisible,
                      controller: passwordcontroller,
                      decoration: InputDecoration(
                        hintText: 'Enter Your Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        focusColor: Colors.orange,
                        suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                passwordvisible = !passwordvisible;
                              });
                            },
                            child: Icon(passwordvisible == false
                                ? Icons.visibility
                                : Icons.visibility_off)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                  child: TextField(
                      controller: reenterpassword,
                      obscureText: passwordvisible,
                      decoration: InputDecoration(
                        hintText: 'Re-Enter Your Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        focusColor: Colors.amber,
                        suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                passwordvisible = !passwordvisible;
                              });
                            },
                            child: Icon(passwordvisible == false
                                ? Icons.visibility
                                : Icons.visibility_off)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: emailcontroller.text,
                                password: passwordcontroller.text);
                        await firestore
                            .collection("Users")
                            .doc(emailcontroller.text)
                            .collection("userinfo")
                            .doc("userinfo")
                            .set({
                          "email": emailcontroller.text,
                          "type": "user",
                        });
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        showDialog(
                            context: context,
                            builder: (context) {
                              if (e.code == "channel-error") {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Please enter a valid email address'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              }
                              if (e.code == "weak-password") {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Password should be atleast 6 characters long'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              }
                              if (e.code == "email-already-in-use") {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Email already in use. Please login'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              }
                              if (e.code == "network-request-failed") {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Please check your internet connection'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              }
                              return AlertDialog(
                                title: const Text('Error'),
                                content: Text(e.code),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'))
                                ],
                              );
                            });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30),
                      child: Container(
                          width: width,
                          height: 50,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(80, 0, 0, 0),
                                blurRadius: 3.0,
                                spreadRadius: 0.0,
                                offset: const Offset(0.0, 3.0),
                              )
                            ],
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber,
                                const Color.fromARGB(255, 234, 175, 0)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Sign Up',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, right: 30, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/LoginPage/');
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text("or Signup with...",
                        style: TextStyle(color: Colors.black54, fontSize: 16))),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        // Access the GoogleSignInProvider without rebuilding the widget tree
                        final provider = Provider.of<GoogleSignInProvider>(
                            context,
                            listen: false);

                        // Show a loading indicator while the login process is ongoing
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              Center(child: CircularProgressIndicator()),
                        );

                        // Attempt to log in with Google and await completion
                        await provider.googleLogin();

                        // Remove the loading indicator once login is complete
                        Navigator.of(context).pop();

                        // Get the current user's email
                        User? user = FirebaseAuth.instance.currentUser;
                        String? email = user?.email;

                        // Navigate based on the email
                        if (email == "biteboxcanteen@gmail.com") {
                          // Redirect to Admin Home
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/AdminHome/', (route) => false);
                        } else if (email == null) {
                          // Handle the case where email is null (user not logged in properly)
                          print('User email is null');
                          // Show a SnackBar with the error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Sign-In failed. Please try again.')),
                          );
                        } else {
                          // Redirect to User Home
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/UserHome/', (route) => false);
                        }
                      } on Exception catch (e) {
                        // Print the exception and provide user feedback
                        print('Error during Google Sign-In: $e');

                        // Remove the loading indicator in case of error
                        Navigator.of(context).pop();

                        // Show a SnackBar with the error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Sign-In failed. Please try again.')),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30),
                      child: Container(
                          width: width,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: const Color.fromARGB(123, 0, 0, 0),
                                width: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  'assets/images/google.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              const Text('Continue with Google',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w100)),
                            ],
                          )),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
