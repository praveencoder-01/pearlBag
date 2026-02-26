import 'package:flutter/material.dart';
import 'package:food_website/admin/theme/_theme.dart';
import 'package:food_website/admin/widgets/header.dart';

/// ----------------------
/// Page Host (Header + content)
/// ----------------------
class PageHost extends StatelessWidget {
  final String title;
  final VoidCallback? onOpenDrawer;
  final Widget child;
  final bool isDesktop;
  final ValueChanged<String> onQuickAction;

  const PageHost({
    super.key,
    required this.title,
    required this.child,
    required this.isDesktop,
    required this.onQuickAction,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTheme.bg,
      child: Column(
        children: [
          // Top header bar (premium, aligned, responsive)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF6F8FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(bottom: BorderSide(color: AdminTheme.border)),
            ),
            child: Padding(
              // ✅ REQUIRED padding
              padding: const EdgeInsets.symmetric(
                horizontal: Space.x16,
                vertical: 10, // ✅ REQUIRED vertical 10
              ),
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final isMobile = Breakpoints.isMobile(w);
                  final isTablet = Breakpoints.isTablet(w);
                  final isDesktop = Breakpoints.isDesktop(w);

                  return ResponsiveHeader(
                    width: w,
                    isMobile: isMobile,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                    title: title,
                    // ✅ Menu only when drawer exists; shown on mobile requirement
                    onOpenDrawer: onOpenDrawer,
                    onQuickAction: onQuickAction,
                  );
                },
              ),
            ),
          ),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
