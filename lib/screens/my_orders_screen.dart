import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/screens/product_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool showOngoing = true;
  Widget _orderImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Icon(Icons.shopping_bag_outlined);
    }

    final isNetwork = path.startsWith("http");

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: isNetwork
          ? Image.network(path, fit: BoxFit.cover)
          : Image.asset(path, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Please login first")));
    }

    final ordersQuery = FirebaseFirestore.instance
        .collection("orders")
        .where("userId", isEqualTo: uid);
    // .orderBy("createdAt", descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: Column(
        children: [
          Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          _tabButton("Ongoing", true),
          const SizedBox(width: 10),
          _tabButton("Completed", false),
        ],
      ),
    ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersQuery.snapshots(),
            
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No orders yet"));
                }
            
                final orders = snapshot.data!.docs;
            
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final data = orders[index].data() as Map<String, dynamic>;
            
                    final items = (data["items"] as List?) ?? [];
                    final status = data["orderStatus"] ?? "Placed";
                    final isDelivered = status == "Delivered";

// filter logic
if (showOngoing && isDelivered) {
  return const SizedBox(); // hide completed in ongoing
}
if (!showOngoing && !isDelivered) {
  return const SizedBox(); // hide ongoing in completed
}
                    final total = data["totalAmount"] ?? 0;
            
                    // first product (card preview)
                    final firstItem = items.isNotEmpty
                        ? items[0] as Map<String, dynamic>
                        : null;
            
                    final name = firstItem?["name"] ?? "Order";
                    final image = firstItem?["imageUrl"];
            
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        if (firstItem == null) return;
            
                        final productId = firstItem["productId"]?.toString();
                        if (productId == null || productId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("productId missing in order item"),
                            ),
                          );
                          return;
                        }
            
                        final doc = await FirebaseFirestore.instance
                            .collection("products")
                            .doc(productId)
                            .get();
            
                        if (!doc.exists || doc.data() == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Product not found (maybe deleted)"),
                            ),
                          );
                          return;
                        }
            
                        final product = Product.fromMap(doc.id, doc.data()!);
            
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 16,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // product image
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFEFEF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: image == null
                                  ? const Icon(Icons.shopping_bag_outlined)
                                  : _orderImage(image),
                            ),
            
                            const SizedBox(width: 12),
            
                            // order details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
            
                                  Text(
                                    "Items: ${items.length}",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
            
                                  const SizedBox(height: 6),
            
                                  Text(
                                    "Status: $status",
                                    style: TextStyle(
                                      color: status == "Delivered"
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
            
                                  const SizedBox(height: 6),
            
                                  Text(
                                    "Total: ₹${(total as num).toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
            
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool ongoingTab) {
  final selected = showOngoing == ongoingTab;

  return Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() {
          showOngoing = ongoingTab;
        });
      },
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}
}
