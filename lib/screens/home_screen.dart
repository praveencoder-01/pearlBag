import 'package:flutter/material.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/hero_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCartFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding;

          if (constraints.maxWidth > 1200) {
            horizontalPadding = 50;
          } else if (constraints.maxWidth > 800) {
            horizontalPadding = 60;
          } else {
            horizontalPadding = 24;
          }

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const HeroSection(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
