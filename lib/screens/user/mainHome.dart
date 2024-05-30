import 'package:flutter/material.dart';

class MainUserHome extends StatefulWidget {
  const MainUserHome({super.key});

  @override
  State<MainUserHome> createState() => _MainUserHomeState();
}

class _MainUserHomeState extends State<MainUserHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('mainHome'),
      ),
    );
  }
}
