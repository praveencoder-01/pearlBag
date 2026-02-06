import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with AutomaticKeepAliveClientMixin {
  bool isVisible = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      key: ValueKey(widget.product.imageUrl),
      onVisibilityChanged: (info) {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: InkWell(
          hoverColor: Colors.transparent,

          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: widget.product),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    // 🖼 Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: RepaintBoundary(
                        child: _buildProductImage(widget.product.imageUrl),
                      ),
                    ),

                    // 🔖 DISCOUNT BADGE
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0XFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '-20% OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),

                    // 🛒 Add to cart (hover)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: IgnorePointer(
                        ignoring: false,
                        child: _AddToCartButton(product: widget.product),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🏷 Name
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 4),

              // 💰 Price
              Text(
                '₹${widget.product.price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildProductImage(String url) {
  if (url.startsWith('http')) {
    return SizedBox(
      height: 150, // ✅ fix height for grid
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      ),
    );
  }

  return SizedBox(
    height: 150,
    width: double.infinity,
    child: Image.asset(
      url,
      fit: BoxFit.cover,
    ),
  );
}


}

class _AddToCartButton extends StatelessWidget {
  final Product product;
  const _AddToCartButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          final userId = FirebaseAuth.instance.currentUser!.uid;
          final cartRef = FirebaseFirestore.instance
              .collection('cart')
              .doc(userId)
              .collection('items')
              .doc(product.id); // unique product ID

          final cartDoc = await cartRef.get();

          if (cartDoc.exists) {
            // If product already in cart, increase quantity
            final currentQty = (cartDoc.data()?['quantity'] ?? 1);
            await cartRef.update({'quantity': currentQty + 1});
          } else {
            // New product add
            await cartRef.set({
              'name': product.name,
              'price': product.price,
              'quantity': 1,
              'imageUrl': product.imageUrl, // ✅ string only
            });
          }

          // Also update local provider (optional)
          final cart = context.read<CartProvider>();
          cart.addToCart(product);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${product.name} added to cart!")),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error adding to cart: $e")));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 245, 235, 206),
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: const Text(
        'ADD TO CART',
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
