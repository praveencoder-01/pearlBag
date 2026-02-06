import 'package:flutter/material.dart';

class SiteHeader extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<bool>? onSearchChanged;

  final bool isSearching;
  final TextEditingController searchController;

  const SiteHeader({
    super.key,
    this.onSearchChanged,
    required this.isSearching,
    required this.searchController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<SiteHeader> createState() => _SiteHeaderState();
}

class _SiteHeaderState extends State<SiteHeader> {
  @override
  Widget build(BuildContext context) {
    // final cart = context.watch<CartProvider>();
    return Material(
      child: SafeArea(
        bottom: false,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              !widget.isSearching
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu),

                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => widget.onSearchChanged?.call(false),
                    ),

              widget.isSearching
                  ? Expanded(
                      child: TextField(
                        controller: widget.searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "search",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      "Pearl Bags",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
              if (!widget.isSearching)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => widget.onSearchChanged?.call(true),
                ),

              // ❌ CLOSE SEARCH
              if (widget.isSearching)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => widget.onSearchChanged?.call(false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
