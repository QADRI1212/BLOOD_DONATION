import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }
}

class AnimatedDoubleCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final int decimals;
  final Duration duration;

  const AnimatedDoubleCounter({
    super.key,
    required this.value,
    this.style,
    this.decimals = 1,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          value.toStringAsFixed(decimals),
          style: style,
        );
      },
    );
  }
}
