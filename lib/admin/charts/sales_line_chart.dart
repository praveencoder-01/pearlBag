import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_website/admin/theme/_theme.dart';

class SalesLineChart extends StatelessWidget {
  final List<double> values; // 7 values
  final List<String> labels; // 7 labels

  const SalesLineChart({super.key, required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    final maxY = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
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
              interval: 1,
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
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
              (i) => FlSpot(i.toDouble(), values[i].toDouble()),
            ),
            isCurved: true,
            curveSmoothness: 0.18,
            gradient: const LinearGradient(
              colors: [AdminTheme.primary, AdminTheme.primary2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, p, bar, i) => FlDotCirclePainter(
                radius: 3,
                color: AdminTheme.primary2,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AdminTheme.primary.withOpacity(0.18),
                  AdminTheme.primary2.withOpacity(0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
