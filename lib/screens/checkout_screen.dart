import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

  // ✅ SECTION CARD (INSIDE STATE)
  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  // ✅ TOTAL
  double calculateTotal(List<QueryDocumentSnapshot> items) {
    double total = 0;
    for (var doc in items) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
    }
    return total;
  }

  // ✅ PLACE ORDER
  Future<void> placeOrder(List<QueryDocumentSnapshot> cartItems) async {
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

    final totalAmount = calculateTotal(cartItems);

    await orderRef.set({
      'userId': user.uid,
      'orderNumber': DateTime.now().millisecondsSinceEpoch,
      'items': orderItems,
      'totalAmount': totalAmount,
      'orderStatus': 'Pending',
      'paymentStatus': 'COD',
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (var doc in cartItems) {  
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
//     print("User ID: $userId");
// FirebaseFirestore.instance
//     .collection('cart')
//     .doc(userId)
//     .collection('items')
//     .get()
//     .then((value) => print("Cart items: ${value.docs.length}"));

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),

      
      body: StreamBuilder<QuerySnapshot>(
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

          if (cartItems.isEmpty) {
            return const Center(child: Text("Cart is empty"));
          }

          final totalAmount = calculateTotal(cartItems);

          return Column(
            children: [

              Expanded(
                child: _sectionCard(
                  title: "Items",
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final data =
                          cartItems[index].data() as Map<String, dynamic>;

                      return ListTile(
                        leading: Image.network(
  // agar data['imageUrl'] ek list hai, first item lo, nahi toh fallback
  (data['imageUrl'] is List && data['imageUrl'].isNotEmpty) 
      ? data['imageUrl'][0] 
      : (data['imageUrl'] ?? ''), 
  width: 40,
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
),
                        title: Text(data['name']),
                        subtitle: Text("Qty: ${data['quantity']}"),
                        trailing: Text("₹ ${data['price']}"),
                      );
                    },
                  ),
                ),
              ),

              _sectionCard(
                title: "Total",
                child: Column(
                  children: [
                    Text(
                      "₹ $totalAmount",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          await placeOrder(cartItems);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Order placed successfully")),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("Place Order"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


