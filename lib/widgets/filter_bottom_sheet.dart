import 'package:flutter/material.dart';
import 'package:food_website/theme/app_colors.dart';

class FilterResult {
  final String category;
  final RangeValues price;
  final String sort;
  final int rating;

  FilterResult({
    required this.category,
    required this.price,
    required this.sort,
    required this.rating,
  });
}

class FilterBottomSheet extends StatefulWidget {
  final String initialCategory;
  final RangeValues initialPrice;
  final String initialSort;
  final int initialRating;

  const FilterBottomSheet({
    super.key,
    required this.initialCategory,
    required this.initialPrice,
    required this.initialSort,
    required this.initialRating,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final List<String> _categories = [
    "All",
    "Handbags",
    "Clutch Bags",
    "Mini Bags",
    "Dresses",
    "Jackets",
    "Jeans",
    "Shoese",
    "Tops",
    "Sneakers",
  ];

  String _selectedCategory = "All";
  RangeValues _price = const RangeValues(0, 750);
  final List<String> _sorts = ["New Today", "New This Week", "Top Sellers"];
  String _selectedSort = "New Today";
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _price = widget.initialPrice;
    _selectedSort = widget.initialSort;
    _selectedRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final border = Colors.black.withOpacity(.18);

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
 color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row (Back only)
              Row(
                children: [
                  _circleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 18),
              _title("Categories"),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((c) {
                  final selected = c == _selectedCategory;
                  return _chip(
                    text: c,
                    selected: selected,
                    border: border,
                    onTap: () => setState(() => _selectedCategory = c),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),
              _title("Price Range"),
              const SizedBox(height: 10),

              Stack(
                children: [
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _MiniGraphPainter(
                        color: Colors.black.withOpacity(.10),
                      ),
                    ),
                  ),
                  RangeSlider(
                    min: 0,
                    max: 1750,
                    values: _price,
                    activeColor: Colors.black,
                    inactiveColor: Colors.black.withOpacity(.18),
                    onChanged: (v) => setState(() => _price = v),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$0",
                      style: TextStyle(color: Colors.black.withOpacity(.35)),
                    ),
                    Text(
                      "\$${_price.end.round()}",
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      "\$1750",
                      style: TextStyle(color: Colors.black.withOpacity(.35)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _title("Sort by"),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _sorts.map((s) {
                  final selected = s == _selectedSort;
                  return _chip(
                    text: s,
                    selected: selected,
                    border: border,
                    onTap: () => setState(() => _selectedSort = s),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              _title("Ratting"),
              const SizedBox(height: 10),

              _ratingRow(5),
              const SizedBox(height: 10),
              _ratingRow(4),
              const SizedBox(height: 10),
              _ratingRow(3),
              const SizedBox(height: 10),
              _ratingRow(2),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      FilterResult(
                        category: _selectedCategory,
                        price: _price,
                        sort: _selectedSort,
                        rating: _selectedRating,
                      ),
                    );
                  },
                  child: const Text(
                    "Apply Now",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI helpers
  Widget _title(String t) => Text(
    t,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
  );

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _chip({
    required String text,
    required bool selected,
    required Color border,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? Colors.black : border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _ratingRow(int starsCount) {
    final selected = _selectedRating == starsCount;
    return Row(
      children: [
        Row(
          children: List.generate(
            starsCount,
            (_) => const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(Icons.star, color: Color(0xFFF5A623), size: 18),
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () => setState(() => _selectedRating = starsCount),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.black : Colors.black.withOpacity(.22),
                width: 2,
              ),
            ),
            child: selected
                ? const Center(
                    child: Icon(Icons.check, size: 12, color: Colors.black),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _MiniGraphPainter extends CustomPainter {
  final Color color;
  _MiniGraphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * .05, size.height * .75);
    path.lineTo(size.width * .12, size.height * .85);
    path.lineTo(size.width * .22, size.height * .55);
    path.lineTo(size.width * .32, size.height * .80);
    path.lineTo(size.width * .42, size.height * .45);
    path.lineTo(size.width * .55, size.height * .75);
    path.lineTo(size.width * .68, size.height * .52);
    path.lineTo(size.width * .78, size.height * .82);
    path.lineTo(size.width * .90, size.height * .60);
    path.lineTo(size.width, size.height * .72);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
