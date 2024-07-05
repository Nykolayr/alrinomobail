import 'package:alrino/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// фоновый рисунок внизу страниц для Stack
class FonPicture extends StatelessWidget {
  final bool isTable;

  const FonPicture({this.isTable = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: ClippedSvgBackground(isTable: isTable),
    );
  }
}
