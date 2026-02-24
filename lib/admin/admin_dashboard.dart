// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:food_website/widgets/admin_drawer.dart';

// class AdminDashboard extends StatelessWidget {
//   const AdminDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         title: const Text(
//           "Admin Dashboard",
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: "Logout",
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               if (context.mounted) {
//                 Navigator.popUntil(context, (route) => route.isFirst);
//               }
//             },
//           ),
//         ],
//       ),

//       drawer: const AdminDrawer(),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('products')
//                 .snapshots(),
//             builder: (context, productSnap) {
//               return StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('orders')
//                     .snapshots(),
//                 builder: (context, orderSnap) {
//                   return StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('users')
//                         .snapshots(),
//                     builder: (context, userSnap) {
//                       final productCount = productSnap.data?.docs.length ?? 0;
//                       final orderCount = orderSnap.data?.docs.length ?? 0;
//                       final userCount = userSnap.data?.docs.length ?? 0;

//                       final today = DateTime.now();

//                       final todayOrdersList =
//                           orderSnap.data?.docs.where((doc) {
//                             final data = doc.data() as Map<String, dynamic>;
//                             if (data['createdAt'] == null) return false;
//                             final date = (data['createdAt'] as Timestamp)
//                                 .toDate();
//                             return date.year == today.year &&
//                                 date.month == today.month &&
//                                 date.day == today.day;
//                           }).toList() ??
//                           [];

//                       final todayOrdersCount = todayOrdersList.length;

//                       final todayRevenue = todayOrdersList.fold<double>(0, (
//                         sum,
//                         doc,
//                       ) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         final amount = (data['totalAmount'] ?? 0);
//                         return sum + (amount is num ? amount.toDouble() : 0.0);
//                       });

//                       return LayoutBuilder(
//                         builder: (context, constraints) {
//                           final w = constraints.maxWidth;
//                           final crossAxisCount = w >= 900
//                               ? 3
//                               : (w >= 520 ? 2 : 2);

//                           return SingleChildScrollView(
//                             padding: const EdgeInsets.only(bottom: 24),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Header strip
//                                 Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.06),
//                                         blurRadius: 16,
//                                         offset: const Offset(0, 10),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       CircleAvatar(
//                                         radius: 22,
//                                         backgroundColor: Colors.black
//                                             .withOpacity(0.06),
//                                         child: const Icon(
//                                           Icons.admin_panel_settings,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: const [
//                                             Text(
//                                               "Overview",
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w700,
//                                               ),
//                                             ),
//                                             SizedBox(height: 2),
//                                             Text(
//                                               "Quick stats of your store",
//                                               style: TextStyle(
//                                                 color: Colors.black54,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 10,
//                                           vertical: 8,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Colors.black.withOpacity(0.06),
//                                           borderRadius: BorderRadius.circular(
//                                             12,
//                                           ),
//                                         ),
//                                         child: const Text(
//                                           "Today",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 const SizedBox(height: 16),

//                                 // Cards grid
//                                 GridView(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   gridDelegate:
//                                       SliverGridDelegateWithFixedCrossAxisCount(
//                                         crossAxisCount: crossAxisCount,
//                                         crossAxisSpacing: 14,
//                                         mainAxisSpacing: 14,
//                                         childAspectRatio: w < 420 ? 1.55 : 1.75,
//                                       ),
//                                   children: [
//                                     DashboardCard(
//                                       title: "Today Orders",
//                                       value: todayOrdersCount.toString(),
//                                       icon: Icons.receipt_long,
//                                       color: Colors.deepPurple,
//                                     ),
//                                     DashboardCard(
//                                       title: "Today Revenue",
//                                       value:
//                                           "₹${todayRevenue.toStringAsFixed(0)}",
//                                       icon: Icons.currency_rupee,
//                                       color: Colors.teal,
//                                     ),
//                                     DashboardCard(
//                                       title: "Products",
//                                       value: productCount.toString(),
//                                       icon: Icons.inventory_2,
//                                       color: Colors.orange,
//                                     ),
//                                     DashboardCard(
//                                       title: "Orders",
//                                       value: orderCount.toString(),
//                                       icon: Icons.shopping_bag,
//                                       color: Colors.green,
//                                     ),
//                                     DashboardCard(
//                                       title: "Users",
//                                       value: userCount.toString(),
//                                       icon: Icons.people_alt,
//                                       color: Colors.blue,
//                                     ),
//                                     DashboardCard(
//                                       title: "Pending (demo)",
//                                       value: "-",
//                                       icon: Icons.pending_actions,
//                                       color: Colors.redAccent,
//                                     ),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 16),

//                                 // Small info section (optional)
//                                 Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.06),
//                                         blurRadius: 16,
//                                         offset: const Offset(0, 10),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Row(
//                                     children: const [
//                                       Icon(
//                                         Icons.tips_and_updates,
//                                         color: Colors.black54,
//                                       ),
//                                       SizedBox(width: 10),
//                                       Expanded(
//                                         child: Text(
//                                           "Tip: Keep product images optimized for faster loading.",
//                                           style: TextStyle(
//                                             color: Colors.black54,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DashboardCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const DashboardCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [color.withOpacity(0.18), Colors.white],
//         ),
//         border: Border.all(color: color.withOpacity(0.18)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 18,
//             offset: const Offset(0, 12),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 height: 44,
//                 width: 44,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.14),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.06),
//                   borderRadius: BorderRadius.circular(999),
//                 ),
//                 child: const Text(
//                   "Live",
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ],
//           ),

//           const Spacer(),

//           // value: auto fit (no overflow)
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             alignment: Alignment.centerLeft,
//             child: Text(
//               value,
//               maxLines: 1,
//               style: TextStyle(
//                 fontSize: 34,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.black.withOpacity(0.88),
//               ),
//             ),
//           ),

//           const SizedBox(height: 6),

//           Text(
//             title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black.withOpacity(0.55),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
