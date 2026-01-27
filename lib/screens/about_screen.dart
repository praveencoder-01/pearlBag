import 'package:flutter/material.dart';
import '../widgets/site_header.dart';
import '../widgets/site_footer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ✅ KEEP SAME HEADER
          const SiteHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 80,
                    ),
                    color: Colors.grey.shade100,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Story',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Handcrafted Momos. Honest Ingredients. Real Taste.',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CONTENT
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 60,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'How It Started',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Our journey began with a simple idea — to serve authentic, freshly made momos using real ingredients and traditional techniques. What started as a small kitchen experiment soon became a passion for sharing comfort food that feels homemade and honest.',
                          style: TextStyle(fontSize: 16, height: 1.6),
                        ),
                        SizedBox(height: 40),

                        Text(
                          'What We Believe',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'We believe great food doesn’t need shortcuts. No frozen fillings. No artificial flavors. Just carefully sourced vegetables, quality proteins, and recipes refined over time.',
                          style: TextStyle(fontSize: 16, height: 1.6),
                        ),
                        SizedBox(height: 40),

                        Text(
                          'Made Fresh, Served Warm',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Every momo is handcrafted, packed with flavor, and prepared fresh to order. Whether steamed or fried, veg or chicken — each bite reflects our commitment to quality and taste.',
                          style: TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  // ✅ KEEP SAME FOOTER
                  const SiteFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
