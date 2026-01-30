import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String selectedStatus = 'All';
  String searchText = '';

  final List<String> statuses = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders Management")),

      body: Column(
        children: [
          // 🔹 SEARCH
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Order Number",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchText = value.trim());
              },
            ),
          ),

          // 🔹 FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              items: statuses
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedStatus = value!);
              },
              decoration: const InputDecoration(
                labelText: "Filter by Status",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 ORDERS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data!.docs;

                // 🔹 APPLY FILTERS
                final orders = allOrders.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['orderStatus'] ?? 'Pending';
                  final orderNo = (data['orderNumber'] ?? '').toString();

                  if (selectedStatus != 'All' && status != selectedStatus) {
                    return false;
                  }

                  if (searchText.isNotEmpty && !orderNo.contains(searchText)) {
                    return false;
                  }

                  return true;
                }).toList();

                if (orders.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String orderStatus = data['orderStatus'] ?? 'Pending';

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: Text(
                                    orderStatus.isNotEmpty
                                        ? orderStatus[0]
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    "Order #${data['orderNumber'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                _statusChip(orderStatus),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text("Amount: ₹ ${data['totalAmount'] ?? 0}"),
                            Text(
                              "Payment: ${data['paymentStatus'] ?? 'Unpaid'}",
                            ),

                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            OrderDetailScreen(orderId: doc.id),
                                      ),
                                    );
                                  },
                                  child: const Text("View Details"),
                                ),
                                

                                // DropdownButton<String>(
                                //   value: orderStatus,
                                //   underline: const SizedBox(),
                                //   items: statuses
                                //       .where((e) => e != 'All')
                                //       .map(
                                //         (e) => DropdownMenuItem(
                                //           value: e,
                                //           child: Text(e),
                                //         ),
                                //       )
                                //       .toList(),
                                //   onChanged: (value) {
                                //     FirebaseFirestore.instance
                                //         .collection('orders')
                                //         .doc(doc.id)
                                //         .update({'orderStatus': value});
                                //   },
                                // ),
                              ],
                            ),
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

  // 🔹 STATUS CHIP WIDGET
  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case 'Delivered':
        color = Colors.green;
        break;
      case 'Cancelled':
        color = Colors.red;
        break;
      case 'Processing':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
