import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';
import 'package:food_website/screens/cart_screen.dart';
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
  final FocusNode _homeSearchFocus = FocusNode();

  int _selectedIndex = 0;
  late final VoidCallback _tabListener;
  String _shopSearchQuery = "";
  List<Product> _suggestions = [];
  bool _loadingSuggest = false;
  Timer? _suggestDebounce;

  Future<void> _fetchSuggestions(String text) async {
    final q = text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _loadingSuggest = true);

    try {
      // ✅ SIMPLE method: fetch a small batch and filter locally
      // (Firestore "contains" query directly support nahi karta)
      final snap = await FirebaseFirestore.instance
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .limit(60)
          .get();

      final products = snap.docs
          .map((d) => Product.fromMap(d.id, d.data()))
          .toList();

      final filtered = products
          .where((p) {
            final name = p.name.toLowerCase();
            return name.contains(q);
          })
          .take(8)
          .toList();

      if (!mounted) return;
      setState(() => _suggestions = filtered);
    } catch (e) {
      if (!mounted) return;
      setState(() => _suggestions = []);
    } finally {
      if (!mounted) return;
      setState(() => _loadingSuggest = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = AppNavigation.tabIndex.value;

    _tabListener = () {
      debugPrint(
        "MAINSHELL: tabIndex listener -> ${AppNavigation.tabIndex.value}",
      );
      setState(() {
        _selectedIndex = AppNavigation.tabIndex.value;
      });
    };

    AppNavigation.tabIndex.addListener(_tabListener);
  }

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  // String searchQuery = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    AppNavigation.tabIndex.removeListener(_tabListener); // 👈 IMPORTANT
    _searchController.dispose();
    _suggestDebounce?.cancel();
    _homeSearchFocus.dispose();

    super.dispose();
  }

  Widget _currentScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen();
      case 1:
        debugPrint(
          "MAINSHELL: building ShopScreen with query='$_shopSearchQuery'",
        );
        return ShopScreen(
          key: ValueKey(_shopSearchQuery), // ✅ add this
          searchQuery: _shopSearchQuery,
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
    debugPrint("MAINSHELL: _onItemTapped -> $index (before: $_selectedIndex)");
    // close drawer if open
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }

    setState(() {
      _isSearching = false;
      _searchController.clear();
      _selectedIndex = index;
      if (index != 1) _shopSearchQuery = "";
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
        focusNode: _homeSearchFocus,
        onSearchChanged: (value) {
          setState(() {
            _isSearching = value;
            if (!value) {
              _searchController.clear();
              _suggestions = [];
            }
          });

          if (value) {
            Future.delayed(const Duration(milliseconds: 100), () {
              _homeSearchFocus.requestFocus();
            });
          }
        },

        onQueryChanged: (text) {
          debugPrint("MAINSHELL: onQueryChanged -> '$text'");

          _suggestDebounce?.cancel();
          _suggestDebounce = Timer(const Duration(milliseconds: 250), () {
            _fetchSuggestions(text);
          });
        },

        onSearchSubmit: (q) {
          debugPrint("MAINSHELL: onSearchSubmit -> '$q'");
          final query = q.trim();
          if (query.isEmpty) return;

          setState(() {
            _shopSearchQuery = query;
            _isSearching = false;
            _selectedIndex = 1;
            _suggestions = [];
          });

          debugPrint(
            "MAINSHELL: set shopQuery='$_shopSearchQuery', selectedIndex=$_selectedIndex",
          );

          _searchController.clear();
          AppNavigation.tabIndex.value = 1;
          debugPrint("MAINSHELL: tabIndex notifier set to 1");
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
          /// 1️⃣ Normal screen (Home / Shop / Cart / Profile)
          _currentScreen(),

          /// 2️⃣ WHITE SEARCH OVERLAY (THIS HIDES HOME SCREEN)
          if (_isSearching)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _suggestions = [];
                  });
                },
                child: Container(color: Colors.white),
              ),
            ),

          /// 3️⃣ SUGGESTION DROPDOWN (ALWAYS TOP LAYER)
          if (_isSearching)
            Positioned(
              // top: , // just below search bar
              // left: 12,
              // right: 12,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: _loadingSuggest
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _suggestions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("No results found"),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _suggestions.length,
                          itemBuilder: (context, i) {
                            final p = _suggestions[i];

                            return ListTile(
                              /// 🔵 PRODUCT IMAGE
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  p.imageUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 44,
                                    height: 44,
                                    color: Colors.black12,
                                    child: const Icon(Icons.image),
                                  ),
                                ),
                              ),

                              /// 🔵 PRODUCT NAME
                              title: Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              /// 🔵 CLICK → OPEN SHOP FILTERED
                              onTap: () {
                                setState(() {
                                  _shopSearchQuery = p.name;
                                  _isSearching = false;
                                  _selectedIndex = 1;
                                  _suggestions = [];
                                });

                                _searchController.clear();
                                AppNavigation.tabIndex.value = 1;
                              },
                            );
                          },
                        ),
                ),
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
