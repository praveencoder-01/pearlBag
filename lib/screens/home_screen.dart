import 'package:flutter/material.dart';
import 'package:food_website/layout/main_layout.dart';
import 'package:food_website/widgets/site_drawer_left.dart';
import 'package:food_website/widgets/site_drawer_right.dart';

import '../widgets/hero_section.dart';
import '../widgets/site_footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double horizontalPadding;

                    if (constraints.maxWidth > 1200) {
                      horizontalPadding = 50; // desktop
                    } else if (constraints.maxWidth > 800) {
                      horizontalPadding = 60; // tablet
                    } else {
                      horizontalPadding = 24; // mobile
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: const HeroSection(),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SiteFooter()),
            ],
          ),
          const SiteDrawerLeft(),
          const SiteDrawerRight(),
        ],
      ),
    );
  }
}
