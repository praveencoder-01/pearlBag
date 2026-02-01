import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/providers/drawer_provider.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final flatController = TextEditingController(); // Flat, House no...
  final areaController = TextEditingController(); // Area, street...
  final landmarkController = TextEditingController(); // Landmark
  final pincodeController = TextEditingController(); // Pincode
  final cityController = TextEditingController(); // Town/City (same name ok)
  final stateController = TextEditingController(); // State (same)
  final countryController = TextEditingController(); // Country (same)
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool rememberAddress = false;
  

  @override
  void initState() {
    super.initState();
    loadSavedAddress();
  }

  Future<void> loadSavedAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      setState(() {
        flatController.text = data['flat'] ?? data['street'] ?? '';
        areaController.text = data['area'] ?? '';
        landmarkController.text = data['landmark'] ?? '';
        pincodeController.text = data['pincode'] ?? data['zip'] ?? '';
        cityController.text = data['city'] ?? '';
        stateController.text = data['state'] ?? '';
        countryController.text = data['country'] ?? '';

        rememberAddress = true;
      });
    }
  }

  double calculateTotal(BuildContext context) {
    return context.read<CartProvider>().totalPrice;
  }

Future<void> placeOrder(
  BuildContext context,
  List<Product> cartItems,
  Map<String, dynamic> address,
) async {
  try {
    final user = FirebaseAuth.instance.currentUser!;
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();

    final orderItems = cartItems.map((item) {
      return {
        'productId': item.id,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'imageUrl': item.imageUrl,
      };
    }).toList();

    await orderRef.set({
      'userId': user.uid,
      'items': orderItems,
      'totalAmount': calculateTotal(context),
      'shippingAddress': address,
      'orderStatus': 'Pending',
      'paymentStatus': 'COD',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await context.read<CartProvider>().clearCart();
  } catch (e) {
    // ignore: avoid_print
    rethrow;
  }
}



  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "₹ $value",
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.items;
    final totalAmount = cartProvider.totalPrice;
    // final cp = context.watch<CartProvider>();

    if (cartItems.isEmpty) {
      return const Scaffold(body: Center(child: Text("Cart is empty")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// USER DETAILS
                _sectionCard(
                  title: "User Details",
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue:
                            FirebaseAuth.instance.currentUser?.displayName ??
                            "",
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Name",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// SHIPPING ADDRESS
                _sectionCard(
                  title: "Shipping Address",
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _input(
                          flatController,
                          "Flat, House no., Building, Company, Apartment",
                        ),
                        _input(areaController, "Area, Street, Sector, Village"),
                        _input(landmarkController, "Landmark"),
                        _input(pincodeController, "Pincode"),
                        _input(cityController, "Town/City"),
                        _input(stateController, "State"),
                        _input(countryController, "Country"),

                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: const Text(
                            "Remember this address",
                            style: TextStyle(fontSize: 14),
                          ),
                          value: rememberAddress,
                          onChanged: (val) =>
                              setState(() => rememberAddress = val ?? false),
                        ),
                      ],
                    ),
                  ),
                ),

                /// CART ITEMS
                _sectionCard(
                  title: "Cart Items",
                  child: Column(
                    children: cartItems.map((item) {
                      final qty = item.quantity;

                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("Qty: $qty"),
                                  ],
                                ),
                              ),
                              Text(
                                "₹${item.price * qty}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                /// PRICE DETAILS
                _sectionCard(
                  title: "Price Details",
                  child: Column(
                    children: [
                      _priceRow("Subtotal", totalAmount),
                      _priceRow("Delivery", 0),
                      _priceRow("Tax", 0),
                      const Divider(),
                      _priceRow("Total", totalAmount, isTotal: true),
                    ],
                  ),
                ),

                /// PLACE ORDER
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isLoading
    ? null
    : () async {

final ok = _formKey.currentState?.validate() ?? false;

if (!ok) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Please fill all required fields")),
  );
  return;
}
        if (!_formKey.currentState!.validate()) return;

        setState(() => isLoading = true);

        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please login again")),
            );
            return;
          }

          final address = {
            'flat': flatController.text.trim(),
            'area': areaController.text.trim(),
            'landmark': landmarkController.text.trim(),
            'pincode': pincodeController.text.trim(),
            'city': cityController.text.trim(),
            'state': stateController.text.trim(),
            'country': countryController.text.trim(),
          };

          if (rememberAddress) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('addresses')
                .add({
              ...address,
              'isDefault': true,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          await placeOrder(context, cartItems, address);
          context.read<DrawerProvider>().closeAll();

          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Order Placed"),
              content: const Text("Your order has been placed successfully."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } catch (e) {
          // ✅ exact error aayega yaha
          // ignore: avoid_print
          // print("❌ CHECKOUT ERROR: $e");  

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Order failed: $e")),
            );
          }
        } finally {
          if (mounted) setState(() => isLoading = false);
        }
      },

                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Place Order",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
