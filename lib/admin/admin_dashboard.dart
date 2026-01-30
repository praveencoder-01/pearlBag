import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/widgets/admin_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
        ],
      ),

      drawer: const AdminDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, productSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .snapshots(),
              builder: (context, orderSnap) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, userSnap) {
                    final productCount = productSnap.data?.docs.length ?? 0;
                    final orderCount = orderSnap.data?.docs.length ?? 0;
                    final userCount = userSnap.data?.docs.length ?? 0;

                    final today = DateTime.now();

                    final todayOrdersList =
                        orderSnap.data?.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['createdAt'] == null) return false;

                          final date = (data['createdAt'] as Timestamp)
                              .toDate();

                          return date.year == today.year &&
                              date.month == today.month &&
                              date.day == today.day;
                        }).toList() ??
                        [];

                    final todayOrdersCount = todayOrdersList.length;

                    final todayRevenue = todayOrdersList.fold<double>(0, (
                      sum,
                      doc,
                    ) {
                      final data = doc.data() as Map<String, dynamic>;
                      return sum + (data['totalAmount'] ?? 0);
                    });

                    return GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.8,
                          ),
                      children: [
                        DashboardCard(
                          title: "Today Orders",
                          value: todayOrdersCount.toString(),
                          icon: Icons.today,
                          color: Colors.purple,
                        ),
                        DashboardCard(
                          title: "Today Revenue",
                          value: "₹${todayRevenue.toStringAsFixed(0)}",
                          icon: Icons.currency_rupee,
                          color: Colors.teal,
                        ),
                        DashboardCard(
                          title: "Products",
                          value: productCount.toString(),
                          icon: Icons.fastfood,
                          color: Colors.orange,
                        ),
                        DashboardCard(
                          title: "Orders",
                          value: orderCount.toString(),
                          icon: Icons.shopping_bag,
                          color: Colors.green,
                        ),
                        DashboardCard(
                          title: "Users",
                          value: userCount.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 26),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
