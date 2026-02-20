import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:food_website/widgets/app_navigation.dart';
import 'package:food_website/widgets/feature_icons_row.dart';
import 'package:food_website/widgets/home_feature_section.dart';
import 'package:food_website/widgets/product_card.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _controller = PageController();
  int page = 0;
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _pageNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _startScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _pageNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startScroll() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_controller.hasClients) return;

      final current = _pageNotifier.value;
      final nextPage = (current + 1) % 2; // 2 = itemCount

      _pageNotifier.value = nextPage; // keep state in sync immediately

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
                Text(
                  'Popular Categories',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),

                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    // padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  height: 130,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: 2,
                    onPageChanged: (i) => _pageNotifier.value = i,

                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),

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
                ValueListenableBuilder<int>(
                  valueListenable: _pageNotifier,
                  builder: (_, page, __) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (i) {
                        final active = page == i;
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
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 25),

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

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('isAvailable', isEqualTo: true)
                .limit(10)
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
                final data = doc.data() as Map<String, dynamic>;

                return Product.fromMap(doc.id, data);
              }).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.74,
                ),
                itemBuilder: (_, i) => ProductCard(product: products[i]),
              );
            },
          ),

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
                    AppNavigation.tabIndex.value = 1;
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
            color: AppColors.card,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
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
