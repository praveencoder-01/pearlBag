import 'package:flutter/material.dart';
import 'package:food_website/screens/cart_screen.dart';
// ✅ Replace these imports with your real screens (if they exist)
import 'package:food_website/screens/home_screen.dart';
import 'package:food_website/screens/profile_screen.dart';
import 'package:food_website/screens/shop_screen.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:food_website/widgets/app_navigation.dart';
import 'package:food_website/widgets/site_drawer_left.dart';
import 'package:food_website/widgets/site_header.dart';

// If you don't have these yet, keep the placeholder screens below
// and later replace with your real screens.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  late final VoidCallback _tabListener;

  @override
  void initState() {
    super.initState();
    _selectedIndex = AppNavigation.tabIndex.value;

    _tabListener = () {
      setState(() {
        _selectedIndex = AppNavigation.tabIndex.value;
      });
    };

    AppNavigation.tabIndex.addListener(_tabListener);
  }

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    AppNavigation.tabIndex.removeListener(_tabListener); // 👈 IMPORTANT
    _searchController.dispose();
    super.dispose();
  }

  Widget _currentScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return ShopScreen(
          searchQuery: searchQuery, // ✅ yaha live value jayegi
        );
      case 2:
        return CartScreen();
      case 3:
        return ProfileScreen();
      default:
        return HomeScreen();
    }
  }

  void _onItemTapped(int index) {
    // close drawer if open
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }

    setState(() {
      _isSearching = false;
      _searchController.clear();
      _selectedIndex = index;
    });

    // ✅ IMPORTANT: keep notifier in sync
    AppNavigation.tabIndex.value = index;
  }

  PreferredSizeWidget? _buildAppBar() {
    // HOME
    if (_selectedIndex == 0) {
      return SiteHeader(
        isSearching: _isSearching,
        searchController: _searchController,
        onSearchChanged: (value) {
          setState(() {
            _isSearching = value;
            if (!value) _searchController.clear();
          });
        },
      );
    }

    // ✅ SHOP -> remove top bar
    if (_selectedIndex == 1) {
      return null;
    }

    // CART
    if (_selectedIndex == 2) {
      return AppBar(
        title: const Text("Cart"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      );
    }

    // ACCOUNT
    return AppBar(
      title: const Text("Account"),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false, // ✅ ADD THIS
      endDrawerEnableOpenDragGesture: false,
      drawerEdgeDragWidth: 0,
      drawer: _isSearching ? null : SiteDrawerLeft(),
      appBar: _buildAppBar(),

      extendBody: true, // ⭐ VERY IMPORTANT
      backgroundColor: AppColors.scaffold,

      body: Stack(
        children: [
          _currentScreen(),
          if (_isSearching)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
                child: Container(color: AppColors.surface),
              ),
            ),
        ],
      ),

      bottomNavigationBar: IgnorePointer(
        ignoring: _isSearching,
        child: Opacity(
          opacity: _isSearching ? 0 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: NavigationBar(
              height: 56,
              // backgroundColor: const Color.fromARGB(255, 255, 0, 0),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: "Home",
                ),
                NavigationDestination(
                  icon: Icon(Icons.store_outlined),
                  selectedIcon: Icon(Icons.store),
                  label: "Shop",
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  selectedIcon: Icon(Icons.shopping_bag),
                  label: "Cart",
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  selectedIcon: Icon(Icons.account_circle_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class ShopHeader extends StatelessWidget implements PreferredSizeWidget {
//   final TextEditingController controller;
//   final VoidCallback onFilterTap;
//   final ValueChanged<String> onSearchChanged;
//   final VoidCallback onBack;

//   const ShopHeader({
//     super.key,
//     required this.controller,
//     required this.onFilterTap,
//     required this.onSearchChanged,
//     required this.onBack,
//   });

//   @override
//   Size get preferredSize => const Size.fromHeight(80);

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           child: Row(
//             children: [
//               // ✅ MENU (drawer)
//               IconButton(
//                 icon: const Icon(Icons.arrow_back_ios_new),
//                 onPressed: onBack,
//               ),

//               const SizedBox(width: 8),

              // ✅ SEARCH FIELD
              // Expanded(
              //   child: SizedBox(
              //     height: 46,
              //     child: TextField(
              //       controller: controller,
              //       onChanged: onSearchChanged,
              //       decoration: InputDecoration(
              //         hintText: "Search products...",
              //         prefixIcon: const Icon(Icons.search),
              //         filled: true,
              //         contentPadding: const EdgeInsets.symmetric(vertical: 12),
              //         border: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(14),
              //         ),
              //         focusedBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(14),
              //           borderSide: const BorderSide(width: 1),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // const SizedBox(width: 8),

              // // ✅ FILTER ICON
              // SizedBox(
              //   height: 46,
              //   width: 46,
              //   child: Material(
              //     borderRadius: BorderRadius.circular(14),
              //     child: InkWell(
              //       borderRadius: BorderRadius.circular(14),
              //       onTap: onFilterTap,
              //       child: const Icon(Icons.tune),
              //     ),
              //   ),
              // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
