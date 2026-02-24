import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final List<String> orderStatuses = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  Widget statusBadgeDropdown({
    required BuildContext context,
    required String currentStatus,
    required String orderId,
  }) {
    Color bg = Colors.black.withOpacity(0.06);
Color br = Colors.black.withOpacity(0.10);

return Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: br),
  ),
  child: Theme(
    data: Theme.of(context).copyWith(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: orderStatuses.contains(currentStatus) ? currentStatus : 'Pending',
        isDense: true,
        dropdownColor: Colors.white,
        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        items: orderStatuses.map((status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (newStatus) async {
          if (newStatus == null) return;
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .update({'orderStatus': newStatus});
        },
      ),
    ),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Order not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final address = data['shippingAddress'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🧾 ORDER INFO
                _title("Order Info"),
                _row("Order No", data['orderNumber'] ?? 'N/A'),
                Row(
                  children: [
                    Expanded(
                      child: const Text(
                        "Status",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Flexible(
                      child: statusBadgeDropdown(
                        context: context,
                        currentStatus: orderStatuses.contains(data['orderStatus'])
                            ? data['orderStatus']
                            : 'Pending',
                        orderId: widget.orderId,
                      ),
                    ),
                  ],
                ),
                _row("Payment", data['paymentStatus'] ?? 'Unpaid'),

                _row(
                  "Ordered On",
                  data['createdAt'] != null
                      ? (data['createdAt'] as Timestamp).toDate().toString()
                      : 'N/A',
                ),

                const Divider(height: 32),

                /// 👤 USER INFO
                _title("User"),
                _row("Email", data['userEmail'] ?? 'N/A'),
                _row("User ID", data['userId'] ?? 'N/A'),

                const Divider(height: 32),

                /// 📍 ADDRESS
                _title("Delivery Address"),
                _addressBlock(address),

                const Divider(height: 32),

                /// 🛒 ITEMS
                _title("Items"),
                _orderItems(widget.orderId),

                const Divider(height: 32),

                /// 💰 BILL
                _title("Bill Summary"),
                _row("Subtotal", "₹${data['subtotal'] ?? 0}"),
                _row("Delivery", "₹${data['deliveryCharge'] ?? 0}"),
                _row("Discount", "- ₹${data['discount'] ?? 0}"),
                _row("Total", "₹${data['grandTotal'] ?? 0}"),

                _row("Payment Method", data['paymentMethod'] ?? 'N/A'),

                _row(
                  "Total Payable",
                  "₹${(data['totalAmount'] ?? 0) + (data['deliveryCharge'] ?? 0) - (data['discount'] ?? 0)}",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- UI HELPERS ----------------
  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  Widget _row(String key, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 120,
        child: Text(
          key,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  ),
);

  Widget _addressBlock(Map address) {
    if (address.isEmpty) {
      return const Text("No address available");
    }

    return Text(
      "${address['street'] ?? ''}, ${address['city'] ?? ''}, ${address['state'] ?? ''}\n"
      "${address['zip'] ?? ''}, ${address['country'] ?? ''}",
    );
  }

  Widget _orderItems(String orderId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('items')
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Text("No items found");
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final item = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading:
                    item['imageUrl'] != null &&
                        item['imageUrl'].toString().isNotEmpty
                    ? Image.network(
                        item['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Agar image URL invalid hai toh icon show kare
                          return const Icon(Icons.broken_image);
                        },
                      )
                    : const Icon(Icons.image_not_supported),

                title: Text(item['name'] ?? 'Item'),
                subtitle: Text("Qty: ${item['quantity'] ?? 1}"),
                trailing: Text("₹${item['price'] ?? 0}"),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
