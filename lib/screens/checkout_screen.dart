import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/providers/user_provider.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  bool _placingOrder = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
 color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$k: ", style: const TextStyle(fontWeight: FontWeight.w800)),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(String left, String right, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder(CartProvider cart, UserProvider u) async {
    // ✅ double click guard
    if (_placingOrder) return;

    // ✅ address check first
    if (!u.hasAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add address in Profile")),
      );
      return;
    }

    setState(() => _placingOrder = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please login again")));
        return;
      }

      // ✅ Build items (unitPrice + qty separate)
      final items = cart.items.map((p) {
        final lineTotal = p.price * p.quantity;
        return {
          "productId": p.id, // agar p.id nahi hai to remove this line
          "name": p.name,
          "imageUrl": p.cartImage, // asset OR network supported
          "quantity": p.quantity,
          "unitPrice": p.price,
          "lineTotal": lineTotal,
        };
      }).toList();

      // ✅ Calculate totals from items (no double calculation)
      num subtotal = 0;
      for (final it in items) {
        subtotal += (it["lineTotal"] as num);
      }

      final shipping = cart.shippingFee;
      final total = subtotal + shipping;

      final orderData = {
        "userId": uid,
        "createdAt": FieldValue.serverTimestamp(),
        "orderStatus": "Placed",
        "paymentStatus": "Pending",
        "shippingAddress": u.address,
        "items": items,
        "subtotal": subtotal,
        "shippingFee": shipping,
        "totalAmount": total,
      };

      // ✅ Save order
      await FirebaseFirestore.instance.collection("orders").add(orderData);

      if (!mounted) return;

      // ✅ Clear cart after order saved
      await cart.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully ✅")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = context.watch<UserProvider>();
    final cart = context.watch<CartProvider>();

    final subtotal = cart.subTotal;
    final shipping = cart.shippingFee;
    final bagTotal = cart.bagTotal;

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),

      body: cart.items.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
              children: [
                // 1) Delivery details
                _sectionCard(
                  title: "Delivery Address",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _kv("Street", u.address['street'] ?? "—"),
                      _kv("City", u.address['city'] ?? "—"),
                      _kv("State", u.address['state'] ?? "—"),
                      _kv("Phone", u.address['phone'] ?? "—"),
                      _kv("Pincode", u.address['pincode'] ?? "—"),
                      _kv("Country", u.address['country'] ?? "India"),
                    ],
                  ),
                ),

                const SizedBox(height: 26),
                Text(
                  "Product Item",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),

                ...cart.items.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 23),
                    child: _CheckoutItemCard(
                      imageUrl: p.cartImage,
                      name: p.name,
                      subtitle: "Qty: ${p.quantity}",
                      priceText:
                          "₹${(p.price * p.quantity).toStringAsFixed(0)}",
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 3) Price details
                _sectionCard(
                  title: "Price Details",
                  child: Column(
                    children: [
                      _billRow("Subtotal", "₹${subtotal.toStringAsFixed(0)}"),
                      const SizedBox(height: 8),
                      _billRow(
                        "Shipping",
                        shipping == 0
                            ? "FREE"
                            : "₹${shipping.toStringAsFixed(0)}",
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      _billRow(
                        "Bag Total",
                        "₹${bagTotal.toStringAsFixed(0)}",
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),

      // 4) Sticky bottom bar
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration:  BoxDecoration(
 color: AppColors.card,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total (${cart.itemCount} items)",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹${bagTotal.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                              ),
                            ),
                            onPressed: _placingOrder
                                ? null
                                : () => _placeOrder(cart, u),
                            child: _placingOrder
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
                                    "PLACE ORDER",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
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
    );
  }
}

class _CheckoutItemCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String subtitle;
  final String priceText;

  const _CheckoutItemCard({
    required this.imageUrl,
    required this.name,
    required this.subtitle,
    required this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
 color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 235, 235, 235),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.startsWith("http")
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Image.asset(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  priceText,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
