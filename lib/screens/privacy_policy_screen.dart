import 'package:flutter/material.dart';
import 'package:food_website/widgets/page_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildPageAppBar(
        context: context,
        title: "Privacy Policy",
        onBack: () => Navigator.pop(context),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: _PrivacyContent(),
        ),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          height: 1.55,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [

        sectionTitle("Introduction"),
        paragraph(
            "Welcome to Pearl Bags. Your privacy is important to us. "
            "This Privacy Policy explains how we collect, use, and protect your information "
            "when you use our application."),

        sectionTitle("Information We Collect"),
        paragraph(
            "We may collect personal information such as your name, email address, phone number, "
            "shipping address, and profile photo when you create an account or place an order."),

        sectionTitle("How We Use Your Information"),
        paragraph(
            "We use your information to process orders, deliver products, communicate with you, "
            "provide customer support, and improve our services and user experience."),

        sectionTitle("Account & Authentication"),
        paragraph(
            "We use secure authentication services to log you into the application. "
            "Your login credentials are protected and are never shared publicly."),

        sectionTitle("Payments"),
        paragraph(
            "We do not store your payment details such as card numbers or UPI PIN. "
            "All payments are handled securely by trusted payment providers."),

        sectionTitle("Data Security"),
        paragraph(
            "We take appropriate security measures to protect your personal data from "
            "unauthorized access, alteration, disclosure, or destruction."),

        sectionTitle("Sharing of Information"),
        paragraph(
            "We do not sell, trade, or rent users’ personal identification information "
            "to others. Information may only be shared with delivery partners to fulfill orders."),

        sectionTitle("Your Rights"),
        paragraph(
            "You may update or delete your personal information anytime from your account settings. "
            "You can also contact us to request account deletion."),

        sectionTitle("Changes to This Policy"),
        paragraph(
            "We may update this Privacy Policy from time to time. "
            "Any changes will be posted on this page."),

        sectionTitle("Contact Us"),
        paragraph(
            "If you have any questions regarding this Privacy Policy, "
            "please contact us at: support@pearlbags.com"),

        const SizedBox(height: 30),
      ],
    );
  }
}