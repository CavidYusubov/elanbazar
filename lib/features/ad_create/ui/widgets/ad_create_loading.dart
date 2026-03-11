import 'package:flutter/material.dart';

class AdCreateLoadingView extends StatefulWidget {
  const AdCreateLoadingView({super.key});

  @override
  State<AdCreateLoadingView> createState() => _AdCreateLoadingViewState();
}

class _AdCreateLoadingViewState extends State<AdCreateLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bone({
    required double height,
    double? width,
    double radius = 16,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final color = Color.lerp(
          const Color(0xff171b22),
          const Color(0xff262b35),
          t,
        )!;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  Widget _section() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff111318),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bone(height: 20, width: 140),
          const SizedBox(height: 8),
          _bone(height: 12, width: 220, radius: 10),
          const SizedBox(height: 16),
          _bone(height: 54),
          const SizedBox(height: 12),
          _bone(height: 54),
          const SizedBox(height: 12),
          _bone(height: 54),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        _section(),
        _section(),
        _section(),
      ],
    );
  }
}