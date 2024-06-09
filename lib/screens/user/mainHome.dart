import 'package:bite_box/utils/Hexcode.dart';
import 'package:bite_box/utils/signOut.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MainUserHome extends StatefulWidget {
  const MainUserHome({super.key});

  @override
  State<MainUserHome> createState() => _MainUserHomeState();
}

class _MainUserHomeState extends State<MainUserHome> {
  List<String> featured = [];
  List<String> featuredimages = [];

  @override
  void initState() {
    super.initState();
    _setFeaturedItems();
  }

  @override
  void dispose() {
    DefaultCacheManager().emptyCache();
    super.dispose();
  }

  void _setFeaturedItems() {
    final time = TimeOfDay.now();
    final isMorning = time.hour < 11;

    final newFeatured = isMorning
        ? ["Dosa", "Idly", "Vada", "Bonda"]
        : [
            "Chicken Biriyani",
            "Chicken Fried Rice",
            "Veg Manchuria",
            "Chicken Noodles"
          ];
    final featuredimages2 = isMorning
        ? [""]
        : [
            "assets/images/biriyani.png",
            "assets/images/fried rice.png",
            "assets/images/Manchuria.png",
            "assets/images/noodles.png"
          ];

    if (featured != newFeatured) {
      setState(() {
        featured = newFeatured;
      });
    }
    if (featuredimages != featuredimages2) {
      setState(() {
        featuredimages = featuredimages2;
      });
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    final categorySnapshot = await FirebaseFirestore.instance
        .collection('Categories')
        .doc('Categories Images')
        .get();
    return categorySnapshot.data() ?? {};
  }

  Widget _buildCategoryItem(String category, String imageUrl) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            color: HexColor('#EEEEEE'),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Padding(
              padding: category == "Soft drinks"
                  ? const EdgeInsets.all(18.0)
                  : const EdgeInsets.all(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                key: UniqueKey(),
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        Text(
          category,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 169, 127, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedItem(String item, String image) {
    final width = MediaQuery.of(context).size.width;

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: width * 0.9,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 100,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  const SizedBox(height: 10),
                ],
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          _setFeaturedItems();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    handleSignOut(context);
                  },
                  child: Container(
                    width: width * 0.98,
                    height: 220,
                    color: Colors.black,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    final categories = snapshot.data!.keys.toList();
                    final categoriesImages =
                        snapshot.data!.values.cast<String>().toList();
                    return Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryItem(
                              categories[index], categoriesImages[index]);
                        },
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('No categories found.'),
                    );
                  }
                },
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    'Featured',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  return _buildFeaturedItem(
                      featured[index], featuredimages[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
