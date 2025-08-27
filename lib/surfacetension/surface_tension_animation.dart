import 'dart:math';
import 'dart:ui';

import 'package:first_flutter_app/surfacetension/water_surface_tension_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bug_painter.dart';

class SurfaceTensionAnimation extends StatefulWidget {
  final Size _size;

  const SurfaceTensionAnimation(this._size, {super.key});

  @override
  State<StatefulWidget> createState() => SurfaceTensionAnimationState(_size);
}

class SurfaceTensionAnimationState
    extends State<SurfaceTensionAnimation> with SingleTickerProviderStateMixin {

  late Size areaSize;
  late AnimationController _controller;
  late Animation<double> _animation;
  late double animationStep = 1.0;
  Offset touchPosition = Offset(150, 300);

  SurfaceTensionAnimationState(Size size): areaSize = size, touchPosition = Offset(size.width / 2, 0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {
          animationStep = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          touchPosition = details.localPosition;
        });
      },
      child: CustomPaint(
        painter: WaterSurfaceTensionPainter(animationStep, touchPosition)),
      );
  }

  Widget buildReflection(Widget child) {
    return Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.rotationX(pi),
      child: Opacity(
        opacity: 0.3,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: child,
        ),
      ),
    );
  }
}