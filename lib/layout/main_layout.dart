import 'package:flutter/material.dart';
import 'package:food_website/data/dummy_images.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/providers/drawer_provider.dart';
import 'package:food_website/screens/product_detail_screen.dart';
import 'package:food_website/widgets/site_drawer_left.dart';
import 'package:food_website/widgets/site_drawer_right.dart';
import 'package:food_website/widgets/site_header.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSearching = false;

  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  void _onSearch(String value) {
    setState(() {
      _filteredProducts = dummyProducts
          .where((p) => p.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drawer = context.watch<DrawerProvider>();

    return Stack(
      children: [
        // 🔹 BACKGROUND
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF2BC0E4), Color(0xFFEAECC6)],
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,

          // 🔹 HEADER
          appBar: SiteHeader(
            onSearchChanged: (value) {
              setState(() => _isSearching = value);
            },
          ),

          // 🔹 PAGE CONTENT (opacity here)
          body: Opacity(opacity: _isSearching ? 0.4 : 1, child: widget.child),
        ),

        if (_isSearching)
          Stack(
            children: [
              // 🔹 OUTSIDE CLICK AREA (transparent)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      _filteredProducts.clear();
                    });
                  },
                ),
              ),

              // 🔹 SEARCH POPUP (safe area)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 8,
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                      left: 200,
                      right: 200,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔍 SEARCH BAR
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  onChanged: _onSearch,
                                  decoration: const InputDecoration(
                                    hintText: 'Search products...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _searchController.clear(); // ✅ text clear
                                    _filteredProducts
                                        .clear(); // ✅ results clear
                                  });
                                },
                                child: const Text('✕'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_searchController.text.isNotEmpty)
                          SizedBox(
                            height: 300,
                            child: _filteredProducts.isEmpty
                                ? const Center(child: Text('No products found'))
                                : ListView.builder(
                                    itemCount: _filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = _filteredProducts[index];
                                      return ListTile(
                                        leading: Image.asset(product.imageUrl),
                                        title: Text(product.name),
                                        subtitle: Text('₹${product.price}'),
                                        onTap: () {
                                          setState(() {
                                            _isSearching = false;
                                            _searchController.clear();
                                            _filteredProducts.clear();
                                          });

                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProductDetailScreen(
                                                    product: product,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

        // 🔹 CLOSE DRAWER OVERLAY
        if (drawer.isAnyOpen)
          GestureDetector(
            onTap: () => drawer.closeAll(),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

        const SiteDrawerLeft(),
        const SiteDrawerRight(),
      ],
    );
  }
}
