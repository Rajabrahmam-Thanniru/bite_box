import 'package:bite_box/utils/searchIteams.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final FocusNode _searchFocusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CupertinoSearchTextField(
                    focusNode: _searchFocusNode,
                    placeholder: 'Search',
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    onChanged: (value) {
                      setState(() {
                        _search(value);
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Text(_searchResults.length.toString()),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchResults[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _search(String value) async {
    _searchResults.clear();
    try {
      await _firestore
          .collection('Menu')
          .where('Item Name', isGreaterThanOrEqualTo: value)
          .where('Item Name', isLessThanOrEqualTo: value + '\uf8ff')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          _searchResults.add(element.get('Item Name'));
        });
        setState(() {});
      });
    } catch (e) {
      print('Error: $e');
    }
  }
}
