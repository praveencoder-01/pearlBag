import 'package:flutter/material.dart';
import 'package:food_website/data/dummy_images.dart';
import 'package:food_website/layout/main_layout.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/providers/drawer_provider.dart';
import 'package:food_website/widgets/material_section.dart';
import 'package:food_website/widgets/product_horizontal_list.dart';
import 'package:food_website/widgets/product_info_image_section.dart';
import 'package:food_website/widgets/site_footer.dart';
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
  ProductInfoSection _selectedSection = ProductInfoSection.description;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();

    suggestedProducts = dummyProducts 
        .where((p) => p.id != widget.product.id)
        .take(4)
        .toList();
  }

  Widget _buildSectionContent() {
    switch (_selectedSection) {
      case ProductInfoSection.description:
        return Text(
          widget.product.description,
          key: const ValueKey('description'),
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black54,
          ),
        );

      case ProductInfoSection.shipping:
        return const Text(
          'Shipping costs are non-refundable. All costs associated with returning products are your responsibility. If your products are post-stamped outside the 14 day return window, we reserve the right to refuse the return or offer you store credit.',
          key: ValueKey('shipping'),
          style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black54),
        );

      case ProductInfoSection.returns:
        return const Text(
          'You have 14 days from the delivery date to request and dispatch a return. To send something back you can process the return by logging in to your account. All returns have a processing fee of 2% and original shipping costs are non-refundable.You can return at your own cost or we can provide a return label for a charge that will be deducted from your refund or store credit.',
          key: ValueKey('returns'),
          style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black54),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🏷 PRODUCT NAME (TOP CENTER)
            Text(
              widget.product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.1,
              ),
            ),
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 300.0),
              child: Text(
                "More than an accessory, our pearl bags reflect confidence, elegance, and individuality. Thoughtfully designed and beautifully finished, they are made for women who love standing out in a soft, graceful way.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // 🔽 IMAGE + DETAILS
            Padding(
              padding: const EdgeInsets.only(
                left: 80,
                right: 80,
                top: 30,
                bottom: 50,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼 IMAGE + GALLERY
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 0,
                          color: const Color.fromARGB(255, 237, 237, 237),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SizedBox(
                            height: 620,
                            child: Center(
                              child: SizedBox(
                                height: 500,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ProductImageSlider(
                                    images: widget.product.images,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  const SizedBox(width: 60),

                  // 📄 DETAILS
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs${widget.product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),

                        // const SizedBox(height: 30),
                        const SizedBox(height: 40),

                        SizedBox(
                          height: 70,
                          width: 550,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              overlayColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 0.7,
                                ),
                              ),
                            ),

                            // 🔒 disable button while loading
                            onPressed: _isAddingToCart
                                ? null
                                : () async {
                                    setState(() {
                                      _isAddingToCart = true;
                                    });

                                    // simulate network delay (real apps need this)
                                    await Future.delayed(
                                      const Duration(milliseconds: 600),
                                    );

                                    context.read<CartProvider>().addToCart(
                                      widget.product,
                                    );
                                    context.read<DrawerProvider>().openRight();

                                    setState(() {
                                      _isAddingToCart = false;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to cart'),
                                      ),
                                    );
                                  },

                            child: _isAddingToCart
                                ? const SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'ADD TO CART',
                                    style: TextStyle(
                                      color: Colors.black,
                                      letterSpacing: 3.0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Row(
                          children: [
                            _InfoTextButton(
                              text: 'DESCRIPTION',
                              isActive:
                                  _selectedSection ==
                                  ProductInfoSection.description,
                              onTap: () {
                                setState(() {
                                  _selectedSection =
                                      ProductInfoSection.description;
                                });
                              },
                            ),
                            const SizedBox(width: 24),
                            _InfoTextButton(
                              text: 'SHIPPING POLICY',
                              isActive:
                                  _selectedSection ==
                                  ProductInfoSection.shipping,
                              onTap: () {
                                setState(() {
                                  _selectedSection =
                                      ProductInfoSection.shipping;
                                });
                              },
                            ),
                            const SizedBox(width: 24),
                            _InfoTextButton(
                              text: 'RETURNS',
                              isActive:
                                  _selectedSection ==
                                  ProductInfoSection.returns,
                              onTap: () {
                                setState(() {
                                  _selectedSection = ProductInfoSection.returns;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildSectionContent(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const ProductMaterialSection(),
            ProductInfoImageSection(data: widget.product.infoSection),

            // YOU MIGHT ALSO LIKE PART
            const SizedBox(height: 100),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Text(
                  'YOU MIGHT ALSO LIKE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),

            ProductHorizontalList(products: dummyProducts ),

            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _InfoTextButton extends StatefulWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;
  const _InfoTextButton({
    required this.text,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_InfoTextButton> createState() => _InfoTextButtonState();
}

class _InfoTextButtonState extends State<_InfoTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final showUnderline = _isHovered || widget.isActive;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 15,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 3),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 1.2,
                width: showUnderline ? _textWidth(context, widget.text) : 0,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _textWidth(BuildContext context, String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 15,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.size.width;
  }
}

// image slider code
class ProductImageSlider extends StatefulWidget {
  final List<String> images;

  const ProductImageSlider({super.key, required this.images});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int currentIndex = 0;

  void next() {
    setState(() {
      currentIndex = (currentIndex + 1) % widget.images.length;
    });
  }

  void previous() {
    setState(() {
      currentIndex =
          (currentIndex - 1 + widget.images.length) % widget.images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                widget.images[currentIndex],
                key: ValueKey(currentIndex),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // LEFT BUTTON
          Positioned(left: 12, child: _navButton(Icons.chevron_left, previous)),

          // RIGHT BUTTON
          Positioned(right: 12, child: _navButton(Icons.chevron_right, next)),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Icon(icon, color: Colors.black, size: 40),
    );
  }
}
