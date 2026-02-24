import 'package:flutter/material.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:food_website/widgets/page_appbar.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildPageAppBar(
        context: context,
        title: "About Us",
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            _HeroCard(),

            const SizedBox(height: 14),

            _SectionTitle("Who we are"),
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.storefront_outlined,
              title: "Pearl Bags",
              body:
                  "We create premium bags that look minimal, feel premium, and stay durable for daily use. Each piece is designed with clean aesthetics and quality material.",
            ),

            const SizedBox(height: 14),

            _SectionTitle("What we believe"),
            const SizedBox(height: 10),
            Row(
              children: const [
                Expanded(
                  child: _MiniValueCard(
                    icon: Icons.verified_outlined,
                    title: "Quality First",
                    body: "Carefully picked material & finishing.",
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MiniValueCard(
                    icon: Icons.local_shipping_outlined,
                    title: "Fast Shipping",
                    body: "Quick dispatch & smooth delivery.",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _MiniValueCard(
                    icon: Icons.lock_outline,
                    title: "Secure Payment",
                    body: "Safe checkout & trusted payments.",
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MiniValueCard(
                    icon: Icons.assignment_return_outlined,
                    title: "Easy Returns",
                    body: "Hassle-free return support.",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _SectionTitle("Our promise"),
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.favorite_border,
              title: "Made to be loved",
              body:
                  "From packaging to product quality, we focus on a premium experience. If something feels off, we are here to help quickly.",
            ),

            const SizedBox(height: 18),

            _SectionTitle("Quick stats"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: _StatItem(
                      value: "100+",
                      label: "Designs",
                      icon: Icons.style_outlined,
                    ),
                  ),
                  _VLine(),
                  Expanded(
                    child: _StatItem(
                      value: "4.8★",
                      label: "Avg Rating",
                      icon: Icons.star_outline,
                    ),
                  ),
                  _VLine(),
                  Expanded(
                    child: _StatItem(
                      value: "24/7",
                      label: "Support",
                      icon: Icons.support_agent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _SectionTitle("Contact"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.mail_outline,
                    label: "Email us",
                    onTap: () {
                      // TODO: launch mailto: with url_launcher if you want
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email us clicked")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.phone_outlined,
                    label: "Call us",
                    onTap: () {
                      // TODO: launch tel:
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Call us clicked")),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Center(
              child: Text(
                "Thank you for choosing Pearl Bags 🤍",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- UI Widgets ----------

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Pearl Bags",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  "Premium bags • Minimal design • Everyday comfort",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _MiniValueCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.25,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VLine extends StatelessWidget {
  const _VLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.black12,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}