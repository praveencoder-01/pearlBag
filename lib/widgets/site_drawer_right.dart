import 'package:flutter/material.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/screens/checkout_screen.dart';
import 'package:provider/provider.dart';

import '../providers/drawer_provider.dart';
import '../theme/app_colors.dart';

class SiteDrawerRight extends StatelessWidget {
  const SiteDrawerRight({super.key});

  @override
  Widget build(BuildContext context) {
    final isOpen = context.watch<DrawerProvider>().isRightOpen;
    final cart = context.watch<CartProvider>();

    if (!isOpen) return const SizedBox.shrink();

    return Stack(
      children: [
        // GestureDetector(
        //   onTap: () => context.read<DrawerProvider>().closeAll(),
        //   child: Container(color: Colors.black.withOpacity(0.4)),
        // ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          right: 0,
          top: 0,
          bottom: 0,
          width: 360,
          child: Container(
            color: AppColors.scaffoldGrey,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'YOUR CART',
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w100,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 CART CONTENT
                Expanded(
                  child: cart.items.isEmpty
                      ? const Text(
                          'Cart is empty',
                          style: TextStyle(
                            fontSize: 15,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        )
                      : ListView.separated(
                          itemCount: cart.items.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final product = cart.items[index];

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    product.cartImage,
                                    fit: BoxFit
                                        .contain, // preserves entire image
                                    width: 100, // give it some reasonable width
                                    // no height, lets image scale naturally
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // PRODUCT INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.none,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '₹${product.price}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          decoration: TextDecoration.none,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Text('Items: ${cart.items.length}'), //for testing_________________________---------

                                // REMOVE BUTTON
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,

                                  child: Text(
                                    "Remove",
                                    style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 1,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  onTap: () {
                                    cart.removeFromCart(product);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                ),

                // 🔹 FOOTER
                if (cart.items.isNotEmpty) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.2,
                          decoration: TextDecoration.none,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '₹${cart.totalPrice}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'CHECK OUT',
                        style: TextStyle(
                          // fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.9,
                          decoration: TextDecoration.none,
                          color: Color.fromARGB(255, 42, 41, 41),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
