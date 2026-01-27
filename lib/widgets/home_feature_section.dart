import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeFeatureSection extends StatefulWidget {
  const HomeFeatureSection({super.key});

  @override
  State<HomeFeatureSection> createState() => _HomeFeatureSectionState();
}

class _HomeFeatureSectionState extends State<HomeFeatureSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool hasAnimated = false; // ✅ MUST be here (not in build)

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // ⚡ faster
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return VisibilityDetector(
      key: const Key('home-feature'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.6 && !hasAnimated) {
          hasAnimated = true;

          // slight delay → smoother on web
          Future.delayed(const Duration(milliseconds: 80), () {
            if (mounted) _controller.forward();
          });
        }
      },
      child: IgnorePointer(
        ignoring: _controller.isAnimating, // ✅ smooth scroll
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 80),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _ImagePart(controller: _controller),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      flex: 4,
                      child: _TextPart(controller: _controller),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _ImagePart(controller: _controller),
                    const SizedBox(height: 40),
                    _TextPart(controller: _controller),
                  ],
                ),
        ),
      ),
    );
  }
}

/* ---------------- IMAGE ---------------- */

class _ImagePart extends StatelessWidget {
  final AnimationController controller;
  const _ImagePart({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child:
          Image.asset(
                'assets/images/home/pexels-mamadvali-33045459.jpg',
                cacheWidth: 800,
                height: 650,
                width: double.infinity,
                fit: BoxFit.cover,
              )
              .animate(controller: controller, autoPlay: false)
              .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
              .slideX(begin: -0.15), // smaller distance = faster feel
    );
  }
}

/* ---------------- TEXT ---------------- */

class _TextPart extends StatelessWidget {
  final AnimationController controller;
  const _TextPart({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.of(context).size.width > 1100;

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CRAFTED FOR EVERYDAY ELEGANCE',
              style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Text(
              'Designed to Carry\nYour Story',
              style: TextStyle(
                fontSize: isLarge ? 70 : 42,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Our pearl bags are designed for women who love subtle luxury. '
              'Each piece is carefully handcrafted with delicate pearls that add '
              'charm, grace, and a timeless glow.',
              style: TextStyle(fontSize: 18, height: 1.8),
            ),
          ],
        )
        .animate(controller: controller, autoPlay: false)
        .fadeIn(duration: 700.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.2);
  }
}





    // ----------------SECOND IMAGE AND TEXT-----------------!


class HomeFeatureSectionReverse extends StatefulWidget {
  const HomeFeatureSectionReverse({super.key});

  @override
  State<HomeFeatureSectionReverse> createState() =>
      _HomeFeatureSectionReverseState();
}

class _HomeFeatureSectionReverseState
    extends State<HomeFeatureSectionReverse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return VisibilityDetector(
      key: const Key('home-feature-reverse'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.6 && !hasAnimated) {
          hasAnimated = true;
          _controller.forward();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 80),
        child: isDesktop
            ? Row(
                children: [
                  Expanded(flex: 4, child: _ReverseText(controller: _controller)),
                  const SizedBox(width: 60),
                  Expanded(flex: 5, child: _ReverseImage(controller: _controller)),
                ],
              )
            : Column(
                children: [
                  _ReverseImage(controller: _controller),
                  const SizedBox(height: 40),
                  _ReverseText(controller: _controller),
                ],
              ),
      ),
    );
  }
}



/* ---------------- IMAGE ---------------- */

class _ReverseImage extends StatelessWidget {
  final AnimationController controller;
  const _ReverseImage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        'assets/images/home/pexels-maria-mileta-3563033-5357486.jpg',
        height: 650,
        width: double.infinity,
        fit: BoxFit.cover,
      )
          .animate(controller: controller, autoPlay: false)
          .fadeIn(duration: 800.ms)
          .slideX(begin: 0.3), // 👈 RIGHT → LEFT
    );
  }
}




/* ---------------- TEXT ---------------- */

class _ReverseText extends StatelessWidget {
  final AnimationController controller;
  const _ReverseText({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.of(context).size.width > 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIMELESS & HANDCRAFTED',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600),
        ),  
        const SizedBox(height: 20),
        Text(
          'Where Style\nMeets Tradition',
          style: TextStyle(
            fontSize: isLarge ? 70 : 42,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Pearls are not made in a moment. They are formed slowly, layer by layer, through time and patience. What begins as something ordinary becomes something beautiful. This is why pearls are special — they remind us that real beauty grows quietly and becomes stronger with time.',
          style: TextStyle(fontSize: 18, height: 1.8),
        ),
      ],
    )
        .animate(controller: controller, autoPlay: false)
        .fadeIn(duration: 1200.ms)
        .slideY(begin: 0.25);
  }
}
