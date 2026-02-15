import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/widgets/product_card.dart';

class ShopScreen extends StatefulWidget {
   final String? initialCategory;
  final String searchQuery;

  const ShopScreen({super.key, this.initialCategory, this.searchQuery = ""});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// PRODUCTS GRID (next step)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('isAvailable', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              /// ERROR
              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              }

              /// LOADING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              /// DATA
              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(child: Text("No products found"));
              }

              var products = docs.map((doc) {
                return Product.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                );
              }).toList();

               // ✅ FILTER BY SEARCH
        if (widget.searchQuery.isNotEmpty) {
          products = products
              .where((p) => p.name.toLowerCase().contains(widget.searchQuery))
              .toList();
        }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.74,
                ),
                itemBuilder: (_, i) => ProductCard(product: products[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}
