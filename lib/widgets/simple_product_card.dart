import 'package:flutter/material.dart';

import '../models/product.dart';

class SimpleProductCard extends StatelessWidget {
  final Product product;

  const SimpleProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: Image.asset(product.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),

            const SizedBox(height: 4),

            Text(
              '₹ ${product.price.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
