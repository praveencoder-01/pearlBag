import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          // 🔸 BRAND
          Center(
            child: const Text(
              'Pearl Bags',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const Spacer(),

          // 🔸 NAV ITEMS (ONLY ON DESKTOP)
          if (isDesktop) ...[
            _NavItem(title: 'Home', onTap: () {}),
            const SizedBox(width: 24),
            _NavItem(
              title: 'About',
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
            const SizedBox(width: 32),
          ],
        ],
      ),
    );
  }
}

/// 🔹 NAV ITEM
class _NavItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _NavItem({required this.title, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 1.2,
              width: _hover ? widget.title.length * 10.0 : 0,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
