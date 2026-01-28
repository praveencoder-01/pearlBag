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
  // List<Product> _filteredProducts = [];
  // bool _isSearching = false;
  // final TextEditingController _controller = TextEditingController();

  // void _onSearch(String value) {
  //   setState(() {
  //     _filteredProducts = dummyProducts
  //         .where((p) => p.name.toLowerCase().contains(value.toLowerCase()))
  //         .toList();
  //   });
  // }

  // void _clearSearch() {
  //   setState(() {
  //     _isSearching = false;
  //     _filteredProducts.clear();
  //     _controller.clear();
  //     widget.onSearchChanged?.call(false);
  //   });
  // }

  @override
Widget build(BuildContext context) {
  return Container(
    height: 80,
    padding: const EdgeInsets.symmetric(horizontal: 32),
    color: Colors.transparent,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            TextButton(
              onPressed: () =>
                  context.read<DrawerProvider>().openLeft(),
              child: const Text('MENU'),
            ),
            TextButton(
  onPressed: () {
    widget.onSearchChanged?.call(true);
  },
  style: TextButton.styleFrom(
    padding: EdgeInsets.zero, // ❌ no container space
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    splashFactory: NoSplash.splashFactory, // ❌ no splash
    overlayColor: Colors.transparent, // ❌ no highlight
  ),
  child: const Text(
    'Search',
    style: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
  ),
),
          ],
        ),
        const Text(
          'Pearl Bags',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountScreen(),
      ),
    );
  },
  child: const Text('ACCOUNT'),
),

            Consumer<CartProvider>(
              builder: (context, cart, _) => GestureDetector(
                onTap: () =>
                    context.read<DrawerProvider>().openRight(),
                child: Row(
                  children: [
                    const Text('CART'),
                    if (cart.itemCount > 0) Text(': ${cart.itemCount}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  // Widget _buildNormalHeader() {
  //   return Container(
  //     height: 80,
  //     padding: const EdgeInsets.symmetric(horizontal: 32),
  //     color: Colors.white,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Row(
  //           children: [
  //             TextButton(
  //               onPressed: () => context.read<DrawerProvider>().openLeft(),
  //               child: const Text('MENU'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 setState(() => _isSearching = true);
  //                 widget.onSearchChanged?.call(true);
  //               },
  //               child: const Text('Search'),
  //             ),
  //           ],
  //         ),
  //         const Text(
  //           'Pearl Bags',
  //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //         ),
  //         Row(
  //           children: [
  //             TextButton(onPressed: () {}, child: const Text('ACCOUNT')),
  //             Consumer<CartProvider>(
  //               builder: (context, cart, _) => GestureDetector(
  //                 onTap: () => context.read<DrawerProvider>().openRight(),
  //                 child: Row(
  //                   children: [
  //                     const Text('CART'),
  //                     if (cart.itemCount > 0) Text(': ${cart.itemCount}'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

//  Widget _buildSearchHeader() {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
//     child: Column(
//       children: [
//         // 🔍 SEARCH BAR
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 autofocus: true,
//                 onChanged: _onSearch,
//                 decoration: const InputDecoration(
//                   hintText: 'Search products...',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             IconButton(
//   icon: const Icon(Icons.close),
//   onPressed: () {
//     setState(() {
//       _isSearching = false;
//       _controller.clear();
//       _filteredProducts.clear();
//     });
//   },
// ),

//           ],
//         ),

//         const SizedBox(height: 10),

//         // 📦 SEARCH RESULTS
//         Expanded(
//           child: _filteredProducts.isEmpty
//               ? const Center(child: Text('No products found'))
//               : ListView.builder(
//                   itemCount: _filteredProducts.length,
//                   itemBuilder: (context, index) {
//                     final product = _filteredProducts[index];
//                     return ListTile(
//                       leading: Image.asset(
//                         product.imageUrl,
//                         width: 40,
//                         height: 40,
//                         fit: BoxFit.cover,
//                       ),
//                       title: Text(product.name),
//                       subtitle: Text('₹${product.price}'),
//                       onTap: _clearSearch,
//                     );
//                   },
//                 ),
//         ),
//       ],
//     ),
//   );
// }

  }

