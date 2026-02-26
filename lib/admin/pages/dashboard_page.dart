import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_website/admin/admin_shell.dart';
import 'package:food_website/admin/charts/order_analytics.dart';
import 'package:food_website/admin/charts/order_status_donut_chart.dart';
import 'package:food_website/admin/charts/revenue_bar_chart.dart';
import 'package:food_website/admin/charts/sales_line_chart.dart';
import 'package:food_website/admin/theme/_theme.dart';
import 'package:food_website/admin/widgets/common.dart';
import 'package:food_website/admin/widgets/empty_state.dart';
import 'package:food_website/admin/widgets/skeletons.dart';

class PearlDashboardPage extends StatefulWidget {
  const PearlDashboardPage({super.key});

  @override
  State<PearlDashboardPage> createState() => _PearlDashboardPageState();
}

class _PearlDashboardPageState extends State<PearlDashboardPage> {
  int _rangeIndex = 0; // 0=7d, 1=30d, 2=90d (UI tabs)

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
                final isLoading =
                    productSnap.connectionState == ConnectionState.waiting ||
                    orderSnap.connectionState == ConnectionState.waiting ||
                    userSnap.connectionState == ConnectionState.waiting;

                final productDocs = productSnap.data?.docs ?? const [];
                final orderDocs = orderSnap.data?.docs ?? const [];
                final userDocs = userSnap.data?.docs ?? const [];

                final productCount = productDocs.length;
                final orderCount = orderDocs.length;
                final userCount = userDocs.length;

                final totalSales = _sum(orderDocs, key: 'totalAmount');
                final monthlyRevenue = totalSales; // placeholder (kept)

                // “delta” indicators (simple heuristic; replace with real comparisons later)
                final stats = <StatModel>[
                  StatModel(
                    title: "Total sales",
                    value: "₹${totalSales.toStringAsFixed(0)}",
                    icon: Icons.payments_outlined,
                    accentA: AdminTheme.primary,
                    accentB: AdminTheme.primary2,
                    deltaPct: _safeDelta(totalSales, denomFallback: 50000),
                  ),
                  StatModel(
                    title: "Orders",
                    value: "$orderCount",
                    icon: Icons.receipt_long_outlined,
                    accentA: AdminTheme.success,
                    accentB: const Color(0xFF34D399),
                    deltaPct: _safeDelta(
                      orderCount.toDouble(),
                      denomFallback: 120,
                    ),
                  ),
                  StatModel(
                    title: "Customers",
                    value: "$userCount",
                    icon: Icons.people_outline,
                    accentA: const Color(0xFF0EA5E9),
                    accentB: const Color(0xFF2563EB),
                    deltaPct: _safeDelta(
                      userCount.toDouble(),
                      denomFallback: 80,
                    ),
                  ),
                  StatModel(
                    title: "Revenue (monthly)",
                    value: "₹${monthlyRevenue.toStringAsFixed(0)}",
                    icon: Icons.trending_up_rounded,
                    accentA: AdminTheme.warning,
                    accentB: const Color(0xFFF97316),
                    deltaPct: _safeDelta(monthlyRevenue, denomFallback: 45000),
                  ),
                ];

                final analytics = OrderAnalytics.fromOrders(orderDocs);

                return LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final isMobile = Breakpoints.isMobile(w);
                    final isTablet = Breakpoints.isTablet(w);
                    final isDesktop = Breakpoints.isDesktop(w);

                    // Stats grid columns by breakpoint
                    final statsCols = isMobile ? 1 : (isTablet ? 2 : 4);

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: "Overview",
                            subtitle:
                                "Sales performance and store health at a glance.",
                            right: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SegmentedTabs(
                                  items: const ["7d", "30d", "90d"],
                                  selectedIndex: _rangeIndex,
                                  onChanged: (i) =>
                                      setState(() => _rangeIndex = i),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        // Stats cards
                        if (isLoading)
                          SliverToBoxAdapter(
                            child: SkeletonStatsGrid(cols: statsCols),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.zero,
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: statsCols,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: isMobile ? 2.05 : 2.35,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => StatCardV2(model: stats[i]),
                                childCount: stats.length,
                              ),
                            ),
                          ),

                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: "Analytics",
                            subtitle:
                                "Trends, revenue and order status distribution.",
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        // Charts
                        if (isLoading)
                          SliverToBoxAdapter(
                            child: SkeletonCharts(isDesktop: isDesktop),
                          )
                        else
                          SliverToBoxAdapter(
                            child: LayoutBuilder(
                              builder: (context, cc) {
                                final wide = cc.maxWidth >= 1100;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: wide ? 2 : 1,
                                      child: Column(
                                        children: [
                                          Panel(
                                            title: "Sales (last 7 days)",
                                            subtitle: "Daily revenue signals",
                                            child: SizedBox(
                                              height: wide ? 260 : 230,
                                              child: SalesLineChart(
                                                values:
                                                    analytics.last7DaysRevenue,
                                                labels:
                                                    analytics.last7DaysLabels,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Panel(
                                            title: "Revenue (last 6 months)",
                                            subtitle: "Monthly totals",
                                            child: SizedBox(
                                              height: wide ? 260 : 230,
                                              child: RevenueBarChart(
                                                values: analytics
                                                    .last6MonthsRevenue,
                                                labels:
                                                    analytics.last6MonthsLabels,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (wide) ...[
                                      const SizedBox(width: 14),
                                      Expanded(
                                        flex: 1,
                                        child: Panel(
                                          title: "Order status",
                                          subtitle: "Distribution snapshot",
                                          child: SizedBox(
                                            height: 534,
                                            child: OrderStatusDonutChart(
                                              statusCounts:
                                                  analytics.statusCounts,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),

                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // Orders + Top products + Reviews
                        SliverToBoxAdapter(
                          child: LayoutBuilder(
                            builder: (context, cc) {
                              final w2 = cc.maxWidth;
                              final isMobile2 = Breakpoints.isMobile(w2);
                              final isWide = w2 >= 980;

                              if (isMobile2) {
                                return Column(
                                  children: [
                                    Panel(
                                      title: "Recent orders",
                                      subtitle: "Latest activity",
                                      child: orderDocs.isEmpty && !isLoading
                                          ? const EmptyState(
                                              icon: Icons.receipt_long_outlined,
                                              title: "No orders yet",
                                              subtitle:
                                                  "Once customers place orders, they will appear here.",
                                            )
                                          : OrdersList(orderDocs),
                                    ),
                                    const SizedBox(height: 14),
                                    Panel(
                                      title: "Top products",
                                      subtitle:
                                          "Demo list (replace with query later)",
                                      child: TopProducts(
                                        productCount: productCount,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Panel(
                                      title: "Recent reviews",
                                      subtitle: "Customer feedback",
                                      child: ReviewsList(),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Panel(
                                      title: "Recent orders",
                                      subtitle: "Latest activity",
                                      child: orderDocs.isEmpty && !isLoading
                                          ? const EmptyState(
                                              icon: Icons.receipt_long_outlined,
                                              title: "No orders yet",
                                              subtitle:
                                                  "Once customers place orders, they will appear here.",
                                            )
                                          : (isWide
                                                ? OrdersTable(orderDocs)
                                                : OrdersList(orderDocs)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Panel(
                                          title: "Top products",
                                          subtitle:
                                              "Demo list (replace with query later)",
                                          child: TopProducts(
                                            productCount: productCount,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        const Panel(
                                          title: "Recent reviews",
                                          subtitle: "Customer feedback",
                                          child: ReviewsList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
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

  static double _safeDelta(double v, {required double denomFallback}) {
    final denom = v.abs() < 1 ? denomFallback : v.abs();
    final pct = (v / denom) * 100;
    // Keep it in a friendly range for UI demo:
    return pct.clamp(-25, 25).toDouble();
  }

  static double _sum(List<QueryDocumentSnapshot> docs, {required String key}) {
    double s = 0;
    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final v = data[key];
      if (v is num) s += v.toDouble();
    }
    return s;
  }
}


/// =======================================================
/// Top Products + Reviews (kept demo, improved UI)
/// =======================================================
class TopProducts extends StatelessWidget {
  final int productCount;
  const TopProducts({super.key, required this.productCount});

  @override
  Widget build(BuildContext context) {
    // Demo UI as requested (replace with real top-selling query later).
    final items = [
      ("Pearl Mini Bag", 2499, 12, 0.72),
      ("Classic Tote", 3299, 8, 0.55),
      ("Pearl Sling", 1899, 20, 0.86),
    ];

    return Column(
      children: List.generate(items.length, (i) {
        final it = items[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 10),
          child: Hoverable(
            borderRadius: 16,
            builder: (hovered) => AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hovered ? const Color(0xFFF7F9FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AdminTheme.primary.withOpacity(0.16),
                          AdminTheme.primary2.withOpacity(0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: AdminTheme.border),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AdminTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.$1,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${it.$2}  •  Stock ${it.$3}",
                          style: AdminTheme.meta,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: it.$4,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFEFF3FA),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AdminTheme.success.withOpacity(0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AdminTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ReviewsList extends StatelessWidget {
  const ReviewsList({super.key});

  @override
  Widget build(BuildContext context) {
    Widget review(String name, String msg, int stars) {
      final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : "?";
      return Hoverable(
        borderRadius: 16,
        builder: (hovered) => AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hovered ? const Color(0xFFF7F9FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminTheme.border),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AdminTheme.primary.withOpacity(0.20),
                      AdminTheme.primary2.withOpacity(0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AdminTheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTheme.meta,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        final filled = i < stars;
                        return Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 16,
                          color: filled
                              ? AdminTheme.warning
                              : AdminTheme.textTertiary.withOpacity(0.55),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        review("Aanya", "Packaging is premium. Bag looks expensive.", 5),
        const SizedBox(height: 10),
        review("Rohit", "Quality is good. Delivery was fast.", 4),
      ],
    );
  }
}


/// ----------------------
/// Stats Card (premium)
/// ----------------------
class StatModel {
  final String title;
  final String value;
  final IconData icon;
  final Color accentA;
  final Color accentB;
  final double deltaPct;

  StatModel({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentA,
    required this.accentB,
    required this.deltaPct,
  });
}

class StatCardV2 extends StatelessWidget {
  final StatModel model;

  const StatCardV2({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final up = model.deltaPct >= 0;
    final deltaColor = up ? AdminTheme.success : AdminTheme.danger;
    final deltaIcon = up
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Hoverable(
      borderRadius: 16,
      builder: (hovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminTheme.border),
            boxShadow: hovered
                ? const [
                    BoxShadow(
                      color: Color(0x1A0B1220),
                      blurRadius: 26,
                      offset: Offset(0, 14),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x120B1220),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
            gradient: LinearGradient(
              colors: [
                Colors.white,
                hovered ? const Color(0xFFF8FAFF) : const Color(0xFFFBFCFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Soft accent glow
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          model.accentA.withOpacity(0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: -50,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          model.accentB.withOpacity(0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _AccentIcon(
                            icon: model.icon,
                            a: model.accentA,
                            b: model.accentB,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              model.title,
                              style: TextStyle(
                                color: AdminTheme.textSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          model.value,
                          style: const TextStyle(
                            color: AdminTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: deltaColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: deltaColor.withOpacity(0.22),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(deltaIcon, size: 16, color: deltaColor),
                                const SizedBox(width: 4),
                                Text(
                                  "${model.deltaPct.abs().toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    color: deltaColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "vs. previous",
                            style: TextStyle(
                              color: AdminTheme.textTertiary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccentIcon extends StatelessWidget {
  final IconData icon;
  final Color a;
  final Color b;

  const _AccentIcon({required this.icon, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [a, b],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220B1220),
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

/// ----------------------
/// Segmented Tabs (7d/30d/90d)
/// ----------------------
class SegmentedTabs extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (i) {
          final active = i == selectedIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AdminTheme.primary.withOpacity(0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active
                      ? AdminTheme.primary.withOpacity(0.20)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                items[i],
                style: TextStyle(
                  color: active ? AdminTheme.primary : AdminTheme.textSecondary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final v = _c.value;
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1.0 - 0.3 + v * 2.0, 0),
              end: Alignment(-0.2 + v * 2.0, 0),
              colors: const [
                Color(0xFFEDF2FA),
                Color(0xFFFFFFFF),
                Color(0xFFEDF2FA),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class CellText extends StatelessWidget {
  final String text;
  final int flex;
  final bool strong;
  final bool alignEnd;

  const CellText(
    this.text, {
    required this.flex,
    this.strong = false,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: strong ? AdminTheme.textPrimary : AdminTheme.textSecondary,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// ----------------------
/// Status chips (payment + order)
/// ----------------------
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip._(this.label, this.color);

  static StatusChip payment(String text) {
    final t = text.toLowerCase();
    if (t.contains('fail') || t.contains('unpaid'))
      return const StatusChip._("Unpaid", AdminTheme.danger);
    if (t.contains('pend'))
      return const StatusChip._("Pending", AdminTheme.warning);
    return const StatusChip._("Paid", AdminTheme.success);
  }

  static StatusChip order(String text) {
    final t = text.toLowerCase();
    if (t.contains('deliver')) {
      return const StatusChip._("Delivered", AdminTheme.success);
    }
    if (t.contains('cancel')) {
      return const StatusChip._("Cancelled", AdminTheme.danger);
    }
    if (t.contains('ship')) {
      return const StatusChip._("Shipped", AdminTheme.primary2);
    }
    if (t.contains('process')) {
      return const StatusChip._("Processing", AdminTheme.warning);
    }
    return const StatusChip._("Pending", AdminTheme.textSecondary);
  }

  @override
  Widget build(BuildContext context) {
    final bg = color == AdminTheme.textSecondary
        ? const Color(0xFFF7F9FF)
        : color.withOpacity(0.12);
    final br = color == AdminTheme.textSecondary
        ? AdminTheme.border
        : color.withOpacity(0.22);
    final fg = color == AdminTheme.textSecondary
        ? AdminTheme.textSecondary
        : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: br),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}

/// =======================================================
/// Orders UI (hover rows + status chips)
/// =======================================================
class OrdersTable extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const OrdersTable(this.docs, {super.key});

  @override
  Widget build(BuildContext context) {
    final items = docs.take(6).toList();
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: "No recent orders",
        subtitle: "Orders will appear here once customers start buying.",
      );
    }

    // Use a table-like layout with hover rows. Horizontal scroll ONLY if needed.
    const minTableWidth = 860.0;

    return LayoutBuilder(
      builder: (context, c) {
        final needsScroll = c.maxWidth < minTableWidth;

        final table = Column(
          children: [
            TableHeaderRow(
              columns: const [
                "Order",
                "Customer",
                "Product",
                "Date",
                "Payment",
                "Status",
                "Total",
              ],
              flex: const [12, 18, 18, 14, 12, 12, 10],
            ),
            const SizedBox(height: 8),
            ...items.map((d) {
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Hoverable(
                  borderRadius: 14,
                  builder: (hovered) => AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: hovered ? const Color(0xFFF7F9FF) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AdminTheme.border),
                    ),
                    child: Row(
                      children: [
                        CellText(
                          "#${id.substring(0, math.min(8, id.length))}",
                          flex: 12,
                          strong: true,
                        ),
                        CellText(customer, flex: 18),
                        CellText(product, flex: 18),
                        CellText(date, flex: 14),
                        Expanded(
                          flex: 12,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: StatusChip.payment(payment),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: StatusChip.order(status),
                          ),
                        ),
                        CellText(
                          "₹$price",
                          flex: 10,
                          alignEnd: true,
                          strong: true,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );

        if (!needsScroll) return table;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: minTableWidth),
            child: table,
          ),
        );
      },
    );
  }
}

class OrdersList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const OrdersList(this.docs, {super.key});

  @override
  Widget build(BuildContext context) {
    final items = docs.take(6).toList();
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: "No recent orders",
        subtitle: "Orders will appear here once customers start buying.",
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Hoverable(
            borderRadius: 16,
            builder: (hovered) => AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hovered ? const Color(0xFFF7F9FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AdminTheme.primary.withOpacity(0.08),
                      border: Border.all(
                        color: AdminTheme.primary.withOpacity(0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: AdminTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#${id.substring(0, math.min(8, id.length))}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(customer, style: AdminTheme.meta),
                      ],
                    ),
                  ),
                  StatusChip.order(status),
                  const SizedBox(width: 10),
                  Text(
                    "₹$price",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
