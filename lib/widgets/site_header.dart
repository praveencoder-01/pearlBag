import 'package:flutter/material.dart';
// import 'package:food_website/data/dummy_images.dart';
// import 'package:food_website/models/product.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/providers/drawer_provider.dart';
import 'package:food_website/screens/account_screen.dart';
import 'package:provider/provider.dart';

class SiteHeader extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<bool>? onSearchChanged;

  const SiteHeader({super.key, this.onSearchChanged});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<SiteHeader> createState() => _SiteHeaderState();
}

class _SiteHeaderState extends State<SiteHeader> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT SIDE
          Row(
            children: [
              HoverUnderlineText(
                text: 'MENU',
                onTap: () => context.read<DrawerProvider>().openLeft(),
              ),
              const SizedBox(width: 32),
              HoverUnderlineText(
                text: 'SEARCH',
                onTap: () {
                  widget.onSearchChanged?.call(true);
                },
              ),
            ],
          ),

          // CENTER BRAND
          const Text(
            'Pearl Bags',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          // RIGHT SIDE
          Row(
            children: [
              HoverUnderlineText(
                text: 'ACCOUNT',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  );
                },
              ),
              const SizedBox(width: 32),
              HoverUnderlineText(
                text: 'CART',
                trailing: cart.itemCount > 0 ? ': ${cart.itemCount}' : null,
                onTap: () => context.read<DrawerProvider>().openRight(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class HoverUnderlineText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final String? trailing;

  const HoverUnderlineText({
    super.key,
    required this.text,
    required this.onTap,
    this.trailing,
  });

  @override
  State<HoverUnderlineText> createState() => _HoverUnderlineTextState();
}

class _HoverUnderlineTextState extends State<HoverUnderlineText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.translucent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 MAIN TEXT (underline applies here)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 1.2,
                      width: _hover ? widget.text.length * 9.5 : 0,
                      color: Colors.black,
                    ),
                  ],
                ),
                // 🔹 TRAILING (fixed, separate, does not affect underline)
                if (widget.trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 14),
                    child: Text(
                      widget.trailing!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
