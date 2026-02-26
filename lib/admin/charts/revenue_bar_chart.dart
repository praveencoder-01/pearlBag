import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_website/admin/theme/_theme.dart';

class RevenueBarChart extends StatelessWidget {
  final List<double> values; // 6 values
  final List<String> labels; // 6 labels

  const RevenueBarChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
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
              FlLine(color: const Color(0x110B1220), strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AdminTheme.border),
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
              reservedSize: 40,
              interval: top / 4,
              getTitlesWidget: (v, meta) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  v.toStringAsFixed(0),
                  style: TextStyle(
                    color: AdminTheme.textSecondary.withOpacity(0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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
                      color: AdminTheme.textSecondary.withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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
                width: 16,
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [AdminTheme.success, Color(0xFF34D399)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: top,
                  color: const Color(0xFFEFF3FA),
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
