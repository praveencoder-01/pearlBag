import 'package:flutter/material.dart';
import 'package:food_website/admin/admin_setting_screen.dart';
import 'package:food_website/admin/orders/admin_orders_screen.dart';
import 'package:food_website/admin/products/admin_product_list.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "Admin Panel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
  leading: const Icon(Icons.inventory),
  title: const Text('Product Management'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminProductListScreen(),
      ),
    );
  },
),


          ListTile(
  leading: const Icon(Icons.receipt_long),
  title: const Text("Orders"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminOrdersScreen(),
      ),
    );
  },
),


          const Spacer(),

          ListTile(
  leading: const Icon(Icons.settings),
  title: const Text("Admin Setting"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminSettingsScreen(),
      ),
    );
  },
),
        ],
      ),
    );
  }
}
