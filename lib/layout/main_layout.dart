import 'package:flutter/material.dart';
import 'package:food_website/providers/drawer_provider.dart';
import 'package:food_website/widgets/site_drawer_left.dart';
import 'package:food_website/widgets/site_drawer_right.dart';
// import 'package:food_website/widgets/site_footer.dart';
import 'package:food_website/widgets/site_header.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final drawer = context.watch<DrawerProvider>();

    return Stack(
      children: [
        // 🔹 GRADIENT BACKGROUND (APP-WIDE)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter, // to top
              end: Alignment.topCenter,
              colors: [Color(0xFF2BC0E4), Color(0xFFEAECC6)],
            ),
          ),
        ),

        Scaffold(
          
          backgroundColor: Colors.transparent, // 🔑 IMPORTANT
          appBar: const SiteHeader(),
          body: child,
          
        ),
        


        if (drawer.isAnyOpen)
          GestureDetector(
            onTap: () => drawer.closeAll(),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

        const SiteDrawerLeft(),
        const SiteDrawerRight(),
      ],
      
    );
    
  }
}
