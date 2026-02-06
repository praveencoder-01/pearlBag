import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/screens/shop_screen.dart';
import 'package:food_website/widgets/feature_icons_row.dart';
import 'package:food_website/widgets/home_feature_section.dart';
import 'package:food_website/widgets/product_card.dart';
// import 'package:food_website/models/product.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _controller = PageController();
  int _page = 0;
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startScroll();
  }

  void _startScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_scrollController.hasClients) return;
      int nextPage = _page + 1;

      if (nextPage >= 2) {
        nextPage = 0;
      }

      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController, // 🔹 Attach controller
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Popular Categories',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      CategoryChip(
                        image:
                            "assets/images/products/arno-senoner-ooj5VfXq5o8-unsplash.jpg",
                        title: "Potli Bag",
                      ),
                      CategoryChip(
                        image: "assets/images/products/bag1.png",
                        title: "Potli Bag",
                      ),
                      CategoryChip(
                        image:
                            "assets/images/products/gold-zipper-on-black-backpack.png",
                        title: "Potli Bag",
                      ),
                      CategoryChip(
                        image:
                            "assets/images/products/leather-handbag-on-bed.jpg",
                        title: "Potli Bag",
                      ),
                      CategoryChip(
                        image:
                            "assets/images/products/genesis-warner-kNuSOBHBtmA-unsplash.jpg",
                        title: "Potli Bag",
                      ),
                      CategoryChip(
                        image:
                            "assets/images/products/genesis-warner-vSoo12NA9jw-unsplash.jpg",
                        title: "Potli Bag",
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: 2,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PromoCard(
                          title: index == 0
                              ? "Summer Sale 50% OFF"
                              : "New Arrivals",
                          text: index == 0
                              ? "Don't miss out on our biggest sale of the season!"
                              : "Check out the latest collections just for you!",
                          bgColor: index == 0
                              ? const Color(0xFFF2C94C)
                              : const Color(0xFFE9D5FF),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 10),

                // DOT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (i) {
                    final active = _page == i;
                    return AnimatedContainer(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      duration: const Duration(milliseconds: 200),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: active ? Colors.black : Colors.black26,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          SizedBox(height: 25),

          const HomeFeatureSection(),
          // const SizedBox(height: 25),
          const HomeFeatureSectionReverse(),

          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    debugPrint("VIEW EVERYTHING TAPPED");
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const ShopScreen()),
                    );
                  },
                  child: const Text(
                    'VIEW EVERYTHING',
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 5,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(height: 1, width: 240, color: Colors.black),
                const SizedBox(height: 20),
                const FeatureIconsRow(),
              ],
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recommended",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Padding(
  padding: EdgeInsets.all(16),
  child: Text("DEBUG: Recommended widget reached"),
),


          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('isAvailable', isEqualTo: true)
                .limit(6)
                .snapshots(),
            builder: (context, snapshot) {
              // 1) ERROR CHECK (MOST IMPORTANT)
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Firestore Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // 2) LOADING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // 3) EMPTY
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No recommended products found"),
                );
              }

              final products = docs.map((doc) {
                return Product.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                );
              }).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.60,
                ),
                itemBuilder: (_, i) => ProductCard(product: products[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String image;
  final String title;
  const CategoryChip({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            // image: DecorationImage( image: "")
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Image.asset(
              image,
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// class PromoCarousel extends StatefulWidget {
//   const PromoCarousel({super.key});

//   @override
//   State<PromoCarousel> createState() => _PromoCarouselState();
// }

// class _PromoCarouselState extends State<PromoCarousel> {
//   @override
//    Widget build(BuildContext context) {
//     // first add controller

//     //

//   }
// }

class PromoCard extends StatelessWidget {
  final String title;
  final String text;
  final Color bgColor;

  const PromoCard({
    super.key,
    required this.title,
    required this.text,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Text(
                  text,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          Image.asset(
            "assets/images/products/backpack-in-black.png",
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
