import 'package:flutter/material.dart';

class HoverUnderlineText extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;

  const HoverUnderlineText({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  State<HoverUnderlineText> createState() => _HoverUnderlineTextState();
}

class _HoverUnderlineTextState extends State<HoverUnderlineText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 4),

            // 🔹 Animated underline
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: 2,
              width: _isHovered ? _textWidth(widget.text) : 0,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  // Approximate text width (simple & effective)
  double _textWidth(String text) {
    return text.length * 9.0;
  }
}
