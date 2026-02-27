// =======================
// ORDER DETAIL SCREEN (PREMIUM SaaS UI) - UI ONLY REFACTOR
// ✅ Keeps ALL Firestore logic/paths + update logic EXACTLY SAME
// =======================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // ✅ MUST KEEP SAME STATUSES
  final List<String> orderStatuses = [
    'Placed',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  // ===================== THEME TOKENS =====================
  static const _bg = Color(0xFFF6F7FB);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8ECF4);

  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  static const _primary = Color(0xFF4F46E5);

  static const _r16 = Radius.circular(16);

  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;

  // ===================== STATUS DROPDOWN (KEEP LOGIC) =====================
  // ✅ SAME FUNCTIONALITY: orders/{orderId}.update({'orderStatus': newStatus})
  Widget statusBadgeDropdown({
    required BuildContext context,
    required String currentStatus,
    required String orderId,
  }) {
    final Color bg = _primary.withOpacity(0.08);
    final Color br = _primary.withOpacity(0.18);

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
            value: orderStatuses.contains(currentStatus)
                ? currentStatus
                : 'Pending',
            isExpanded: true,
            isDense: true,
            dropdownColor: Colors.white,
            icon: const Icon(Icons.expand_more_rounded, color: _textSecondary),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              fontSize: 13,
            ),
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

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        foregroundColor: _textPrimary,
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: "Copy Order ID",
            onPressed: () =>
                _copyToClipboard(context, widget.orderId, label: "Order ID"),
            icon: const Icon(Icons.copy_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),

      // ✅ MUST KEEP StreamBuilder PATH EXACTLY
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _CenteredLoader();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const _EmptyState(
              icon: Icons.receipt_long_outlined,
              title: "Order not found",
              subtitle:
                  "This order may have been deleted or the ID is invalid.",
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final address = (data['shippingAddress'] ?? {}) as Map;

          final createdAt = data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate().toString()
              : 'N/A';

          final orderNumber = (data['orderNumber'] ?? 'N/A').toString();
          final paymentStatus = (data['paymentStatus'] ?? 'Unpaid').toString();
          final orderStatus = orderStatuses.contains(data['orderStatus'])
              ? data['orderStatus'].toString()
              : 'Pending';

          final totalAmount = _toNum(data['totalAmount']);
          final delivery = _toNum(data['deliveryCharge']);
          final discount = _toNum(data['discount']);
          final subtotal = _toNum(data['subtotal']);
          final grandTotal = _toNum(data['grandTotal']);

          // ✅ Keep your exact total payable formula (same as your old code)
          final totalPayable = totalAmount + delivery - discount;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== TOP SUMMARY CARD =====
                _SummaryCard(
                  orderId: widget.orderId,
                  orderNumber: orderNumber,
                  dateText: createdAt.split(' ').first,
                  amountText: "₹${totalAmount.toStringAsFixed(0)}",
                  paymentChip: PaymentChip(status: paymentStatus),
                  statusDropdown: statusBadgeDropdown(
                    context: context,
                    currentStatus: orderStatus,
                    orderId: widget.orderId,
                  ),
                ),

                const SizedBox(height: s16),

                // ===== CUSTOMER =====
                SectionCard(
                  icon: Icons.person_outline_rounded,
                  title: "Customer",
                  child: _KeyValueGrid(
                    rows: [
                      KeyValue(
                        label: "Email",
                        value: (data['userEmail'] ?? 'N/A').toString(),
                        canCopy: true,
                      ),
                      KeyValue(
                        label: "User ID",
                        value: (data['userId'] ?? 'N/A').toString(),
                        canCopy: true,
                      ),
                    ],
                    onCopy: (v, label) =>
                        _copyToClipboard(context, v, label: label),
                  ),
                ),

                const SizedBox(height: s16),

                // ===== ADDRESS =====
                SectionCard(
                  icon: Icons.location_on_outlined,
                  title: "Delivery Address",
                  child: _AddressBlock(address: address),
                ),

                const SizedBox(height: s16),

                // ===== ITEMS =====
                SectionCard(
                  icon: Icons.shopping_cart_outlined,
                  title: "Items",
                  child: _orderItems(widget.orderId),
                ),

                const SizedBox(height: s16),

                // ===== BILL SUMMARY =====
                SectionCard(
                  icon: Icons.receipt_long_outlined,
                  title: "Bill Summary",
                  child: Column(
                    children: [
                      _BillRow(
                        label: "Subtotal",
                        value: "₹${subtotal.toStringAsFixed(0)}",
                      ),
                      const SizedBox(height: s8),
                      _BillRow(
                        label: "Delivery",
                        value: "₹${delivery.toStringAsFixed(0)}",
                      ),
                      const SizedBox(height: s8),
                      _BillRow(
                        label: "Discount",
                        value: "- ₹${discount.toStringAsFixed(0)}",
                        valueColor: Colors.red,
                      ),
                      const SizedBox(height: s12),
                      _SoftDivider(),
                      const SizedBox(height: s12),
                      _BillRow(
                        label: "Total",
                        value: "₹${grandTotal.toStringAsFixed(0)}",
                      ),
                      const SizedBox(height: s12),
                      _BillRow(
                        label: "Payment Method",
                        value: (data['paymentMethod'] ?? 'N/A').toString(),
                      ),
                      const SizedBox(height: s12),
                      _SoftDivider(),
                      const SizedBox(height: s12),
                      _BillRow(
                        label: "Total Payable",
                        value: "₹${totalPayable.toStringAsFixed(0)}",
                        isEmphasis: true,
                        valueColor: _primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===================== ITEMS (KEEP PATH EXACTLY) =====================
  Widget _orderItems(String orderId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        // Skeleton loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ItemsSkeleton(count: 3);
        }

        if (!snapshot.hasData) {
          return const _ItemsSkeleton(count: 3);
        }

        if (snapshot.data!.docs.isEmpty) {
          return const _EmptyState(
            icon: Icons.inventory_2_outlined,
            title: "No items",
            subtitle: "This order doesn't contain any items.",
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final item = doc.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ItemTile(
                imageUrl: (item['imageUrl'] ?? '').toString(),
                name: (item['name'] ?? 'Item').toString(),
                qty: _toInt(item['quantity']),
                price: _toNum(item['unitPrice']), // ✅ FIX
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ===================== UTIL =====================
  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    final s = v.toString();
    return num.tryParse(s) ?? 0;
  }

  int _toInt(dynamic v) {
    if (v == null) return 1;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 1;
  }

  void _copyToClipboard(
    BuildContext context,
    String value, {
    required String label,
  }) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copied"),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// =======================
// PREMIUM WIDGETS
// =======================

class _SummaryCard extends StatelessWidget {
  final String orderId;
  final String orderNumber;
  final String dateText;
  final String amountText;
  final Widget paymentChip;
  final Widget statusDropdown;

  const _SummaryCard({
    required this.orderId,
    required this.orderNumber,
    required this.dateText,
    required this.amountText,
    required this.paymentChip,
    required this.statusDropdown,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: _border),
        gradient: LinearGradient(
          colors: [Colors.white, _primary.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #$orderNumber",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: _textSecondary,
                        ),
                        SizedBox(width: 6),
                        // Date text below (actual date is added via widget)
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // RIGHT
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  paymentChip,
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // STATUS PILL
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 18, color: _textSecondary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Order status",
                  style: TextStyle(
                    color: _textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 190, child: statusDropdown),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF4F46E5).withOpacity(0.10),
                  border: Border.all(
                    color: const Color(0xFF4F46E5).withOpacity(0.18),
                  ),
                ),
                child: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              const Text(" ", style: TextStyle(color: _textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class KeyValue {
  final String label;
  final String value;
  final bool canCopy;

  KeyValue({required this.label, required this.value, this.canCopy = false});
}

class _KeyValueGrid extends StatelessWidget {
  final List<KeyValue> rows;
  final void Function(String value, String label) onCopy;

  const _KeyValueGrid({required this.rows, required this.onCopy});

  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE8ECF4);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 420;

        if (isNarrow) {
          // Label ABOVE value (mobile safe)
          return Column(
            children: rows.map((r) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                    color: const Color(0xFFF8FAFF),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.label,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.value,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (r.canCopy)
                            IconButton(
                              tooltip: "Copy ${r.label}",
                              onPressed: () => onCopy(r.value, r.label),
                              icon: const Icon(Icons.copy_rounded, size: 18),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }

        // Desktop: 2 column grid style
        return Column(
          children: rows.map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      r.label,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (r.canCopy)
                    IconButton(
                      tooltip: "Copy ${r.label}",
                      onPressed: () => onCopy(r.value, r.label),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final Map address;

  const _AddressBlock({required this.address});

  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE8ECF4);

  @override
  Widget build(BuildContext context) {
    if (address.isEmpty) {
      return const _EmptyState(
        icon: Icons.location_off_outlined,
        title: "No address",
        subtitle: "Delivery address is not available for this order.",
      );
    }

    final line1 = "${address['street'] ?? ''}";
    final line2 = "${address['city'] ?? ''}, ${address['state'] ?? ''}";
    final line3 = "${address['zip'] ?? ''}, ${address['country'] ?? ''}";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        color: const Color(0xFFF8FAFF),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.place_outlined, color: _textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line1.isEmpty ? "—" : line1,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  line2.trim() == "," ? "—" : line2,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  line3.trim() == "," ? "—" : line3,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int qty;
  final num price;

  const ItemTile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.qty,
    required this.price,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // THUMB
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 54,
              width: 54,
              color: const Color(0xFFF1F5FF),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: _textSecondary),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      color: _textSecondary,
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // NAME + QTY
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                _QtyPill(qty: qty),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // PRICE
          Text(
            "₹${price.toStringAsFixed(0)}",
            style: const TextStyle(
              color: _primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  final int qty;
  const _QtyPill({required this.qty});

  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE8ECF4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _border),
        color: const Color(0xFFF8FAFF),
      ),
      child: Text(
        "Qty: $qty",
        style: const TextStyle(
          color: _textSecondary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmphasis;
  final Color? valueColor;

  const _BillRow({
    required this.label,
    required this.value,
    this.isEmphasis = false,
    this.valueColor,
  });

  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isEmphasis ? _textPrimary : _textSecondary,
              fontWeight: isEmphasis ? FontWeight.w900 : FontWeight.w800,
              fontSize: isEmphasis ? 14 : 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: valueColor ?? _textPrimary,
            fontWeight: isEmphasis ? FontWeight.w900 : FontWeight.w900,
            fontSize: isEmphasis ? 16 : 13,
            letterSpacing: isEmphasis ? -0.2 : 0,
          ),
        ),
      ],
    );
  }
}

class _SoftDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00E8ECF4), Color(0xFFE8ECF4), Color(0x00E8ECF4)],
        ),
      ),
    );
  }
}

// =======================
// CHIPS
// =======================

class PaymentChip extends StatelessWidget {
  final String status;
  const PaymentChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    if (s.contains('paid')) return _Chip(text: "Paid", color: Colors.green);
    if (s.contains('pend')) return _Chip(text: "Pending", color: Colors.amber);
    return _Chip(text: "Unpaid", color: Colors.red);
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

// =======================
// SKELETON + EMPTY + LOADER
// =======================

class _ItemsSkeleton extends StatelessWidget {
  final int count;
  const _ItemsSkeleton({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 10),
          child: const _SkeletonItem(),
        );
      }),
    );
  }
}

class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _SkBox(w: 54, h: 54, r: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SkBox(w: 180, h: 12, r: 999),
                SizedBox(height: 10),
                _SkBox(w: 90, h: 12, r: 999),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _SkBox(w: 52, h: 12, r: 999),
        ],
      ),
    );
  }
}

class _SkBox extends StatelessWidget {
  final double w;
  final double h;
  final double r;
  const _SkBox({required this.w, required this.h, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2FA),
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 26,
        width: 26,
        child: CircularProgressIndicator(strokeWidth: 2.6),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8ECF4)),
            ),
            child: Icon(icon, color: _textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
