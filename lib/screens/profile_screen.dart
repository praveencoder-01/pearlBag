import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/screens/address_screen.dart';
import 'package:food_website/screens/my_orders_screen.dart';
import 'package:food_website/screens/personal_details_screen.dart';
import 'package:food_website/screens/settings_screen.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // PROFILE CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
 color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 54,
                      width: 54,
                      color: const Color(0xFFEDEDED),
                      child: const Icon(
                        Icons.account_circle_rounded,
                        size: 44,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Fscreation",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "No email",
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // MAIN MENU CARD
            _SectionCard(
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: Icons.person_rounded,
                    title: "Personal Details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PersonalDetailsScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.shopping_bag,
                    title: "My Order",
                    onTap: () {
                      // ✅ same logic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.favorite,
                    title: "My Favourites",
                    onTap: () {
                      // TODO: Favourites screen
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.local_shipping,
                    title: "Shipping Address",
                    onTap: () {
                      // ✅ same logic (Manage Address)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddressScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.settings,
                    title: "Settings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },

                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SECOND MENU CARD (FAQs etc.)
            _SectionCard(
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: Icons.help_outline,
                    title: "FAQs",
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.verified_user_rounded,
                    title: "Privacy Policy",
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // LOGOUT BUTTON (✅ SAME LOGIC)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  context.read<CartProvider>().clearCart();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
         color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 64, right: 14),
            // child: Divider(height: 1),
          ),
      ],
    );
  }
}
