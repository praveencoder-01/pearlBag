import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
// import 'package:food_website/providers/product_provider.dart';
// import 'package:provider/provider.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _controller = TextEditingController();

  late List<Product> allProducts;
  List<Product> filtered = [];

  @override
  void initState() {
    super.initState();

    // 🔹 GET PRODUCTS FROM PROVIDER
    // allProducts = context.read<ProductProvider>().products;

    filtered = allProducts;

    _controller.addListener(_search);
  }

  void _search() {
    final query = _controller.text.toLowerCase();

    setState(() {
      filtered = allProducts.where((p) {
        return p.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // 🔍 SEARCH FIELD
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search momo...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),

              const SizedBox(height: 16),

              // 📦 RESULTS
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, index) {
                          final product = filtered[index];

                          return ListTile(
                            leading: Image.asset(
                              product.cartImage,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                            title: Text(product.name),
                            subtitle: Text('₹${product.price}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
