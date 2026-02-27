// =======================
// ADMIN ORDERS SCREEN (PREMIUM RESPONSIVE)
// =======================

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

  // ---------- BREAKPOINT ----------
  bool isDesktop(double w) => w >= 1000;
  bool isTablet(double w) => w >= 650 && w < 1000;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF6F7FB),
       
      child: SafeArea(
        child: Column(
          children: [

            // ===== SEARCH + FILTERS =====
            _topControls(),

            // ===== ORDERS STREAM =====
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Firestore Error:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allOrders = snapshot.data!.docs;

                  final orders = allOrders.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['orderStatus'] ?? 'Pending';
                    final orderNo = (data['orderNumber'] ?? '').toString();

                    if (selectedStatus != 'All' && status != selectedStatus) {
                      return false;
                    }

                    if (searchText.isNotEmpty &&
                        !orderNo.contains(searchText)) {
                      return false;
                    }

                    return true;
                  }).toList();

                  if (orders.isEmpty) {
                    return const Center(child: Text("No orders found"));
                  }

                  return LayoutBuilder(
                    builder: (context, c) {
                      final width = c.maxWidth;

                      if (isDesktop(width)) {
                        return _desktopTable(orders);
                      } else {
                        return _mobileCards(orders, isTablet(width));
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== SEARCH + FILTERS =====================

  Widget _topControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        children: [
          // SEARCH FIELD
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() => searchText = value.trim());
              },
              decoration: const InputDecoration(
                hintText: "Search order number",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // FILTER PILLS
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final status = statuses[i];
                final selected = selectedStatus == status;

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => selectedStatus = status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xff4F46E5) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      status,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===================== MOBILE / TABLET CARDS =====================

  Widget _mobileCards(List orders, bool tablet) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final doc = orders[index];
        final data = doc.data() as Map<String, dynamic>;

        final address = data['shippingAddress'] != null
            ? "${data['shippingAddress']['street'] ?? ''}, ${data['shippingAddress']['city'] ?? ''}"
            : 'N/A';

        final date = data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate().toString().split(' ')[0]
            : 'N/A';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 6),
                color: Color(0x14000000),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ORDER + AMOUNT
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "#${data['orderNumber']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    "₹${data['totalAmount'] ?? 0}",
                    style: const TextStyle(
                      color: Color(0xff4F46E5),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                data['userName'] ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 4),

              Text(
                address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 6),

              Text(date, style: const TextStyle(color: Colors.black45)),

              const SizedBox(height: 10),

              Row(
                children: [
                  _paymentChip(data['paymentStatus'] ?? 'Unpaid'),
                  const SizedBox(width: 8),
                  _statusChip(data['orderStatus'] ?? 'Pending'),
                  const Spacer(),
                  _viewButton(doc.id),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================== DESKTOP TABLE =====================

  Widget _desktopTable(List orders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 52,
        dataRowHeight: 64,
        columns: const [
          DataColumn(label: Text("Order #")),
          DataColumn(label: Text("Customer")),
          DataColumn(label: Text("Address")),
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Amount")),
          DataColumn(label: Text("Payment")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Action")),
        ],
        rows: orders.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final address = data['shippingAddress'] != null
              ? "${data['shippingAddress']['street'] ?? ''}, ${data['shippingAddress']['city'] ?? ''}"
              : 'N/A';

          final date = data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate().toString().split(
                  ' ',
                )[0]
              : 'N/A';

          return DataRow(
            cells: [
              DataCell(Text("#${data['orderNumber']}")),
              DataCell(Text(data['userName'] ?? 'N/A')),
              DataCell(
                SizedBox(
                  width: 220,
                  child: Text(
                    address,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              DataCell(Text(date)),
              DataCell(Text("₹${data['totalAmount'] ?? 0}")),
              DataCell(_paymentChip(data['paymentStatus'] ?? 'Unpaid')),
              DataCell(_statusChip(data['orderStatus'] ?? 'Pending')),
              DataCell(_viewButton(doc.id)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ===================== CHIPS =====================

  Widget _paymentChip(String status) {
    final paid = status == "Paid";
    return _chip(paid ? "Paid" : "Unpaid", paid ? Colors.green : Colors.red);
  }

  Widget _statusChip(String status) {
    switch (status) {
      case "Delivered":
        return _chip("Delivered", Colors.green);
      case "Cancelled":
        return _chip("Cancelled", Colors.red);
      case "Processing":
        return _chip("Processing", Colors.blue);
      case "Shipped":
        return _chip("Shipped", Colors.teal);
      default:
        return _chip("Pending", Colors.orange);
    }
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _viewButton(String id) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xff4F46E5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "View",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
