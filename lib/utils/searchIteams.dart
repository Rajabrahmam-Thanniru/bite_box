import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Search_Item extends StatefulWidget {
  const Search_Item({super.key});

  @override
  State<Search_Item> createState() => _Search_ItemState();
}

class _Search_ItemState extends State<Search_Item> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: width * 0.7,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: CupertinoSearchTextField(
              focusNode: _searchFocusNode,
              placeholder: 'Search',
              backgroundColor: Colors.white,
              borderRadius: BorderRadius.circular(30),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: Center(), // Add a body to the Scaffold
    );
  }
}
