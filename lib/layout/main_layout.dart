import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/screens/product_detail_screen.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSearching = false;

  final List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔹 BACKGROUND
        Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(57, 246, 241, 161),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,

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
      ],
    );
  }
}
