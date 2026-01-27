import 'package:flutter/material.dart';
import 'package:food_website/models/product.dart';

class ProductInfoImageSection extends StatelessWidget {
  final ProductInfoSectionData data;

  const ProductInfoImageSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 85),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT TEXT
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  data.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 80),

          // RIGHT IMAGE
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.asset(
                data.image,
                fit: BoxFit.cover,
                // height: 340,
                // width: 400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
