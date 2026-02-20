import 'package:flutter/material.dart';

class CategoryBlobCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final Color background;

  const CategoryBlobCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      height: 450,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 🎨 Organic background shape
          Container(
            height: 460,
            width: 460,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(50),
            ),
          ),

          // 🖼 Image
          ClipRRect(
            borderRadius: BorderRadius.circular(140),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 300,
              height: 300,
            ),
          ),

          // 🏷 Text overlay
          Positioned(
            bottom: 30,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 28,

                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
