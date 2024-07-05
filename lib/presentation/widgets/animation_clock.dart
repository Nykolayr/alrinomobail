import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedClock extends AnimatedWidget {
  const AnimatedClock({
    super.key,
    required AnimationController controller,
  }) : super(listenable: controller);

  Animation<double> get progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      SvgPicture.asset(
        'assets/svg/clock.svg',
        height: 35,
      ),
      Positioned(
        top: 6,
        child: Transform.rotate(
          angle: progress.value * 2.0 * math.pi,
          child: SvgPicture.asset(
            'assets/svg/clock_arrow.svg',
            height: 27,
          ),
        ),
      ),
    ]);
  }
}
