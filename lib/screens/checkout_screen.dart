import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();
  final countryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String street = '';
  String city = '';
  String stateName = '';
  String zip = '';
  String country = '';
  bool rememberAddress = false; // 🔹 toggle for saving address

  Future<void> loadSavedAddress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return; // ✅ safety

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
        streetController.text = data['street'] ?? '';
        cityController.text = data['city'] ?? '';
        stateController.text = data['state'] ?? '';
        zipController.text = data['zip'] ?? '';
        countryController.text = data['country'] ?? '';
        rememberAddress = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadSavedAddress();
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

  double calculateTotal(List<QueryDocumentSnapshot> items) {
    double total = 0;
    for (var doc in items) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
    }
    return total;
  }

  Future<void> placeOrder(
    List<QueryDocumentSnapshot> cartItems,
    Map<String, dynamic> address,
  ) async {
    final user = FirebaseAuth.instance.currentUser!;
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();

    final orderItems = cartItems.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'productId': doc.id,
        'name': data['name'],
        'price': data['price'],
        'quantity': data['quantity'],
        'imageUrl': data['imageUrl'],
      };
    }).toList();

    await orderRef.set({
      'userId': user.uid,
      'items': orderItems,
      'totalAmount': calculateTotal(cartItems),
      'shippingAddress': address,
      'orderStatus': 'Pending',
      'paymentStatus': 'COD',
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (var doc in cartItems) {
      await doc.reference.delete();
    }
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
        validator: (v) => v!.isEmpty ? "Required" : null,
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
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('cart')
                .doc(userId)
                .collection('items')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final cartItems = snapshot.data!.docs;
              final totalAmount = calculateTotal(cartItems);

              if (cartItems.isEmpty) {
                return const Center(child: Text("Cart is empty"));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 USER DETAILS
                    _sectionCard(
                      title: "User Details",
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue:
                                FirebaseAuth
                                    .instance
                                    .currentUser
                                    ?.displayName ??
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

                    /// 🔹 SHIPPING ADDRESS
                    _sectionCard(
                      title: "Shipping Address",
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _input(streetController, "Street"),
                            _input(cityController, "City"),
                            _input(stateController, "State"),
                            _input(zipController, "ZIP Code"),
                            _input(countryController, "Country"),

                            const SizedBox(height: 8),

                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: const Text(
                                "Remember this address",
                                style: TextStyle(fontSize: 14),
                              ),
                              value: rememberAddress,
                              onChanged: (val) {
                                setState(() => rememberAddress = val ?? false);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// 🔹 CART SUMMARY
                    _sectionCard(
                      title: "Cart Items",
                      child: Column(
                        children: cartItems.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      (data['imageUrl'] is List &&
                                              data['imageUrl'].isNotEmpty)
                                          ? data['imageUrl'][0]
                                          : data['imageUrl'] ?? "",
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Qty: ${data['quantity']}",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "₹${data['price']}",
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

                    /// 🔹 PRICE BREAKDOWN
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

                    /// 🔹 PAYMENT METHOD
                    _sectionCard(
                      title: "Payment Method",
                      child: Column(
                        children: const [
                          RadioListTile(
                            value: 1,
                            groupValue: 1,
                            onChanged: null,
                            title: Text("Cash on Delivery"),
                          ),
                          RadioListTile(
                            value: 2,
                            groupValue: 1,
                            onChanged: null,
                            title: Text("Online Payment (Coming Soon)"),
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 DELIVERY INFO
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: const [
                          Icon(Icons.local_shipping_outlined, size: 20),
                          SizedBox(width: 8),
                          Text("Delivered in 5–7 business days"),
                        ],
                      ),
                    ),

                    /// 🔹 PLACE ORDER BUTTON
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
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => isLoading = true);

                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  setState(() => isLoading = false);
                                  return;
                                }

                                final address = {
                                  'street': streetController.text.trim(),
                                  'city': cityController.text.trim(),
                                  'state': stateController.text.trim(),
                                  'zip': zipController.text.trim(),
                                  'country': countryController.text.trim(),
                                };

                                // 🔹 SAVE ADDRESS
                                if (rememberAddress) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .collection('addresses')
                                      .add({
                                        ...address,
                                        'isDefault': true,
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                }

                                // 🔥 ORDER PLACE
                                await placeOrder(cartItems, address);

                                setState(() => isLoading = false);

                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Order Placed"),
                                      content: const Text(
                                        "Your order has been placed successfully.",
                                      ),
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
                                }
                              },

                        // ✅ THIS WAS MISSING
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
              );
            },
          ),
        ),
      ),
    );
  }
}
