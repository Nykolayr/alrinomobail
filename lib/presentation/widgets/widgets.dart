import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// фоновый рисунок внизу страниц
class ClippedSvgBackground extends StatelessWidget {
  final bool isTable;

  const ClippedSvgBackground({this.isTable = false, super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double targetWidth = isTable ? screenWidth : screenWidth + 150;

    return ClipRect(
      child: Align(
        alignment: Alignment.center,
        widthFactor: targetWidth / screenWidth,
        child: SvgPicture.asset(
          isTable ? 'assets/svg/fon2.svg' : 'assets/svg/fon.svg',
          width: targetWidth,
        ),
      ),
    );
  }
}
