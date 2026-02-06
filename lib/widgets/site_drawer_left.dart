import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_website/screens/shop_screen.dart';
import 'package:provider/provider.dart';

import '../providers/drawer_provider.dart';
import '../theme/app_colors.dart';

class SiteDrawerLeft extends StatelessWidget {
  const SiteDrawerLeft({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.scaffold,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Center(
              child: Text(
                'Pearl bags',
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 3.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.black, //  force color
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(height: 15),
            _DrawerItem(
              title: 'HOME',
              category: '',
              icon: FontAwesomeIcons.house,
            ),
            _DrawerItem(
              title: 'ALL PRODUCTS',
              category: null,
              icon: FontAwesomeIcons.bagShopping,
            ),
            _DrawerItem(
              title: 'NEW ARRIVALS',
              category: 'new',
              icon: Icons.fiber_new_outlined,
            ),
            _DrawerItem(
              title: 'BEST SELLER',
              category: 'best',
              icon: Icons.local_fire_department_outlined,
            ),
            _DrawerItem(
              title: 'WISHLIST',
              category: 'wishlist',
              icon: Icons.favorite,
            ),
            _DrawerItem(
              title: 'MY ORDER',
              category: '',
              icon: Icons.fire_truck_rounded,
            ),
            SizedBox(height: 350),
            Divider(color: Colors.black12, thickness: 1),
            _DrawerItem(title: 'ABOUT US', icon: Icons.circle_outlined),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? category;
  const _DrawerItem({required this.title, this.category, required this.icon});

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  // bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<DrawerProvider>().closeAll();

          final nav = Navigator.of(context, rootNavigator: true);

          // go back to root first
          nav.popUntil((route) => route.isFirst);

          // then open products
          nav.push(
            MaterialPageRoute(
              builder: (_) => ShopScreen(initialCategory: widget.category),
            ),
          );
        },

        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(widget.icon),
                  SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w500,
                      color: Colors.black, //  force color
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
