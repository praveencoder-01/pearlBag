import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        // Background overlay (optional)
        GestureDetector(
          onTap: () => context.read<DrawerProvider>().closeAll(),
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          right: 0,
          top: 0,
          bottom: 0,
          width: 360,
          child: Material(
            color: Colors.transparent,
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

                  // Cart content
                  // CART CONTENT
                  Expanded(
                    child: cart.items.isEmpty
                        ? SingleChildScrollView(
                            // only for empty cart message
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Your cart is empty!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: cart.items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final product = cart.items[index];
                              return buildProductRow(
                                product,
                                cart,
                                context,
                              ); // see step 2
                            },
                          ),
                  ),

                  // Footer (Total + Checkout)
                  if (cart.items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                '₹${cart.totalPrice}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF3B82F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen(),
                                  ),
                                );
                                await context.read<CartProvider>().clearCart();

                              },
                              child: const Text(
                                
                                'CHECK OUT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProductRow(product, CartProvider cart, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IMAGE
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(product.cartImage, width: 90, fit: BoxFit.contain),
        ),

        const SizedBox(width: 12),

        // NAME + PRICE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${product.price}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),

              DropdownButton<int>(
                value: product.quantity,
                underline: const SizedBox(),
                items: List.generate(5, (index) {
                  final qty = index + 1;
                  return DropdownMenuItem<int>(
                    value: qty,
                    child: Text('Qty: $qty'),
                  );
                }),
                onChanged: (value) {
                  if (value == null) return;
                  cart.updateQuantity(product, value);
                },
              ),
            ],
          ),
        ),

        // REMOVE
     SizedBox(
  width: 60,
  child: GestureDetector(
    onTap: () async {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 🔥 Firestore se delete
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(uid)
          .collection('items')
          .doc(product.id)
          .delete();

      // 🔥 Provider se bhi remove
      cart.removeFromCart(product);
    },
    behavior: HitTestBehavior.opaque,
    child: const Text(
      'Remove',
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 14,
        color: Colors.black,
        decoration: TextDecoration.none,
      ),
    ),
  ),
)
      ],
    );
  }
}
