import 'package:flutter/material.dart';

class AnimatedWineBottleIcon extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _AnimatedWineBottleIconState createState() => _AnimatedWineBottleIconState();
}

class _AnimatedWineBottleIconState extends State<AnimatedWineBottleIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Adjust the duration as needed
    )..repeat(); // Repeat the animation
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