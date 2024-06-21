import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AdminRevenue extends StatefulWidget {
  const AdminRevenue({super.key});

  @override
  _AdminRevenueState createState() => _AdminRevenueState();
}

class _AdminRevenueState extends State<AdminRevenue> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _totalRevenue = 0.0;
  Map<String, double> itemrevenue = {};
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    calculateRevenue();
  }

  Future<void> calculateRevenue() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> data = await _firestore
          .collection('Admin')
          .doc(user?.email)
          .collection('Orders')
          .get();

      double revenue = 0.0;
      Map<String, double> tempItemRevenue = {};

      for (var doc in data.docs) {
        double price =
            (doc['price'] ?? 0).toDouble(); // Convert price to double
        revenue += price;

        String itemName = doc['itemName'];
        tempItemRevenue[itemName] ??= 0.0; // Initialize if null
        tempItemRevenue[itemName] =
            (tempItemRevenue[itemName] ?? 0.0) + price; // Safe addition
      }

      setState(() {
        _totalRevenue = revenue;
        itemrevenue = tempItemRevenue;
        _filteredItems = itemrevenue.keys
            .toList(); // Initialize filtered items with all keys
      });
    } catch (e) {
      print('Error calculating revenue: $e');
    }
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = itemrevenue.keys
          .where((itemName) => itemName.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total Revenue',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '₹ ${NumberFormat('#,##0.00').format(_totalRevenue)}',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Item Wise Revenue',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search item...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _filterItems();
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    String key = _filteredItems[index];
                    return ListTile(
                      title: Text(
                        key,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '₹ ${NumberFormat('#,##0.00').format(itemrevenue[key])}',
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
