import 'package:flutter/material.dart';

class MainAdminHome extends StatefulWidget {
  const MainAdminHome({super.key});

  @override
  State<MainAdminHome> createState() => _MainAdminHomeState();
}

class _MainAdminHomeState extends State<MainAdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Admin Home")));
  }
}
