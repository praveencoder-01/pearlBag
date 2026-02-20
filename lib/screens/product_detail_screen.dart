import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:food_website/widgets/wishlist_service.dart';
import 'package:provider/provider.dart';

enum ProductInfoSection { description, shipping, returns }

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late List<Product> suggestedProducts;

  bool _isAddingToCart = false;
  int _currentImageIndex = 0;
  int _quantity = 1;
  double _myRating = 0;
  bool _savingRating = false;
  bool _isWishlisted = false;
  bool _loadingWish = true;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadWishlistState();
  }

  Future<void> _loadWishlistState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isWishlisted = false;
        _loadingWish = false;
      });
      return;
    }

    final exists = await WishlistService.isWishlisted(widget.product.id);

    if (!mounted) return;
    setState(() {
      _isWishlisted = exists;
      _loadingWish = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---------------- PRICE ROW ----------------
  Widget buildDiscountPriceRow(Product product) {
    final originalPrice = product.price * 1.2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Price (per item)",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${product.price.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '₹${originalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black45,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
         color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // ⭐ THIS REMOVES THE LINES
        ),
        child: (ExpansionTile(
          leading: Icon(icon, size: 20, color: Colors.black87),

          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          collapsedIconColor: Colors.black54,
          iconColor: Colors.black,
          children: [
            Text(
              body,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ],
        )),
      ),
    );
  }

  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to use wishlist")),
      );
      return;
    }

    setState(() => _loadingWish = true);

    try {
      if (_isWishlisted) {
        await WishlistService.remove(widget.product.id);
        if (!mounted) return;
        setState(() {
          _isWishlisted = false;
          _loadingWish = false;
        });
      } else {
        await WishlistService.add(widget.product.id);
        if (!mounted) return;
        setState(() {
          _isWishlisted = true;
          _loadingWish = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingWish = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Wishlist failed: $e")));
    }
  }

  Widget buildSpecsCard(Map<String, String> specs) {
    if (specs.isEmpty) return const SizedBox();

    Widget row(String k, String v) {
      if (v.trim().isEmpty) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(
                k,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
            Expanded(
              child: Text(
                v,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
         color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Product Info",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          row("Material", specs['material'] ?? ''),
          row("Closure", specs['closure'] ?? ''),
          row("Weight", specs['weight'] ?? ''),
          row("Ideal for", specs['idealFor'] ?? ''),
        ],
      ),
    );
  }

  Widget trustBadgesCard() {
    Widget item(IconData icon, String title, String sub) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
             color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: Colors.black87),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        item(Icons.lock_outline, "Secure", "Payments"),
        const SizedBox(width: 10),
        item(Icons.payments_outlined, "COD", "Available"),
        const SizedBox(width: 10),
        item(Icons.local_shipping_outlined, "Fasy", "Shipping"),
        const SizedBox(width: 10),
        item(Icons.assignment_return_outlined, "Easy", "Returns"),
      ],
    );
  }

  Widget ratingInputCard() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
         color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromARGB(255, 230, 230, 230)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rate this product",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          // ⭐ Star selector
          Row(
            children: [
              RatingBar.builder(
                initialRating: _myRating,
                minRating: 1,
                allowHalfRating: true,
                itemSize: 26,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (value) {
                  setState(() => _myRating = value);
                },
              ),
              const SizedBox(width: 10),
              Text(
                _myRating == 0 ? "Tap to rate" : _myRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (_myRating == 0 || _savingRating)
                  ? null
                  : () async {
                      await _submitRating();
                    },
              child: _savingRating
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "SUBMIT RATING",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login to rate")));
      return;
    }

    if (_myRating <= 0) return;

    setState(() => _savingRating = true);

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id);

    final ratingRef = productRef.collection('ratings').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((txn) async {
        // 1) Read product doc
        final productSnap = await txn.get(productRef);
        final data = productSnap.data() ?? {};

        double ratingSum = ((data['ratingSum'] ?? 0) as num).toDouble();
        int ratingCount = (data['ratingCount'] ?? 0) as int;

        // 2) Check if user already rated
        final ratingSnap = await txn.get(ratingRef);

        if (ratingSnap.exists) {
          final prevRating = ((ratingSnap.data()?['rating'] ?? 0) as num)
              .toDouble();

          // update: remove old + add new
          ratingSum = ratingSum - prevRating + _myRating;
          // ratingCount unchanged
        } else {
          // new rating
          ratingSum = ratingSum + _myRating;
          ratingCount = ratingCount + 1;

          // first time rating: store createdAt
          txn.set(ratingRef, {
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        final avg = ratingCount == 0 ? 0.0 : (ratingSum / ratingCount);

        // 3) Write rating doc (always)
        txn.set(ratingRef, {
          'rating': _myRating,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 4) Update product aggregates
        txn.set(productRef, {
          'ratingSum': ratingSum,
          'ratingCount': ratingCount,
          'avgRating': double.parse(avg.toStringAsFixed(1)),
        }, SetOptions(merge: true));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thanks! Rating submitted ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _savingRating = false);
    }
  }

  Widget ratingSummaryRow(String productId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox();

        final data = snap.data!.data() as Map<String, dynamic>? ?? {};

        final avg = ((data['avgRating'] ?? 0) as num).toDouble();
        final count = (data['ratingCount'] ?? 0) as int;

        // Optional: sold count too (if you store it)
        final sold = (data['soldCount'] ?? 0) as int;

        return Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              avg == 0 ? "New" : avg.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Text(
              "($count ratings)",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            if (sold > 0) ...[
              const SizedBox(width: 8),
              Container(
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$sold sold",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final images = widget.product.images
        .map((e) => e.replaceAll('\n', '').trim())
        .map((e) => e.replaceFirst(RegExp(r'^[,\s]+'), ''))
        .where((e) => e.isNotEmpty)
        .toList();

    // ---------------- IMAGE SECTION ----------------
    Widget imageSection(List<String> images) {
      final imagesCount = images.length;

      if (imagesCount == 0) {
        return Container(
          height: 300,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text("No images found"),
        );
      }

      if (_currentImageIndex >= imagesCount) _currentImageIndex = 0;

      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagesCount,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: _productImage(images[index]),
                  );
                },
              ),
            ),

            // ✅ Wishlist icon bottom-right
            Positioned(
              right: 12,
              bottom: 12,
              child: InkWell(
                onTap: _toggleWishlist,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loadingWish
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isWishlisted
                                ? Colors.black
                                : Colors.black87,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(

      // ---------------- APPBAR ----------------
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                    ),
                    if (cart.items.isNotEmpty)
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
          ),
        ],
      ),

      // ---------------- BODY ----------------
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          imageSection(images),

          const SizedBox(height: 10),

          // dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == _currentImageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 7,
                width: active ? 18 : 7,
                decoration: BoxDecoration(
                  color: active ? Colors.black : Colors.black26,
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // title + quantity
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 238, 238),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.remove, size: 17),
                      ),
                    ),
                    Text(
                      _quantity.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() => _quantity++);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.add, size: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ratingSummaryRow(widget.product.id),

          // buildRatingRow(),
          infoTile(
            icon: Icons.description_outlined,
            title: "Description",
            body: widget.product.description.isEmpty
                ? "No description added."
                : widget.product.description,
          ),

          infoTile(
            icon: Icons.local_shipping_outlined,
            title: "Shipping",
            body: widget.product.shippingPolicy.isEmpty
                ? "No shipping policy added."
                : widget.product.shippingPolicy,
          ),

          infoTile(
            icon: Icons.assignment_return_outlined,
            title: "Returns",
            body: widget.product.returnPolicy.isEmpty
                ? "No return policy added."
                : widget.product.returnPolicy,
          ),

          const SizedBox(height: 30),
          const SizedBox(height: 14),
          const Text(
            "Product Info",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          buildSpecsCard(widget.product.specs),

          const SizedBox(height: 30),
          trustBadgesCard(),
          const SizedBox(height: 30),
          ratingInputCard(),
        ],
      ),

      // ---------------- BOTTOM BAR ----------------
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 86,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
 color: AppColors.card,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: buildDiscountPriceRow(widget.product)),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    onPressed: () async {
                      setState(() => _isAddingToCart = true);

                      await Future.delayed(const Duration(milliseconds: 600));

                      for (int i = 0; i < _quantity; i++) {
                        context.read<CartProvider>().addToCart(widget.product);
                      }

                      setState(() => _isAddingToCart = false);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    },
                    child: _isAddingToCart
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "ADD TO CART",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _productImage(String pathOrUrl) {
  final clean = pathOrUrl
      .replaceAll('\n', '')
      .trim()
      .replaceFirst(RegExp(r'^[,\s]+'), '');

  final isNetwork = clean.startsWith('http');

  if (isNetwork) {
    return Image.network(
      clean,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (context, error, stack) {
        return const Center(child: Icon(Icons.broken_image, size: 40));
      },
    );
  }

  return Image.asset(
    clean,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stack) {
      return const Center(child: Icon(Icons.broken_image, size: 40));
    },
  );
}
