import 'package:flutter/material.dart';

class Liked extends StatefulWidget {
  const Liked({super.key});

  @override
  State<Liked> createState() => _LikedState();
}

class _LikedState extends State<Liked> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('liked'),
      ),
    );
  }
}
