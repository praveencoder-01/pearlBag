import 'package:flutter/material.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:food_website/widgets/page_appbar.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _q = "";

  final List<_FaqItem> _faqs = const [
    _FaqItem(
      "How do I place an order?",
      "Open any product, choose quantity (if available), tap Add to Cart, then go to Cart and press Proceed to Checkout.",
    ),
    _FaqItem(
      "Can I cancel my order?",
      "If the order is not shipped yet, you can cancel it from 'My Orders'. If it’s already shipped, you can request a return after delivery.",
    ),
    _FaqItem(
      "Do you support Cash on Delivery (COD)?",
      "Yes, COD is available in selected locations. You will see COD option at checkout if it’s available for your pincode.",
    ),
    _FaqItem(
      "How long does delivery take?",
      "Usually 2–7 working days depending on your city/pincode. Remote areas may take a bit longer.",
    ),
    _FaqItem(
      "What is your return policy?",
      "You can request a return within 7 days of delivery for eligible products. Item must be unused and in original packaging.",
    ),
    _FaqItem(
      "How do I track my order?",
      "Go to 'My Orders' and open the order. You will see tracking details once the order is shipped.",
    ),
    _FaqItem(
      "Do you offer replacement?",
      "If you receive a damaged/incorrect item, we can replace it based on stock availability. Otherwise we will refund.",
    ),
    _FaqItem(
      "Are product images real?",
      "We try to show accurate images. Minor color difference can happen due to lighting and screen settings.",
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _q.isEmpty
        ? _faqs
        : _faqs.where((f) {
            final t = (f.question + " " + f.answer).toLowerCase();
            return t.contains(_q);
          }).toList();

    return Scaffold(
      appBar: buildPageAppBar(
        context: context,
        onBack: () => Navigator.pop(context),

        // ✅ Search field in title place
        titleWidget: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black38, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _q = v.toLowerCase().trim()),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search FAQs...",
                    isDense: true,
                  ),
                ),
              ),
              if (_q.isNotEmpty)
                InkWell(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _q = "");
                  },
                  child: const Icon(Icons.close, size: 18, color: Colors.black38),
                ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          children: [
            const Text(
              "FAQs",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Center(child: Text("No FAQs found")),
              )
            else
              ...filtered.map((f) => _FaqTile(item: f)),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Text(
            item.question,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Text(
              item.answer,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
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

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}