import 'package:flutter/material.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:food_website/widgets/page_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = <_PolicySection>[
      _PolicySection(
        icon: Icons.info_outline,
        title: "Introduction",
        body:
            "Welcome to Pearl Bags. Your privacy is important to us. This policy explains how we collect, use, and protect your information when you use our app.",
      ),
      _PolicySection(
        icon: Icons.person_outline,
        title: "Information We Collect",
        body:
            "We may collect information such as your name, email, phone number, shipping address, and profile photo when you create an account or place an order.",
      ),
      _PolicySection(
        icon: Icons.analytics_outlined,
        title: "How We Use Your Information",
        body:
            "We use your information to process orders, deliver products, communicate with you, provide support, and improve our services and user experience.",
      ),
      _PolicySection(
        icon: Icons.lock_outline,
        title: "Account & Authentication",
        body:
            "We use secure authentication services to log you in. Your login credentials are protected and are never shared publicly.",
      ),
      _PolicySection(
        icon: Icons.payments_outlined,
        title: "Payments",
        body:
            "We do not store sensitive payment details such as card numbers or UPI PIN. Payments are handled securely by trusted payment providers.",
      ),
      _PolicySection(
        icon: Icons.shield_outlined,
        title: "Data Security",
        body:
            "We take appropriate measures to protect your data from unauthorized access, alteration, disclosure, or destruction.",
      ),
      _PolicySection(
        icon: Icons.share_outlined,
        title: "Sharing of Information",
        body:
            "We do not sell your personal information. We may share limited details with delivery partners only to fulfill your orders.",
      ),
      _PolicySection(
        icon: Icons.manage_accounts_outlined,
        title: "Your Rights",
        body:
            "You can update your details from your account settings. You can also contact us to request account deletion.",
      ),
      _PolicySection(
        icon: Icons.update_outlined,
        title: "Changes to This Policy",
        body:
            "We may update this Privacy Policy from time to time. Any changes will be posted on this page.",
      ),
      _PolicySection(
        icon: Icons.support_agent_outlined,
        title: "Contact Us",
        body:
            "If you have questions about this policy, contact us at:\n\nsupport@pearlbags.com",
      ),
    ];

    return Scaffold(
      appBar: buildPageAppBar(
        context: context,
        title: "Privacy Policy",
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            // ✅ Premium header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.verified_user_outlined, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your privacy matters",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Read how we collect, use and protect your data.",
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ✅ Last updated pill
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  "Last updated: Feb 2026",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ✅ Sections (Accordion Cards)
            ...sections.map((s) => _PolicyCard(section: s)),

            const SizedBox(height: 18),

            // ✅ Footer note card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: const Text(
                "Note: This page is provided for transparency and user trust. "
                "If you are publishing on Play Store, make sure your policies match your actual data collection and usage.",
                style: TextStyle(
                  fontSize: 12.8,
                  height: 1.5,
                  color: Colors.black54,
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

class _PolicyCard extends StatelessWidget {
  final _PolicySection section;
  const _PolicyCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(section.icon, size: 20, color: Colors.black87),
          ),
          title: Text(
            section.title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          collapsedIconColor: Colors.black54,
          iconColor: Colors.black,
          children: [
            Text(
              section.body,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection {
  final IconData icon;
  final String title;
  final String body;
  const _PolicySection({
    required this.icon,
    required this.title,
    required this.body,
  });
}