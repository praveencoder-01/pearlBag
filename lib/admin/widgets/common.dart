import 'package:flutter/material.dart';
import 'package:food_website/admin/theme/_theme.dart';

class Panel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const Panel({super.key, required this.title, required this.child, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AdminTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AdminTheme.h2),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!, style: AdminTheme.meta),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? right;

  const SectionHeader({super.key, 
    required this.title,
    required this.subtitle,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AdminTheme.h1),
              const SizedBox(height: 6),
              Text(subtitle, style: AdminTheme.meta),
            ],
          ),
        ),
        if (right != null) ...[const SizedBox(width: 12), right!],
      ],
    );
  
}}

class Hoverable extends StatefulWidget {
  final Widget Function(bool hovered) builder;
  final double borderRadius;

  const Hoverable({super.key, required this.builder, required this.borderRadius});

  @override
  State<Hoverable> createState() => HoverableState();
}

class HoverableState extends State<Hoverable> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.builder(_hovered),
    );
  }
}