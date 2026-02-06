import 'package:flutter/material.dart';
import 'package:food_website/screens/account_screen.dart';
import 'package:food_website/screens/cart_screen.dart';
// ✅ Replace these imports with your real screens (if they exist)
import 'package:food_website/screens/home_screen.dart';
import 'package:food_website/screens/shop_screen.dart';
import 'package:food_website/theme/app_colors.dart';
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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Replace ShopScreen/ProfileScreen later with your real screens
  final List<Widget> _screens = [
    HomeScreen(),
    ShopScreen(),
    CartScreen(),
    AccountScreen(),

    // ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _isSearching ? null : SiteDrawerLeft(),
      appBar: SiteHeader(
        isSearching: _isSearching,
        searchController: _searchController,
        onSearchChanged: (value) {
          setState(() {
            _isSearching = value;
            if (!value) {
              _searchController.clear();
            }
          });
        },
      ),
      extendBody: true, // ⭐ VERY IMPORTANT
      backgroundColor: AppColors.scaffold,

      body: Stack(
        children: [
          _screens[_selectedIndex],
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
                  label: "Shop",
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

// ------------------
// Placeholders (remove later)
// ------------------
