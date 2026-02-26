import 'package:flutter/material.dart';
import 'package:food_website/admin/admin_shell.dart';
import 'package:food_website/admin/theme/_theme.dart'; 
import 'package:food_website/admin/widgets/common.dart';

/// ======================
/// Sidebar (modern SaaS)
/// ======================
class Sidebar extends StatefulWidget {
  final AdminPage selected;
  final ValueChanged<AdminPage> onSelect;
  final VoidCallback onLogout;
  final bool isCompact;

  const Sidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onLogout,
    required this.isCompact,
  });

  @override
  State<Sidebar> createState() => SidebarState();
}

class SidebarState extends State<Sidebar> {
  bool _collapsed = false; // optional collapsed mode support

  @override
  Widget build(BuildContext context) {
    final collapsed = widget.isCompact ? true : _collapsed;

    Widget item(AdminPage page, IconData icon, String label) {
      final active = widget.selected == page;

      return Hoverable(
        borderRadius: 14,
        builder: (hovered) {
          final bg = active
              ? AdminTheme.primary.withOpacity(0.18)
              : hovered
                  ? Colors.white.withOpacity(0.06)
                  : Colors.transparent;

          final iconColor = active ? Colors.white : const Color(0xFFD0D7E6);
          final textColor = active ? Colors.white : const Color(0xFFD0D7E6);

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => widget.onSelect(page),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 10 : 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active
                      ? AdminTheme.primary.withOpacity(0.50)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                children: [
                  // Active indicator bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 18,
                    width: active ? 4 : 0,
                    margin: EdgeInsets.only(right: active ? 10 : 0),
                    decoration: BoxDecoration(
                      color: AdminTheme.success,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Icon(icon, color: iconColor, size: 20),
                  if (!collapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontWeight:
                              active ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      decoration: const BoxDecoration(color: AdminTheme.sidebarBg),
      child: Column(
        children: [
          // Brand header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [AdminTheme.primary, AdminTheme.primary2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330B1220),
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pearl Bags",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Admin Console",
                          style: TextStyle(
                            color: Color(0xFFB7C1D6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!widget.isCompact)
                  IconButton(
                    tooltip: collapsed ? "Expand" : "Collapse",
                    onPressed: () => setState(() => _collapsed = !_collapsed),
                    icon: Icon(
                      collapsed
                          ? Icons.keyboard_double_arrow_right
                          : Icons.keyboard_double_arrow_left,
                      color: const Color(0xFFB7C1D6),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          // Navigation
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.sidebarSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  item(AdminPage.dashboard, Icons.grid_view_rounded, "Dashboard"),
                  const SizedBox(height: 10),
                  item(AdminPage.orders, Icons.receipt_long_outlined, "Orders"),
                  const SizedBox(height: 10),
                  item(AdminPage.products, Icons.inventory_2_outlined, "Products"),
                  const SizedBox(height: 10),
                  item(AdminPage.categories, Icons.category_outlined, "Categories"),
                  const SizedBox(height: 10),
                  item(AdminPage.customers, Icons.people_outline, "Customers"),
                  const SizedBox(height: 10),
                  item(AdminPage.reviews, Icons.star_border_rounded, "Reviews"),
                  const SizedBox(height: 10),
                  item(AdminPage.coupons, Icons.confirmation_number_outlined, "Coupons"),
                  const SizedBox(height: 10),
                  item(AdminPage.analytics, Icons.query_stats_rounded, "Analytics"),
                  const SizedBox(height: 10),
                  item(AdminPage.notifications, Icons.notifications_none_rounded, "Notifications"),
                  const SizedBox(height: 10),
                  item(AdminPage.settings, Icons.settings_outlined, "Settings"),
                ],
              ),
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Hoverable(
              borderRadius: 16,
              builder: (hovered) => InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onLogout,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(
                    horizontal: collapsed ? 12 : 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: hovered
                        ? Colors.white.withOpacity(0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFD0D7E6),
                        size: 20,
                      ),
                      if (!collapsed) ...[
                        const SizedBox(width: 10),
                        const Text(
                          "Logout",
                          style: TextStyle(
                            color: Color(0xFFD0D7E6),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}