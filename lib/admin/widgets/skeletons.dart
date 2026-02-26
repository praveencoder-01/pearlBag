import 'package:flutter/material.dart';
import 'package:food_website/admin/pages/dashboard_page.dart';
import 'package:food_website/admin/theme/_theme.dart';

/// ----------------------
/// Skeleton loaders
/// ----------------------
class _SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const _SkeletonBox({
    required this.height,
    required this.width,
    this.borderRadius = const BorderRadius.all(AdminTheme.r14),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FA),
          borderRadius: borderRadius,
          border: Border.all(color: AdminTheme.border),
        ),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  final double height;

  const SkeletonList({super.key, required this.count, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 10),
          child: _SkeletonBox(height: height, width: double.infinity),
        );
      }),
    );
  }
}

class SkeletonStatsGrid extends StatelessWidget {
  final int cols;
  const SkeletonStatsGrid({super.key, required this.cols});

  @override
  Widget build(BuildContext context) {
    final rows = (4 / cols).ceil();
    return Column(
      children: List.generate(rows, (r) {
        return Padding(
          padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : 14),
          child: Row(
            children: List.generate(cols, (c) {
              final idx = r * cols + c;
              if (idx >= 4) return const SizedBox.shrink();
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: c == cols - 1 ? 0 : 14),
                  child: const _SkeletonBox(
                    height: 110,
                    width: double.infinity,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class SkeletonCharts extends StatelessWidget {
  final bool isDesktop;
  const SkeletonCharts({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        children: const [
          Expanded(child: _SkeletonBox(height: 260, width: double.infinity)),
          SizedBox(width: 14),
          Expanded(child: _SkeletonBox(height: 260, width: double.infinity)),
          SizedBox(width: 14),
          Expanded(child: _SkeletonBox(height: 260, width: double.infinity)),
        ],
      );
    }
    return Column(
      children: const [
        _SkeletonBox(height: 230, width: double.infinity),
        SizedBox(height: 14),
        _SkeletonBox(height: 230, width: double.infinity),
      ],
    );
  }
}
