import 'package:bite_box/utils/Hexcode.dart';
import 'package:bite_box/utils/Search_something.dart';
import 'package:bite_box/utils/place_order.dart';
import 'package:bite_box/utils/signOut.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class MainUserHome extends StatefulWidget {
  const MainUserHome({super.key});

  @override
  State<MainUserHome> createState() => _MainUserHomeState();
}

class _MainUserHomeState extends State<MainUserHome> {
  SearchSomething searchSomething = SearchSomething();
  List<String> featured = [];
  List<String> featuredImages = [];
  List<int> featuredPrices = [];
  Map<int, int> tapval = {};
  late VideoPlayerController _controller;

  Place_order po = Place_order();

  @override
  void initState() {
    super.initState();
    _setFeaturedItems();
    _controller = VideoPlayerController.asset('assets/images/banner_video.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _controller.setLooping(true);
        });
      });
  }

  @override
  void dispose() {
    DefaultCacheManager().emptyCache();
    _controller.dispose();
    super.dispose();
  }

  void _setFeaturedItems() {
    final time = TimeOfDay.now();
    final isMorning = time.hour < 11;

    final newFeatured = isMorning
        ? ["Masala Dosa", "Idly", "Vada", "Bonda"]
        : [
            "Chicken Biriyani",
            "Chicken Fried Rice",
            "Veg Manchuria",
            "Chicken Noodles"
          ];
    final newFeaturedImages = isMorning
        ? [
            "assets/images/Dosa.png",
            "assets/images/Idli.png",
            "assets/images/vada.png",
            "assets/images/bonda.png"
          ]
        : [
            "assets/images/biriyani.png",
            "assets/images/fried rice.png",
            "assets/images/Manchuria.png",
            "assets/images/noodles.png"
          ];
    final newFeaturedPrices = isMorning ? [40, 30, 40, 40] : [130, 90, 60, 80];

    setState(() {
      featured = newFeatured;
      featuredImages = newFeaturedImages;
      featuredPrices = newFeaturedPrices;
      tapval.clear();
      for (var i = 0; i < featuredImages.length; i++) {
        tapval[i] = 0;
      }
    });
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final categorySnapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .doc('Categories Images')
          .get();
      return categorySnapshot.data() ?? {};
    } catch (e) {
      return {};
    }
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
                    Center(child: const CircularProgressIndicator()),
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

  Widget _buildFeaturedItem(String item, String image, int price, int i) {
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
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 100,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(image),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹ $price',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black12,
                    thickness: 0.5,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (tapval[i] == 0) {
                              tapval[i] = 1;
                              searchSomething.searchSomethingFun(
                                  context, item, 1);
                            } else {
                              tapval[i] = 0;
                              searchSomething.searchSomethingFun(
                                  context, item, 2);
                            }
                          });
                        },
                        child: Container(
                          width: (tapval[i] == 1) ? 90 : 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orangeAccent),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            child: Center(
                              child: (tapval[i] == 1)
                                  ? Text(
                                      'Added',
                                      style:
                                          TextStyle(color: Colors.orangeAccent),
                                    )
                                  : Text(
                                      'Add +',
                                      style:
                                          TextStyle(color: Colors.orangeAccent),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 254, 248),
      body: RefreshIndicator(
        onRefresh: () async {
          _setFeaturedItems();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  handleSignOut(context);
                },
                child: Container(
                  width: width,
                  height: 220,
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : Center(child: CircularProgressIndicator()),
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
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final categories = snapshot.data!.keys.toList();
                    final categoriesImages =
                        snapshot.data!.values.cast<String>().toList();
                    return Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              await searchSomething.searchSomethingFun(
                                  context, categories[index], 0);
                            },
                            child: _buildCategoryItem(
                                categories[index], categoriesImages[index]),
                          );
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
                physics: const NeverScrollableScrollPhysics(),
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  return _buildFeaturedItem(
                    featured[index],
                    featuredImages[index],
                    featuredPrices[index],
                    index,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
