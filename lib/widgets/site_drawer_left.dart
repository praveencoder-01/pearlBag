import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/drawer_provider.dart';
import '../theme/app_colors.dart';

class SiteDrawerLeft extends StatelessWidget {
  const SiteDrawerLeft({super.key});

  @override
  Widget build(BuildContext context) {
    final isOpen = context.watch<DrawerProvider>().isLeftOpen;
    if (!isOpen) return const SizedBox.shrink();

    return Stack(
      children: [
        // Positioned.fill(
        //   child: GestureDetector(
        //     onTap: () => context.read<DrawerProvider>().closeAll(),
        //     child: Container(color: Colors.black.withOpacity(0.4)),
        //   ),
        // ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          left: 0,
          top: 0,
          bottom: 0,
          width: 320,
          child: Container(
            color: AppColors.scaffoldGrey,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 15),
                Center(
                  child: Text(
                    'Pearl bags',
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.black, //  force color
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                _DrawerItem(title: 'VIEW EVERYTHING '),
                _DrawerItem(title: 'NEW ARRIVALS'),
                _DrawerItem(title: 'BEST SELLER'),
                _DrawerItem(title: 'CASUAL BAGS'),
                _DrawerItem(title: 'HANDBAGS'),
                _DrawerItem(title: 'CLUTCHES'),
                SizedBox(height: 280),
                Divider(color: Colors.black12, thickness: 1),
                _DrawerItem(title: 'ABOUT US'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatefulWidget {
  final String title;
  const _DrawerItem({required this.title});

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // navigation later
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w500,
                  color: Colors.black, //  force color
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 4),

              //  Animated underline
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 1.2,
                width: _isHovered ? _textWidth(widget.title) : 0,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Simple width calculation for underline
  double _textWidth(String text) {
    return text.length * 9.9;
  }
}
