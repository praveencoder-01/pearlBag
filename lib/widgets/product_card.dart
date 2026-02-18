import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/providers/wishlist_provider.dart';
import 'package:food_website/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
// import 'package:food_website/widgets/wishlist_service.dart';
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
  void initState() {
    super.initState();
    _loadWishlistState();
  }

  Future<void> _loadWishlistState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        // _isWishlisted = false;
        // _loadingWish = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      key: ValueKey(widget.product.id),
      onVisibilityChanged: (info) {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: InkWell(
          hoverColor: Colors.transparent,

          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: widget.product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // IMAGE + HEART
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      
                      child: RepaintBoundary(
                        
                        child: _buildProductImage(widget.product.imageUrl),
                      ),
                    ),

                    Positioned(
                      top: 10,
                      right: 10,
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, _) {
                          final isWishlisted = wishlist.isWishlisted(
                            widget.product.id,
                          );

                          return InkWell(
                            onTap: () {
                              wishlist.toggle(widget.product.id);
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: isWishlisted
                                    ? Colors.black
                                    : Colors.black87,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // TEXT PART (NOW INSIDE CARD)
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text(
                        '₹${widget.product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  

  Widget _buildProductImage(String url) {
    final cleanUrl = url.trim();

    // ✅ 1) empty url guard (prevents Image.asset(""))
    if (cleanUrl.isEmpty) {
      return const SizedBox(
        height: 150,
        width: double.infinity,
        child: Center(child: Icon(Icons.image_not_supported)),
      );
    }

    // ✅ 2) network image
    if (cleanUrl.startsWith('http')) {
      return SizedBox(
        height: 150,
        width: double.infinity,
        child: Image.network(
          cleanUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const Center(child: Icon(Icons.broken_image));
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
        ),
      );
    }

    // ✅ 3) asset image (add errorBuilder too)
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Image.asset(
        cleanUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Center(child: Icon(Icons.broken_image));
        },
      ),
    );
  }
}
