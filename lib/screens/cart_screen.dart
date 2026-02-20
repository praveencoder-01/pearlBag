import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  final double bottomInset;
  const CartScreen({super.key, this.bottomInset = 0});

  // ✅ reusable row (ONLY ONCE)
  Widget _billRow(
    String title,
    double amount, {
    bool isBold = false,
    String? rightText,
    String? subtitle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),

            // ⭐ NEW (items count)
            if (subtitle != null) ...[
              const SizedBox(width: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),

        Text(
          rightText ?? "₹${amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 17,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, product, cart) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false, // user bahar tap karke close nahi karega
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Remove Item?",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            "Are you sure you want to remove '${product.name}' from cart?",
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // ❌ cancel
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true); // ✅ confirm
              },
              child: const Text(
                "Remove",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    // user ne YES dabaya
    if (result == true) {
      cart.removeFromCart(product);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${product.name} removed from cart"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),

      // ✅ BODY
      body: cart.items.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : ListView.builder(
              padding: EdgeInsets.only(
                bottom:
                    190 + bottomInset + MediaQuery.of(context).padding.bottom,
              ),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final product = cart.items[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Slidable(
                    key: ValueKey(product.id), // unique key
                    closeOnScroll: true,

                    // ✅ This controls "stop point" (how much it opens)
                    endActionPane: ActionPane(
                      extentRatio:
                          0.22, // ✅ it will stop around 22% width (icon visible)
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            _confirmDelete(context, product, cart);
                          },
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_outline,
                          label: "Delete",
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),

                    // ✅ your existing card UI (white)
                    child: Container(
                      decoration: BoxDecoration(
                         color: AppColors.card,

                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // image card
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: product.cartImage.startsWith("http")
                                  ? Image.network(
                                      product.cartImage,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      product.cartImage,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // title + subtitle + price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),

                                // optional subtitle (you can remove)
                                const Text(
                                  "Premium item",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Text(
                                  "₹${product.price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // qty pill (like image)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final newQty = product.quantity - 1;
                                    if (newQty <= 0) {
                                      _confirmDelete(context, product, cart);
                                    } else {
                                      cart.updateQuantity(product, newQty);
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.remove, size: 16),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  product.quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => cart.updateQuantity(
                                    product,
                                    product.quantity + 1,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.add, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      // ✅ THIS MUST BE HERE (Scaffold property)
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Container(
                  color: AppColors.card,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26),
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                      decoration: BoxDecoration(
 color: AppColors.card,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 18,
                            offset: Offset(0, -6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 4,
                            width: 45,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),

                          // Amount card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                               color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                _billRow("Subtotal", cart.subTotal),
                                const SizedBox(height: 8),
                                _billRow(
                                  "Shipping",
                                  cart.shippingFee,
                                  rightText: cart.shippingFee == 0
                                      ? "FREE"
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                _billRow(
                                  "Bag Total",
                                  cart.bagTotal,
                                  isBold: true,
                                  subtitle: "(${cart.itemCount} item)",
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/checkout');
                              },
                              child: const Text(
                                "PROCEED TO CHECKOUT",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
