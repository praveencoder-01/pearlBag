import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/widgets/app_navigation.dart';
import 'package:food_website/widgets/product_card.dart';

class ShopScreen extends StatefulWidget {
  final String? initialCategory;
  final String searchQuery;

  const ShopScreen({super.key, this.initialCategory, this.searchQuery = ""});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? "All";
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = _searchCtrl.text.toLowerCase().trim();

    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('isAvailable', isEqualTo: true);

    if (_selectedCategory != "All") {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Top header (optional)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      AppNavigation.tabIndex.value = 0;
                    }, // or AppNavigation.tabIndex.value = 0
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Shop",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
                ],
              ),
            ),

            // ✅ Search bar UI (only UI; actual search logic already in your code)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black45),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: const InputDecoration(
                            hintText: "Search...",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (v) {
                            // ✅ this updates your existing search logic
                            setState(() {});
                          },
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        InkWell(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Category chips row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip("All"),
                    _chip("Handbags"),
                    _chip("Clutch Bags"),
                    _chip("Mini Bags"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Products Grid (aligned)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  var products = docs.map((doc) {
                    return Product.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    );
                  }).toList();

                  // ✅ filter by search
                  if (search.isNotEmpty) {
                    products = products
                        .where((p) => p.name.toLowerCase().contains(search))
                        .toList();
                  }

                  if (products.isEmpty) {
                    return const Center(child: Text("No products found"));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.74, // ✅ aligned grid
                        ),
                    itemBuilder: (_, i) => ProductCard(product: products[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String title) {
    final selected = _selectedCategory == title;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = title),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
