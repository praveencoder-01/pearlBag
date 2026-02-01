import 'package:flutter/material.dart';
import 'package:food_website/screens/all_products_screen.dart';
import 'package:food_website/widgets/category_blob_card.dart';
import 'package:food_website/widgets/feature_icons_row.dart';
import 'package:food_website/widgets/hero_video.dart';
import 'package:food_website/widgets/home_feature_section.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  // 🔹 Define ScrollController here
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController, // 🔹 Attach controller
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 90.0, bottom: 20),
                      child: Text(
                        'Style That You Can Carry',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Handcrafted with love for,\n"
                      "everyday elegance.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),

          const HeroVideo(),

          Padding(
            padding: const EdgeInsets.all(100.0),
            child: Center(
              child: Text(
                "We are happy to have you here. Our store is dedicated to creating beautiful, high-quality handmade purses specially designed for women. Every purse is carefully crafted by skilled hands using premium materials, love, and attention to detail.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const HomeFeatureSection(),
          // const SizedBox(height: 25),
          const HomeFeatureSectionReverse(),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 120),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;

                return isDesktop
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          CategoryBlobCard(
                            imagePath:
                                'assets/images/home/bag-removebg-preview.png',
                            title: 'snacks',
                            background: Color(0xFFEFE3D3),
                          ),
                          SizedBox(width: 12),
                          CategoryBlobCard(
                            imagePath:
                                'assets/images/home/bag2-removebg-preview.png',
                            title: 'merch',
                            background: Color(0xFFF4D7B6),
                          ),
                          SizedBox(width: 12),
                          CategoryBlobCard(
                            imagePath:
                                'assets/images/home/bag3-removebg-preview.png',
                            title: 'teas',
                            background: Color(0xFFDCE6E1),
                          ),
                        ],
                      )
                    : Column(
                        children: const [
                          CategoryBlobCard(
                            imagePath:
                                'assets/images/home/bag-removebg-preview.png',
                            title: 'snacks',
                            background: Color(0xFFEFE3D3),
                          ),
                          SizedBox(height: 22),
                          CategoryBlobCard(
                            imagePath:
                                'assets/images/home/bag2-removebg-preview.png',
                            title: 'merch',
                            background: Color(0xFFF4D7B6),
                          ),
                          SizedBox(height: 22),
                          CategoryBlobCard(
                            imagePath:
                                'assets/images/home/bag3-removebg-preview.png',
                            title: 'teas',
                            background: Color(0xFFDCE6E1),
                          ),
                        ],
                      );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    debugPrint("VIEW EVERYTHING TAPPED");
                    Navigator.of(context, rootNavigator: true).push(
  MaterialPageRoute(builder: (_) => const AllProductsScreen()),
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
                const SizedBox(height: 200),
                const FeatureIconsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
