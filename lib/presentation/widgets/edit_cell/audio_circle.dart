import 'package:alrino/presentation/theme/theme.dart';
import 'package:flutter/material.dart';

/// Виджет с анимацией мигания, на входе любой виджет
class BlinkingWidget extends StatefulWidget {
  final Widget child;
  const BlinkingWidget(
      {this.child = const Icon(Icons.circle, color: AppColor.redPro, size: 25),
      super.key});

  @override
  BlinkingWidgetState createState() => BlinkingWidgetState();
}

class BlinkingWidgetState extends State<BlinkingWidget>
    with TickerProviderStateMixin {
  late final AnimationController animationController;
  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animationController.repeat(reverse: true);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });

    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animationController,
        builder: (context, child) => Opacity(
          opacity: animationController.value,
          child: widget.child,
        ),
        child: widget.child,
      );
}
