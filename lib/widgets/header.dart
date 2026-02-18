import 'package:flutter/material.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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

          const SizedBox(width: 18),

          // ✅ NAV ITEMS (desktop only)
          if (isDesktop) ...[
            _NavItem(title: 'Home', onTap: () {}),
            const SizedBox(width: 24),
            _NavItem(
              title: 'About',
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

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

class _SearchDialog extends StatefulWidget {
  const _SearchDialog();

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Search"),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
  final q = value.trim();
  if (q.isEmpty) return;

  // MainShell ko update karna hai:
  // easiest: callback bhejo SiteHeader me
},
        decoration: const InputDecoration(
          hintText: "Search bags...",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text("Search"),
        ),
      ],
    );
  }
}