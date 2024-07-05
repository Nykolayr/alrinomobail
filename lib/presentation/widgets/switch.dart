import 'package:alrino/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

/// Компонент с переключателем (вкл/выкл)
/// width - ширина переключателя
class SwitchAlrino extends StatelessWidget {
  final bool value;
  final double width;
  final Function(bool) onChanged;
  const SwitchAlrino(
      {required this.value,
      required this.onChanged,
      this.width = 76,
      super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      width: width,
      height: 25.0,
      toggleSize: 15.0,
      value: value,
      borderRadius: 15.0,
      padding: 3.0,
      onToggle: onChanged,
      activeColor: AppColor.white,
      inactiveColor: AppColor.white,
      activeToggleColor: AppColor.blue,
      inactiveToggleColor: AppColor.darkGrey,
      activeSwitchBorder: Border.all(
        color: AppColor.blue,
        width: 2.0,
      ),
      inactiveSwitchBorder: Border.all(
        color: AppColor.darkGrey,
        width: 2.0,
      ),
    );
  }
}
