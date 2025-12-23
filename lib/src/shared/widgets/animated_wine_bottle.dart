import 'package:flutter/material.dart';

class AnimatedWineBottleIcon extends StatefulWidget {
  const AnimatedWineBottleIcon({super.key});

  @override
  State<AnimatedWineBottleIcon> createState() => _AnimatedWineBottleIconState();
}

class _AnimatedWineBottleIconState extends State<AnimatedWineBottleIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
        child: const Icon(Icons.wine_bar, size: 50),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
