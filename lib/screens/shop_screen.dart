import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/widgets/app_navigation.dart';
import 'package:food_website/widgets/filter_bottom_sheet.dart';
import 'package:food_website/widgets/product_card.dart';

class ShopScreen extends StatefulWidget {
  final String? initialCategory;
  final String searchQuery;

  const ShopScreen({
    super.key,
    this.initialCategory,
    required this.searchQuery,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  RangeValues _selectedPrice = const RangeValues(0, 1750);
  String _selectedSort = "New Today";
  int _selectedRating = 5;
  String _selectedCategory = "All";
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    debugPrint("SHOP: initState searchQuery='${widget.searchQuery}'");
    _selectedCategory = widget.initialCategory ?? "All";
    _searchController.text = widget.searchQuery;
    _searchText = widget.searchQuery.toLowerCase().trim();

    _searchController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() {
          _searchText = _searchController.text.toLowerCase().trim();
        });
      });
    });
  }


  @override
void didUpdateWidget(covariant ShopScreen oldWidget) {
  super.didUpdateWidget(oldWidget);
    debugPrint("SHOP: didUpdateWidget old='${oldWidget.searchQuery}' new='${widget.searchQuery}'");

  // ✅ jab Home se new query aaye, ShopScreen update karo
  if (oldWidget.searchQuery != widget.searchQuery) {
    final q = widget.searchQuery.trim();

    // controller ko bhi update karo
    _searchController.text = q;

    // cursor end pe le jao (optional but feels correct)
    _searchController.selection = TextSelection.collapsed(offset: q.length);

    // _searchText update + rebuild
    setState(() {
      _searchText = q.toLowerCase();
    });
    debugPrint("SHOP: applied new query -> _searchText='$_searchText'");
  }

  // (optional) agar category bhi update hoti ho future me
  if (oldWidget.initialCategory != widget.initialCategory &&
      widget.initialCategory != null) {
    setState(() {
      _selectedCategory = widget.initialCategory!;
    });
  }
}

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final search = _searchText;
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('isAvailable', isEqualTo: true);

    // if (_selectedCategory != "All") {
    //   query = query.where('category', isEqualTo: _selectedCategory);
    // }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => AppNavigation.tabIndex.value = 0,
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
                  IconButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet<FilterResult>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => FilterBottomSheet(
                          initialCategory: _selectedCategory,
                          initialPrice: _selectedPrice,
                          initialSort: _selectedSort,
                          initialRating: _selectedRating,
                        ),
                      );

                      if (result == null) return;

                      setState(() {
                        _selectedCategory = result.category;
                        _selectedPrice = result.price;
                        _selectedSort = result.sort;
                        _selectedRating = result.rating;
                      });
                    },
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),

            // ✅ Search bar (CLICKABLE)
            Padding(
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
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search products...",
                        ),
                      ),
                    ),

                    if (_searchText.isNotEmpty)
                      InkWell(
                        onTap: () {
                          _searchController.clear(); // ✅ same controller clear
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

            const SizedBox(height: 12),

            // ✅ Category chips
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

            // ✅ Products
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
                  // ✅ category filter (LOCAL)
                  if (_selectedCategory != "All") {
                    final selected = _selectedCategory.toLowerCase().trim();
                    products = products.where((p) {
                      final c = (p.category).toLowerCase().trim();
                      return c.contains(selected) || selected.contains(c);
                    }).toList();
                  }

                  // ✅ PRICE FILTER (LOCAL)
                  products = products.where((p) {
                    final price = (p.price).toDouble(); // ensure double
                    return price >= _selectedPrice.start &&
                        price <= _selectedPrice.end;
                  }).toList();

                  // ✅ search filter
                  if (_searchText.isNotEmpty) {
                    products = products
                        .where(
                          (p) => p.name.toLowerCase().contains(_searchText),
                        )
                        .toList();
                  }
debugPrint("SHOP: products after filters = ${products.length}, search='$_searchText', category='$_selectedCategory'");

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
                          childAspectRatio: 0.74,
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
