import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Luxury theme colors
// Workspace colors (correct SaaS luxury palette)
const cSidebar = Color(0xFF0B0B0B); // brand black
const cBackground = Color(0xFFF5F5F7); // main workspace (Apple style)
const cCard = Color(0xFFFFFFFF); // card surface
const cBorder = Color(0xFFE5E5E7); // thin luxury border
const cTextPrimary = Color(0xFF111111);
const cTextSecondary = Color(0xFF6B6B6B);
const cPearl = Color(0xFFCFCFCF);

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

class PearlAdminShell extends StatefulWidget {
  const PearlAdminShell({super.key});

  @override
  State<PearlAdminShell> createState() => _PearlAdminShellState();
}

class _PearlAdminShellState extends State<PearlAdminShell> {
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
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;

        final content = _PageHost(
          title: _title(_page),
          onOpenDrawer: isDesktop
              ? null
              : () => Scaffold.of(context).openDrawer(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildPage(_page, key: ValueKey(_page)),
          ),
        );

        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: cBackground,
            appBarTheme: const AppBarTheme(
              backgroundColor: cCard,
              foregroundColor: cTextPrimary,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Scaffold(
            drawer: isDesktop
                ? null
                : Drawer(
                    backgroundColor: cSidebar,
                    child: SafeArea(
                      child: _Sidebar(
                        selected: _page,
                        onSelect: (p) {
                          setState(() => _page = p);
                          Navigator.pop(context);
                        },
                        onLogout: _logout,
                        isCompact: false,
                      ),
                    ),
                  ),
            body: SafeArea(
              child: Row(
                children: [
                  if (isDesktop)
                    SizedBox(
                      width: 272,
                      child: _Sidebar(
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

/// ======================
/// Sidebar (matte black)
/// ======================
class _Sidebar extends StatelessWidget {
  final AdminPage selected;
  final ValueChanged<AdminPage> onSelect;
  final VoidCallback onLogout;
  final bool isCompact;

  const _Sidebar({
    required this.selected,
    required this.onSelect,
    required this.onLogout,
    required this.isCompact,
  });

  static const cBlack = Color(0xFF0B0B0B);
  static const cWhite = Color(0xFFFFFFFF);
  static const cPearl = Color(0xFFCFCFCF);

  @override
  Widget build(BuildContext context) {
    Widget item(AdminPage page, IconData icon, String label) {
      final active = selected == page;
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSelect(page),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? cPearl.withOpacity(0.55)
                  : Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: active ? cWhite : cPearl, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? cWhite : cPearl,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: cBlack,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: const Text(
              "Pearl Bags",
              style: TextStyle(
                color: cWhite,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                item(
                  AdminPage.dashboard,
                  Icons.grid_view_outlined,
                  "Dashboard",
                ),
                const SizedBox(height: 10),
                item(AdminPage.orders, Icons.receipt_long_outlined, "Orders"),
                const SizedBox(height: 10),
                item(
                  AdminPage.products,
                  Icons.inventory_2_outlined,
                  "Products",
                ),
                const SizedBox(height: 10),
                item(
                  AdminPage.categories,
                  Icons.category_outlined,
                  "Categories",
                ),
                const SizedBox(height: 10),
                item(AdminPage.customers, Icons.people_outline, "Customers"),
                const SizedBox(height: 10),
                item(AdminPage.reviews, Icons.star_border, "Reviews"),
                const SizedBox(height: 10),
                item(
                  AdminPage.coupons,
                  Icons.confirmation_number_outlined,
                  "Coupons",
                ),
                const SizedBox(height: 10),
                item(
                  AdminPage.analytics,
                  Icons.query_stats_outlined,
                  "Analytics",
                ),
                const SizedBox(height: 10),
                item(
                  AdminPage.notifications,
                  Icons.notifications_none,
                  "Notifications",
                ),
                const SizedBox(height: 10),
                item(AdminPage.settings, Icons.settings_outlined, "Settings"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.logout_outlined, color: cPearl, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: cPearl,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================
/// Page Host (Header + content)
/// ======================
class _PageHost extends StatelessWidget {
  final String title;
  final VoidCallback? onOpenDrawer;
  final Widget child;

  const _PageHost({
    required this.title,
    required this.child,
    this.onOpenDrawer,
  });

  // static const cBlack = Color(0xFF0B0B0B);
  // static const cWhite = Color(0xFFFFFFFF);
  static const cPearl = Color(0xFFCFCFCF);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cBackground,
      child: Column(
        children: [
          // Top header bar
          Container(
            decoration: BoxDecoration(
              color: cCard,
              border: Border(bottom: BorderSide(color: cBorder)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                children: [
                  if (onOpenDrawer != null) ...[
                    IconButton(
                      onPressed: onOpenDrawer,
                      icon: Icon(Icons.menu, color: cTextPrimary),
                      tooltip: "Menu",
                    ),
                    const SizedBox(width: 6),
                  ],

                  Text(
                    title,
                    style: const TextStyle(
                      color: cTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(width: 12),
                  Expanded(child: Container()),
                  const SizedBox(width: 12),

                  // Search
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width < 900
                            ? 260
                            : 420,
                        minWidth: 160,
                      ),
                      child: _LuxurySearchField(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Bell
                  _IconPill(
                    icon: Icons.notifications_none,
                    onTap: () {},
                    tooltip: "Notifications",
                  ),

                  const SizedBox(width: 10),

                  // Avatar
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cBorder),
                      color: cBackground,
                    ),
                    child: const Icon(Icons.person_outline, color: cPearl),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Main content area
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxurySearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E7)),
      ),
      child: TextField(
        style: const TextStyle(color: Color(0xFF111111)),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.black.withOpacity(0.55)),
          hintText: "Search orders, products, customers…",
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.40)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _IconPill({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  // static const cPearl = Color(0xFFCFCFCF);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E5E7)),
          ),
          child: Icon(icon, color: Colors.black.withOpacity(0.65)),
        ),
      ),
    );
  }
}

/// ======================
/// Dashboard Page (Slivers = no overflow)
/// ======================
class PearlDashboardPage extends StatelessWidget {
  const PearlDashboardPage({super.key});

  static const cBlack = Color(0xFF0B0B0B);
  static const cWhite = Color(0xFFFFFFFF);
  static const cPearl = Color(0xFFCFCFCF);
  static const cGray = Color(0xFFEDEDED);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, productSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, orderSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, userSnap) {
                final productCount = productSnap.data?.docs.length ?? 0;
                final orderCount = orderSnap.data?.docs.length ?? 0;
                final userCount = userSnap.data?.docs.length ?? 0;

                final totalSales = _sum(
                  orderSnap.data?.docs,
                  key: 'totalAmount',
                );
                final monthlyRevenue =
                    totalSales; // (placeholder) replace with real monthly logic

                return LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final statsCols = w >= 1200 ? 4 : (w >= 820 ? 2 : 1);

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _SectionTitle(
                            title: "Overview",
                            subtitle: "Luxury dashboard summary",
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        SliverPadding(
                          padding: EdgeInsets.zero,
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: statsCols,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: w < 520 ? 2.2 : 2.6,
                                ),
                            delegate: SliverChildListDelegate.fixed([
                              _StatCard(
                                label: "Total Sales",
                                value: "₹${totalSales.toStringAsFixed(0)}",
                              ),
                              _StatCard(
                                label: "Total Orders",
                                value: "$orderCount",
                              ),
                              _StatCard(
                                label: "Total Customers",
                                value: "$userCount",
                              ),
                              _StatCard(
                                label: "Revenue (Monthly)",
                                value: "₹${monthlyRevenue.toStringAsFixed(0)}",
                              ),
                            ]),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 18)),

                        SliverToBoxAdapter(
                          child: _SectionTitle(
                            title: "Analytics",
                            subtitle: "Sales, revenue & order health",
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        SliverToBoxAdapter(
                          child: LayoutBuilder(
                            builder: (context, cc) {
                              final wide = cc.maxWidth >= 1100;
                              final analytics = _OrderAnalytics.fromOrders(
                                orderSnap.data?.docs ?? const [],
                              );
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: wide ? 2 : 1,
                                    child: Column(
                                      children: [
                                        _ChartPanel(
                                          title:
                                              "Sales Analytics (Last 7 Days)",
                                          child: _SalesLineChart(
                                            values: analytics.last7DaysRevenue,
                                            labels: analytics.last7DaysLabels,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        _ChartPanel(
                                          title: "Revenue (Last 6 Months)",
                                          child: _RevenueBarChart(
                                            values:
                                                analytics.last6MonthsRevenue,
                                            labels: analytics.last6MonthsLabels,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (wide) ...[
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 1,
                                      child: _ChartPanel(
                                        title: "Order Status",
                                        child: _OrderStatusDonutChart(
                                          statusCounts: analytics.statusCounts,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 18)),

                        SliverToBoxAdapter(
                          child: LayoutBuilder(
                            builder: (context, cc) {
                              final isDesktop = cc.maxWidth >= 900;

                              if (!isDesktop) {
                                // Tablet layout: stack vertically
                                return Column(
                                  children: [
                                    _LuxuryPanel(
                                      title: "Recent Orders",
                                      child: _OrdersList(
                                        orderSnap.data?.docs ?? const [],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _LuxuryPanel(
                                      title: "Top Selling Products",
                                      child: _TopProducts(
                                        productCount: productCount,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const _LuxuryPanel(
                                      title: "Recent Reviews",
                                      child: _ReviewsList(),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _LuxuryPanel(
                                      title: "Recent Orders",
                                      child: _OrdersTable(
                                        orderSnap.data?.docs ?? const [],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        _LuxuryPanel(
                                          title: "Top Selling Products",
                                          child: _TopProducts(
                                            productCount: productCount,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        const _LuxuryPanel(
                                          title: "Recent Reviews",
                                          child: _ReviewsList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 28)),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  static double _sum(List<QueryDocumentSnapshot>? docs, {required String key}) {
    if (docs == null) return 0;
    double s = 0;
    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final v = data[key];
      if (v is num) s += v.toDouble();
    }
    return s;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: cTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: cTextSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  // static const cWhite = Color(0xFFFFFFFF);
  static const cBlack = Color(0xFF0B0B0B);

  @override
  Widget build(BuildContext context) {
    return _LuxuryCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black.withOpacity(0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: cBlack,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Live",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return _LuxuryPanel(
      title: title,
      child: LayoutBuilder(
        builder: (context, c) {
          // Responsive height without hardcoding huge fixed sizes
          final h = c.maxWidth >= 1100 ? 260.0 : 220.0;
          return SizedBox(height: h, child: child);
        },
      ),
    );
  }
}

class _LuxuryPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _LuxuryPanel({required this.title, required this.child});

  static const cBlack = Color(0xFF0B0B0B);

  @override
  Widget build(BuildContext context) {
    return _LuxuryCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: cBlack,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _LuxuryCard extends StatelessWidget {
  final Widget child;

  const _LuxuryCard({required this.child});

  @override
  Widget build(BuildContext context) {
    // White card on black background, thin border, micro shadow (luxury)
    return Container(
      decoration: BoxDecoration(
        color: cCard,
        border: Border.all(color: cBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------- Chart Data Aggregation (from Firestore orders) ----------
class _OrderAnalytics {
  final List<double> last7DaysRevenue; // index 0..6
  final List<String> last7DaysLabels; // e.g. Mon Tue ...
  final List<double> last6MonthsRevenue; // index 0..5
  final List<String> last6MonthsLabels; // e.g. Sep Oct ...
  final Map<String, int>
  statusCounts; // Pending/Shipped/Delivered/Cancelled/Processing

  _OrderAnalytics({
    required this.last7DaysRevenue,
    required this.last7DaysLabels,
    required this.last6MonthsRevenue,
    required this.last6MonthsLabels,
    required this.statusCounts,
  });

  static _OrderAnalytics fromOrders(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

    // last 7 days (including today)
    final last7 = List<double>.filled(7, 0.0);
    final labels7 = List<String>.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return _dowShort(d.weekday);
    });

    // last 6 months (including current)
    final last6 = List<double>.filled(6, 0.0);
    final labels6 = List<String>.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return _monShort(m.month);
    });

    final status = <String, int>{
      'Pending': 0,
      'Processing': 0,
      'Shipped': 0,
      'Delivered': 0,
      'Cancelled': 0,
    };

    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;

      // amount
      final amountAny = data['totalAmount'];
      final amount = (amountAny is num) ? amountAny.toDouble() : 0.0;

      // createdAt
      final ts = data['createdAt'];
      final created = (ts is Timestamp) ? ts.toDate() : null;

      // status
      final rawStatus = (data['orderStatus'] ?? 'Pending').toString();
      final normalized = _normalizeStatus(rawStatus);
      status[normalized] = (status[normalized] ?? 0) + 1;

      if (created == null) continue;

      // last 7 days bucket
      final createdDay = dayStart(created);
      final today = dayStart(now);
      final diff = today.difference(createdDay).inDays; // 0 = today
      if (diff >= 0 && diff <= 6) {
        final idx = 6 - diff; // left->right oldest..newest
        last7[idx] += amount;
      }

      // last 6 months bucket
      final createdMonth = DateTime(created.year, created.month, 1);
      for (int i = 0; i < 6; i++) {
        final bucketMonth = DateTime(now.year, now.month - (5 - i), 1);
        if (bucketMonth.year == createdMonth.year &&
            bucketMonth.month == createdMonth.month) {
          last6[i] += amount;
          break;
        }
      }
    }

    return _OrderAnalytics(
      last7DaysRevenue: last7,
      last7DaysLabels: labels7,
      last6MonthsRevenue: last6,
      last6MonthsLabels: labels6,
      statusCounts: status,
    );
  }

  static String _dowShort(int weekday) {
    const map = {
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };
    return map[weekday] ?? '';
  }

  static String _monShort(int month) {
    const map = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };
    return map[month] ?? '';
  }

  static String _normalizeStatus(String s) {
    final t = s.toLowerCase();
    if (t.contains('deliver')) return 'Delivered';
    if (t.contains('cancel')) return 'Cancelled';
    if (t.contains('ship')) return 'Shipped';
    if (t.contains('process')) return 'Processing';
    return 'Pending';
  }
}

// ---------- Monochrome Charts ----------
class _SalesLineChart extends StatelessWidget {
  final List<double> values; // 7 values
  final List<String> labels; // 7 labels

  const _SalesLineChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    final maxY = (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b));
    final top = maxY <= 0 ? 100.0 : (maxY * 1.2);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: top,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: top / 4,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: Colors.black.withOpacity(0.08), strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black.withOpacity(0.10)),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: top / 4,
              getTitlesWidget: (v, meta) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  v.toStringAsFixed(0),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (x, meta) {
                final i = x.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.60),
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
              (i) => FlSpot(i.toDouble(), values[i].toDouble()),
            ),
            isCurved: true,
            curveSmoothness: 0.18,
            color: Colors.black.withOpacity(0.85),
            barWidth: 2.2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, p, bar, i) => FlDotCirclePainter(
                radius: 2.6,
                color: Colors.black.withOpacity(0.85),
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.black.withOpacity(0.06),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}

class _RevenueBarChart extends StatelessWidget {
  final List<double> values; // 6 values
  final List<String> labels; // 6 labels

  const _RevenueBarChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    final maxY = (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b));
    final top = maxY <= 0 ? 100.0 : (maxY * 1.25);

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: top,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: top / 4,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: const Color(0x11000000), strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black.withOpacity(0.10)),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: top / 4,
              getTitlesWidget: (v, meta) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  v.toStringAsFixed(0),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (x, meta) {
                final i = x.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.60),
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i].toDouble(),
                width: 14,
                borderRadius: BorderRadius.circular(6),
                color: Colors.black.withOpacity(0.78),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: top,
                  color: Colors.black.withOpacity(0.06),
                ),
              ),
            ],
          );
        }),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}

class _OrderStatusDonutChart extends StatelessWidget {
  final Map<String, int> statusCounts;
  const _OrderStatusDonutChart({required this.statusCounts});

  @override
  Widget build(BuildContext context) {
    final total = statusCounts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return Center(
        child: Text(
          "No data",
          style: TextStyle(
            color: Colors.black.withOpacity(0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Monochrome shades
    final shades = [
      Colors.black.withOpacity(0.85),
      Colors.black.withOpacity(0.65),
      Colors.black.withOpacity(0.45),
      Colors.black.withOpacity(0.28),
      Colors.black.withOpacity(0.16),
    ];

    final keys = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < keys.length; i++) {
      final k = keys[i];
      final v = statusCounts[k] ?? 0;
      if (v == 0) continue;

      sections.add(
        PieChartSectionData(
          value: v.toDouble(),
          color: shades[i % shades.length],
          radius: 30,
          title: "", // keep clean
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 46,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
            duration: const Duration(milliseconds: 250),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: keys.map((k) {
              final v = statusCounts[k] ?? 0;
              if (v == 0) return const SizedBox.shrink();
              final pct = (v / total * 100).toStringAsFixed(0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: shades[keys.indexOf(k) % shades.length],
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        k,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      "$v ($pct%)",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.60),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Recent Orders (table for wide)
class _OrdersTable extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const _OrdersTable(this.docs);

  @override
  Widget build(BuildContext context) {
    final rows = docs.take(6).map((d) {
      final data = d.data() as Map<String, dynamic>;
      final id = d.id;
      final customer = (data['customerName'] ?? '—').toString();
      final product = (data['productName'] ?? 'Pearl Bag').toString();
      final price = (data['totalAmount'] is num)
          ? (data['totalAmount'] as num).toStringAsFixed(0)
          : '0';
      final payment = (data['paymentStatus'] ?? 'Paid').toString();
      final status = (data['orderStatus'] ?? 'Pending').toString();
      final date = (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp)
                .toDate()
                .toString()
                .split(' ')
                .first
          : '—';

      return DataRow(
        cells: [
          DataCell(Text("#${id.substring(0, id.length.clamp(0, 8))}")),
          DataCell(
            SizedBox(
              width: 160,
              child: Text(
                customer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 160,
              child: Text(
                product,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 160,
              child: Text(date, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          DataCell(_Pill(text: payment)),
          DataCell(_Pill(text: status, isStatus: true)),
          DataCell(Text("₹$price")),
        ],
      );
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 42,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 52,
        columnSpacing: 18,
        columns: const [
          DataColumn(label: Text("Order ID")),
          DataColumn(label: Text("Customer")),
          DataColumn(label: Text("Product")),
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Payment")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Price")),
        ],
        rows: rows,
      ),
    );
  }
}

/// Recent Orders (list for mobile)
class _OrdersList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const _OrdersList(this.docs);

  @override
  Widget build(BuildContext context) {
    final items = docs.take(6).toList();
    if (items.isEmpty) {
      return Text(
        "No recent orders.",
        style: TextStyle(color: Colors.black.withOpacity(0.55)),
      );
    }

    return Column(
      children: items.map((d) {
        final data = d.data() as Map<String, dynamic>;
        final id = d.id;
        final customer = (data['customerName'] ?? '—').toString();
        final price = (data['totalAmount'] is num)
            ? (data['totalAmount'] as num).toStringAsFixed(0)
            : '0';
        final status = (data['orderStatus'] ?? 'Pending').toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            color: Colors.black.withOpacity(0.02),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "#${id.substring(0, id.length.clamp(0, 8))}",
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer,
                      style: TextStyle(color: Colors.black.withOpacity(0.65)),
                    ),
                  ],
                ),
              ),
              _Pill(text: status, isStatus: true),
              const SizedBox(width: 10),
              Text(
                "₹$price",
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool isStatus;
  const _Pill({required this.text, this.isStatus = false});

  @override
  Widget build(BuildContext context) {
    final t = text.toLowerCase();
    final bg = Colors.black.withOpacity(0.06);
    final br = Colors.black.withOpacity(0.10);

    // keep it monochrome luxury (no colors)
    String label = text;
    if (isStatus) {
      if (t.contains('pending')) label = "Pending";
      if (t.contains('shipped')) label = "Shipped";
      if (t.contains('delivered')) label = "Delivered";
      if (t.contains('cancel')) label = "Cancelled";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: br),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TopProducts extends StatelessWidget {
  final int productCount;
  const _TopProducts({required this.productCount});

  @override
  Widget build(BuildContext context) {
    // (Demo UI) You can replace with Firestore "topSelling" query later.
    return Column(
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            color: Colors.black.withOpacity(0.02),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.06),
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pearl Mini Bag",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "₹2,499  •  Stock 12",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        );
      }),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  const _ReviewsList();

  @override
  Widget build(BuildContext context) {
    // Demo UI
    Widget review(String name, String msg, int stars) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          color: Colors.black.withOpacity(0.02),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.06),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
              child: const Icon(Icons.image_outlined),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black.withOpacity(0.65)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < stars;
                      return Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 16,
                        color: Colors.black.withOpacity(filled ? 0.75 : 0.25),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        review("Aanya", "Packaging is premium. Bag looks expensive.", 5),
        review("Rohit", "Quality is good. Delivery was fast.", 4),
      ],
    );
  }
}

/// ======================
/// Products Page (management)
/// ======================
class PearlProductsPage extends StatelessWidget {
  const PearlProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? const [];

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, c) {
                  final isDesktop = c.maxWidth >= 900;
                  if (!isDesktop) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Product Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _PrimaryWhiteButton(
                            text: "Add Product",
                            icon: Icons.add,
                            onTap: () {},
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Product Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _PrimaryWhiteButton(
                        text: "Add Product",
                        icon: Icons.add,
                        onTap: () {},
                      ),
                    ],
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            SliverToBoxAdapter(
              child: _LuxuryPanel(
                title: "Products",
                child: LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth >= 980;
                    return wide
                        ? _ProductsTable(docs: docs)
                        : _ProductsList(docs: docs);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        );
      },
    );
  }
}

class _PrimaryWhiteButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryWhiteButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black.withOpacity(0.85)),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _ProductsTable extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const _ProductsTable({required this.docs});

  @override
  Widget build(BuildContext context) {
    final rows = docs.take(12).map((d) {
      final data = d.data() as Map<String, dynamic>;
      final name = (data['name'] ?? 'Pearl Bag').toString();
      final price = (data['price'] is num)
          ? (data['price'] as num).toStringAsFixed(0)
          : '0';
      final stock = (data['stock'] ?? 0);
      final category = (data['category'] ?? 'Bags').toString();
      final inStock = (data['inStock'] ?? true) == true;

      return DataRow(
        cells: [
          DataCell(_ImgThumb(url: (data['imageUrl'] ?? '').toString())),
          DataCell(Text(name)),
          DataCell(_Tag(text: category)),
          DataCell(Text("₹$price")),
          DataCell(Text("$stock")),
          DataCell(
            _StockToggle(
              value: inStock,
              onChanged: (v) {
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(d.id)
                    .update({'inStock': v});
              },
            ),
          ),
          DataCell(
            Row(
              children: [
                IconButton(
                  tooltip: "Edit",
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: "Delete",
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('products')
                        .doc(d.id)
                        .delete();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 42,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 60,
        columnSpacing: 18,
        columns: const [
          DataColumn(label: Text("Image")),
          DataColumn(label: Text("Product")),
          DataColumn(label: Text("Category")),
          DataColumn(label: Text("Price")),
          DataColumn(label: Text("Stock")),
          DataColumn(label: Text("Availability")),
          DataColumn(label: Text("Actions")),
        ],
        rows: rows,
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const _ProductsList({required this.docs});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return Text(
        "No products found.",
        style: TextStyle(color: Colors.black.withOpacity(0.55)),
      );
    }

    return Column(
      children: docs.take(10).map((d) {
        final data = d.data() as Map<String, dynamic>;
        final name = (data['name'] ?? 'Pearl Bag').toString();
        final price = (data['price'] is num)
            ? (data['price'] as num).toStringAsFixed(0)
            : '0';
        final category = (data['category'] ?? 'Bags').toString();
        final inStock = (data['inStock'] ?? true) == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            color: Colors.black.withOpacity(0.02),
          ),
          child: Row(
            children: [
              _ImgThumb(url: (data['imageUrl'] ?? '').toString()),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "₹$price  •  $category",
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              _StockToggle(
                value: inStock,
                onChanged: (v) {
                  FirebaseFirestore.instance
                      .collection('products')
                      .doc(d.id)
                      .update({'inStock': v});
                },
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => FirebaseFirestore.instance
                    .collection('products')
                    .doc(d.id)
                    .delete(),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ImgThumb extends StatelessWidget {
  final String url;
  const _ImgThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.06),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
        image: url.isEmpty
            ? null
            : DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: url.isEmpty ? const Icon(Icons.image_outlined) : null,
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.05),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StockToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StockToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.black,
      activeTrackColor: Colors.black.withOpacity(0.25),
      inactiveThumbColor: Colors.black.withOpacity(0.55),
      inactiveTrackColor: Colors.black.withOpacity(0.12),
    );
  }
}

/// ======================
/// Simple placeholder page
/// ======================
class _ComingSoonPage extends StatelessWidget {
  final String title;
  const _ComingSoonPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(color: cTextSecondary, fontWeight: FontWeight.w700),
      ),
    );
  }
}
