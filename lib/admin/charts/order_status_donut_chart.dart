import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_website/admin/theme/_theme.dart';
import 'package:food_website/admin/widgets/empty_state.dart';

class OrderStatusDonutChart extends StatelessWidget {
  final Map<String, int> statusCounts;
  const OrderStatusDonutChart({super.key, required this.statusCounts});

  @override
  Widget build(BuildContext context) {
    final total = statusCounts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return const EmptyState(
        icon: Icons.pie_chart_outline_rounded,
        title: "No chart data",
        subtitle: "Once orders are placed, status distribution will show here.",
      );
    }

    final keys = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
    final colors = <String, Color>{
      'Pending': AdminTheme.textSecondary,
      'Processing': AdminTheme.warning,
      'Shipped': AdminTheme.primary2,
      'Delivered': AdminTheme.success,
      'Cancelled': AdminTheme.danger,
    };

    final sections = <PieChartSectionData>[];
    for (final k in keys) {
      final v = statusCounts[k] ?? 0;
      if (v == 0) continue;
      sections.add(
        PieChartSectionData(
          value: v.toDouble(),
          color: colors[k]!.withOpacity(0.9),
          radius: 34,
          title: "",
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 380;
        return Column(
          children: [
            SizedBox(
              height: narrow ? 180 : 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: narrow ? 52 : 60,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                    ),
                    duration: const Duration(milliseconds: 250),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          color: AdminTheme.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$total",
                        style: const TextStyle(
                          color: AdminTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: keys.map((k) {
                  final v = statusCounts[k] ?? 0;
                  if (v == 0) return const SizedBox.shrink();
                  final pct = (v / total * 100).toStringAsFixed(0);
                  final col = colors[k]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: col.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              k,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            "$v ($pct%)",
                            style: TextStyle(
                              color: AdminTheme.textSecondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
