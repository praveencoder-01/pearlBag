import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeatureIconsRow extends StatelessWidget {
  const FeatureIconsRow({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 FEATURE ICONS ROW
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 40,
        runSpacing: 20,
        children: const [
          _FooterFeature(
            icon: FontAwesomeIcons.handshake,
            title: 'Independent Brand',
            description:
                'We are an independent brand creating thoughtfully handmade purses with care, creativity, and attention to every detail.',
          ),
          _FooterFeature(
            icon: FontAwesomeIcons.lock,
            title: 'Secure Payment',
            description:
                'All payments on our website are fully secure and protected, so you can shop with confidence and peace of mind.',
          ),
          _FooterFeature(
            icon: FontAwesomeIcons.phone,
            title: 'Get In Touch',
            description:
                'Have a question or need help? Our team is always happy to assist you. Feel free to get in touch anytime.',
          ),
          _FooterFeature(
            icon: FontAwesomeIcons.rotateLeft,
            title: 'Easy Returns',
            description:
                'Not satisfied with your purchase? We offer an easy and hassle-free return process for your convenience.',
          ),
        ],
      ),
    );
  }
}

class _FooterFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FooterFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220, // keeps all columns aligned
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 25, color: Colors.black),
          const SizedBox(height: 10),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 2,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
