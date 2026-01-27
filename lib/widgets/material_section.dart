import 'package:flutter/material.dart';

class ProductMaterialSection extends StatelessWidget {
  const ProductMaterialSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, bottom: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          // TOP SMALL TITLE
          Text(
            'THE MATERIAL',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: 18),

          // MAIN TITLE
          Text(
            'Timeless designs, well-made, resourceful and sustainable.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.6,
            ),
          ),

          SizedBox(height: 24),

          // DESCRIPTION
          SizedBox(
            width: 1050,
            child: Text(
              'Born deep within the ocean, pearls take time to become what they are meant to be. Each one is unique, shaped by nature and patience. This slow journey makes every pearl meaningful, beautiful, and full of emotion.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.7, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
