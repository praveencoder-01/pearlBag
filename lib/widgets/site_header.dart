import 'package:flutter/material.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/providers/drawer_provider.dart';
import 'package:provider/provider.dart';

class SiteHeader extends StatefulWidget implements PreferredSizeWidget {
  const SiteHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<SiteHeader> createState() => _SiteHeaderState();
}

class _SiteHeaderState extends State<SiteHeader> {
  bool _isSearching = false;

@override
Widget build(BuildContext context) {
  return Container(
    height: 80,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _isSearching
          ? _buildSearchHeader()
          : _buildNormalHeader(),
    ),
  );
}


  // 🔹 NORMAL HEADER
  Widget _buildNormalHeader() {
    return Stack(
      alignment: Alignment.center,
      
      children: [
        // LEFT
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<DrawerProvider>().openLeft();
                },
                child: const Text(
                  'MENU',
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  setState(() => _isSearching = true);
                },
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.1,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        // CENTER
        const Text(
          'Pearl bags',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),

        // RIGHT
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  'ACCOUNT',
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  return GestureDetector(
                    onTap: () {
                      context.read<DrawerProvider>().openRight();
                    },
                    child: Row(
                      children: [
                        const Text(
                          'CART',
                          style: TextStyle(
                            color: Colors.black,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (cart.itemCount > 0)
                          Text(': ${cart.itemCount}'),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildSearchHeader() {
  return Container(
    key: const ValueKey('search'),
    height: 80,
    width: double.infinity,
    color: const Color(0xFFE7E6DD), // hardgraft-ish beige
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(3),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: const TextField(
              autofocus: true,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        GestureDetector(
          onTap: () {
            setState(() => _isSearching = false);
          },
          child: const Icon(
            Icons.close,
            size: 18,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}



}
