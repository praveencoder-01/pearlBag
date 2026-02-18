import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/screens/cart_screen.dart';
import 'package:food_website/widgets/wishlist_service.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ✅ Firestore whereIn limit = 10, so we fetch in batches
  Future<List<Product>> _fetchProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final productsRef = FirebaseFirestore.instance.collection('products');
    final List<Product> result = [];

    // chunk ids into groups of 10
    for (int i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, (i + 10 > ids.length) ? ids.length : i + 10);

      final snap = await productsRef
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snap.docs) {
        result.add(Product.fromMap(doc.id, doc.data()));
      }
    }

    // keep same order as wishlist ids
    final map = {for (final p in result) p.id: p};
    final ordered = ids
        .where((id) => map.containsKey(id))
        .map((id) => map[id]!)
        .toList();
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to see wishlist")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Row(
                children: [
                  _circleIcon(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),

                  // Search row + cart button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black38),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search...",
                                ),
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
                                  color: Colors.black38,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 12),
                  // const Spacer(),
                  Consumer<CartProvider>(
                    builder: (_, cart, __) {
                      return Stack(
                        children: [
                          _circleIcon(
                            icon: Icons.shopping_bag_outlined,
                            filled: true,
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              );
                            },
                          ),

                          if (cart.totalItemsQty > 0)
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  cart.items.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Wishlist",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
            ),

            // ✅ Wishlist stream -> product fetch -> list
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: WishlistService.wishlistIdsStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final ids = snap.data ?? [];

                  if (ids.isEmpty) {
                    return const Center(child: Text("Your wishlist is empty"));
                  }

                  return FutureBuilder<List<Product>>(
                    future: _fetchProductsByIds(ids),
                    builder: (context, psnap) {
                      if (psnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final products = psnap.data ?? [];

                      // search filter
                      final q = _searchCtrl.text.toLowerCase().trim();
                      final filtered = q.isEmpty
                          ? products
                          : products.where((p) {
                              final name = p.name.toLowerCase();
                              final cat = p.category.toLowerCase();
                              return name.contains(q) || cat.contains(q);
                            }).toList();

                      if (filtered.isEmpty) {
                        return const Center(child: Text("No items found"));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, i) => _WishCardFirebase(
                          product: filtered[i],
                          onRemove: () async {
                            await WishlistService.remove(filtered[i].id);
                          },
                          onAddToCart: () async {
                            final p = filtered[i];
                            final cart = context.read<CartProvider>();

                            // ✅ Add 1 qty to cart
                            await cart.addToCart(p.copyWith(quantity: 1));

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${p.name} added to cart"),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            // ✅ Optional: remove from wishlist after adding
                            await WishlistService.remove(p.id);
                          },
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
    );
  }

  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: Colors.black12),
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
    );
  }
}

class _WishCardFirebase extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;

  const _WishCardFirebase({
    required this.product,
    required this.onAddToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final img = product.imageUrl;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 80,
              width: 80,
              color: Colors.black12,
              child: img.isEmpty
                  ? const Icon(Icons.image_not_supported_outlined)
                  : Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported_outlined),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Text(
                      "Add to cart",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
