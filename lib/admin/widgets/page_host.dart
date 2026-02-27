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
  final bool showSearch;
  final ValueChanged<String> onQuickAction;

  const PageHost({
    super.key,
    required this.title,
    required this.child,
    required this.isDesktop,
    required this.onQuickAction,
    this.onOpenDrawer,
    required this.showSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTheme.bg,
      child: Column(
        children: [
          // Top header bar (premium, aligned, responsive)
          // Top header bar (premium, aligned, responsive)
          Container(
            decoration: BoxDecoration(
              color: AdminTheme.bg, // ✅ yahan shift
              border: const Border(
                bottom: BorderSide(color: AdminTheme.border),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.x16,
                vertical: 10,
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
                    onOpenDrawer: onOpenDrawer,
                    onQuickAction: onQuickAction,
                    showSearch: showSearch,
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
