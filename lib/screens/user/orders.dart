import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Order_screen extends StatefulWidget {
  const Order_screen({super.key});

  @override
  State<Order_screen> createState() => _OrderState();
}

class _OrderState extends State<Order_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('Orders'),
      ),
    );
  }
}
