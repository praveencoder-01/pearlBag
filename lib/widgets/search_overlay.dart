import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/providers/product_provider.dart';
import 'package:provider/provider.dart';

class HeaderSearchOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const HeaderSearchOverlay({super.key, required this.onClose});

  @override
  State<HeaderSearchOverlay> createState() => _HeaderSearchOverlayState();
}

class _HeaderSearchOverlayState extends State<HeaderSearchOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animController;
  late Animation<Offset> _slide;

  List<Product> allProducts = [];
  List<Product> filtered = [];

  @override
  void initState() {
    super.initState();

    allProducts = context.read<ProductProvider>().products;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    _controller.addListener(_search);
  }

  void _search() {
    final q = _controller.text.toLowerCase();

    setState(() {
      filtered = q.isEmpty
          ? []
          : allProducts.where((p) => p.name.toLowerCase().contains(q)).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: SlideTransition(
        position: _slide,
        child: Container(
  height: 80,
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 32),
  color: Colors.white,
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: widget.onClose,
      ),
    ],
  ),
),

      ),
    );
  }
}
