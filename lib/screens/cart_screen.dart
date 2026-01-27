import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {

                final product = cart.items[index];

                return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start, // align top
    children: [
      // 🖼 Product Image
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
  constraints: const BoxConstraints(
    maxWidth: 60,
  ),
  child: Image.asset(
    product.cartImage,
    fit: BoxFit.fitWidth,
  ),
),

      ),

      const SizedBox(width: 12),

      // Product name + price
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text('₹${product.price}'),
          ],
        ),
      ),

      // Remove button
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          cart.removeFromCart(product);
        },
      ),
    ],
  ),
);


              },
            ),
    );
  }
}
