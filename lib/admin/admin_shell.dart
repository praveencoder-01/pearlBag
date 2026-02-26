import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/admin/admin_drawer.dart';
import 'package:food_website/admin/pages/dashboard_page.dart';
import 'package:food_website/admin/pages/products_page.dart';
import 'package:food_website/admin/theme/_theme.dart';
import 'package:food_website/admin/widgets/empty_state.dart';
import 'package:food_website/admin/widgets/page_host.dart';
import 'package:food_website/admin/widgets/sidebar.dart';

enum AdminPage {
  dashboard,
  orders,
  products,
  categories,
  customers,
  reviews,
  coupons,
  analytics,
  notifications,
  settings,
}

/// =======================================================
/// Modern SaaS Admin Dashboard (Responsive + Premium UI)
/// - Keeps all StreamBuilders + shown data + page structure
/// - Responsive breakpoints: <600 mobile, 600–1024 tablet, >1024 desktop
/// - No “SingleChildScrollView everywhere”
/// - Hover states, skeleton loaders, empty states, better typography & spacing
/// - Charts remain fl_chart
/// =======================================================

/// ----------------------
/// Design system / Theme
/// ----------------------

/// ----------------------
/// Shell
/// ----------------------
class PearlAdminShell extends StatefulWidget {
  final String current;
  const PearlAdminShell({super.key, this.current = "dashboard"});

  @override
  State<PearlAdminShell> createState() => _PearlAdminShellState();
}

class _PearlAdminShellState extends State<PearlAdminShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AdminPage _page = AdminPage.dashboard;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  String _title(AdminPage p) {
    switch (p) {
      case AdminPage.dashboard:
        return "Dashboard";
      case AdminPage.orders:
        return "Orders";
      case AdminPage.products:
        return "Products";
      case AdminPage.categories:
        return "Categories";
      case AdminPage.customers:
        return "Customers";
      case AdminPage.reviews:
        return "Reviews";
      case AdminPage.coupons:
        return "Coupons";
      case AdminPage.analytics:
        return "Analytics";
      case AdminPage.notifications:
        return "Notifications";
      case AdminPage.settings:
        return "Settings";
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isDesktop = Breakpoints.isDesktop(w);

        final content = PageHost(
          title: _title(_page),
          isDesktop: isDesktop,
          onOpenDrawer: isDesktop
              ? null
              : () => _scaffoldKey.currentState?.openDrawer(),
          onQuickAction: (action) {
            // Keep functionality intact; hooks are ready for you.
            // Example: open dialogs / export / filters etc.
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildPage(_page, key: ValueKey(_page)),
          ),
        );

        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: AdminTheme.bg,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: Scaffold(
            key: _scaffoldKey,
            drawer: isDesktop ? null : AdminDrawer(current: widget.current),
            body: SafeArea(
              child: Row(
                children: [
                  if (isDesktop)
                    SizedBox(
                      width: 284,
                      child: Sidebar(
                        selected: _page,
                        onSelect: (p) => setState(() => _page = p),
                        onLogout: _logout,
                        isCompact: false,
                      ),
                    ),
                  Expanded(child: content),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(AdminPage page, {Key? key}) {
    switch (page) {
      case AdminPage.dashboard:
        return PearlDashboardPage(key: key);
      case AdminPage.products:
        return PearlProductsPage(key: key);
      case AdminPage.orders:
        return const _ComingSoonPage(
          title: "Orders (list + filters coming next)",
        );
      case AdminPage.reviews:
        return const _ComingSoonPage(title: "Reviews");
      case AdminPage.analytics:
        return const _ComingSoonPage(title: "Analytics");
      case AdminPage.categories:
      case AdminPage.customers:
      case AdminPage.coupons:
      case AdminPage.notifications:
      case AdminPage.settings:
        return _ComingSoonPage(title: _title(page));
    }
  }
}




/// ----------------------
/// Table helpers
/// ----------------------
class TableHeaderRow extends StatelessWidget {
  final List<String> columns;
  final List<int> flex;

  const TableHeaderRow({super.key, required this.columns, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: List.generate(columns.length, (i) {
          final label = columns[i];
          final f = flex[i];
          return Expanded(
            flex: f,
            child: Text(
              label,
              style: TextStyle(
                color: AdminTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ),
    );
  }
}

/// =======================================================
/// Placeholder page
/// =======================================================
class _ComingSoonPage extends StatelessWidget {
  final String title;
  const _ComingSoonPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: AdminTheme.cardDecoration(),
        padding: const EdgeInsets.all(18),
        child: EmptyState(
          icon: Icons.construction_rounded,
          title: title,
          subtitle:
              "This section is coming next. The layout is ready for real data & actions.",
        ),
      ),
    );
  }
}
