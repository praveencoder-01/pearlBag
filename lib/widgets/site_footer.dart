import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [


          Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 70),
            child: Center(
              child: Text(
                "NOT FACTORY PERFECT,\n"
                " PERFECTLY HANDMADE.",
                style: TextStyle(
                  fontSize: 55,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 🔹 SOCIAL ICONS ROW (unchanged)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              FaIcon(FontAwesomeIcons.instagram, size: 18, color: Colors.white),
              SizedBox(width: 28),
              FaIcon(FontAwesomeIcons.xTwitter, size: 18, color: Colors.white),
              SizedBox(width: 28),
              FaIcon(FontAwesomeIcons.facebookF, size: 18, color: Colors.white),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            '© MOMO STORE 2026 · Contact · Terms · Returns',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

