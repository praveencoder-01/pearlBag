import 'package:flutter/material.dart';
import 'package:food_website/data/dummy_images.dart';
import 'package:food_website/layout/main_layout.dart';
// import 'package:food_website/data/products.dart';
import 'package:food_website/widgets/product_card.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: CustomScrollView(
        slivers: [
          // 🔹 TITLE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 100, bottom: 40),
              child: Column(
                children: const [
                  Text(
                    'EVERYTHING',
                    style: TextStyle(
                      fontSize: 28,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  // SizedBox(width: 120, child: Divider(thickness: 1)),
                ],
              ),
            ),
          ),

          // 🔹 PRODUCTS GRID
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = dummyProducts [index];

                return ProductCard(product: product);
              }, childCount: dummyProducts .length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 8,
                childAspectRatio: 1.15,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
