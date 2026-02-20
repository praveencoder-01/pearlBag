// import 'package:flutter/material.dart';

// import '../models/product.dart';
// import 'simple_product_card.dart';

// class ProductHorizontalList extends StatefulWidget {
//   final List<Product> products;

//   const ProductHorizontalList({super.key, required this.products});

//   @override
//   State<ProductHorizontalList> createState() => _ProductHorizontalListState();
// }

// class _ProductHorizontalListState extends State<ProductHorizontalList> {
//   final ScrollController _controller = ScrollController();

//   static const double _cardWidth = 360;
//   static const double _spacing = 20;
//   double get _scrollAmount => _cardWidth + _spacing;

//   void _scrollRight() {
//     final max = _controller.position.maxScrollExtent;
//     final target = (_controller.offset + _scrollAmount).clamp(0.0, max);

//     _controller.animateTo(
//       target,
//       duration: const Duration(milliseconds: 350),
//       curve: Curves.easeOut,
//     );
//   }

//   void _scrollLeft() {
//     final target = (_controller.offset - _scrollAmount).clamp(
//       0.0,
//       double.infinity,
//     );

//     _controller.animateTo(
//       target,
//       duration: const Duration(milliseconds: 350),
//       curve: Curves.easeOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 460,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // 🔹 PRODUCT LIST
//           ListView.separated(
//             controller: _controller,
//             scrollDirection: Axis.horizontal,
//             physics: const NeverScrollableScrollPhysics(), // 🚫 hand scroll OFF
//             padding: const EdgeInsets.symmetric(horizontal: 56),
//             itemCount: widget.products.length,
//             separatorBuilder: (_, __) => const SizedBox(width: _spacing),
//             itemBuilder: (context, index) {
//               return SizedBox(
//                 width: _cardWidth, // ⭐ THIS IS WHERE CARD WIDTH GOES
//                 child: SimpleProductCard(product: widget.products[index]),
//               );
//             },
//           ),

//           // 🔹 LEFT ARROW
// Positioned(
//   left: 10,
//   top: 140, // ⭐ adjust once, then forget
//   child: _ArrowButton(
//     icon: Icons.chevron_left,
//     onTap: _scrollLeft,
//   ),
// ),

// // 🔹 RIGHT ARROW
// Positioned(
//   right: 10,
//   top: 140, // ⭐ same value
//   child: _ArrowButton(
//     icon: Icons.chevron_right,
//     onTap: _scrollRight,
//   ),
// ),

//         ],
//       ),
//     );
//   }
// }

// class _ArrowButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const _ArrowButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       elevation: 4,
//       color: Colors.white,
//       shape: const CircleBorder(),
//       child: InkWell(
//         onTap: onTap,
//         customBorder: const CircleBorder(),
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Icon(icon, size: 28, color: Colors.black87),
//         ),
//       ),
//     );
//   }
// }
