import 'package:alrino/presentation/theme/colors.dart';
import 'package:flutter/material.dart';

class AppDif {
  static const Divider divider = Divider(color: AppColor.grey, height: 1);
  static const Radius radius20 = Radius.circular(20);
  static const Radius radius10 = Radius.circular(10);
  static const Radius radius5 = Radius.circular(5);
  static const BorderRadius borderRadius20 = BorderRadius.all(radius20);
  static const BorderRadius borderRadius10 = BorderRadius.all(radius10);
  static const BorderRadius borderRadius5 = BorderRadius.all(radius5);
  static BoxBorder borderAll = Border.all(
    color: AppColor.blackText,
    width: 0.5,
  );
  static Decoration decotationBlueRadius = BoxDecoration(
    borderRadius: borderRadius20,
    color: AppColor.lightblue,
    border: Border.all(
      color: AppColor.white,
      width: 1,
    ),
  );

  /// общий для всех textField
  static InputDecoration getInputDecoration({
    required String hint,
    bool isTitle = false,
    Function()? clear,
  }) {
    return InputDecoration(
      errorStyle: const TextStyle(fontSize: 10, height: 0.3),
      border: getOutlineBorder(),
      focusedBorder: getOutlineBorder(),
      enabledBorder: getOutlineBorder(),
      disabledBorder: getOutlineBorder(),
      errorBorder: getOutlineBorder(color: AppColor.redPro),
      focusedErrorBorder: getOutlineBorder(color: AppColor.redPro),
      filled: true,
      hintStyle: const TextStyle(color: AppColor.darkGrey),
      hintText: hint,
      fillColor: AppColor.lightblue,
      suffixIcon: clear != null
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: clear,
            )
          : null,
      contentPadding: isTitle
          ? null
          : const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
    );
  }

  static OutlineInputBorder getOutlineBorder({Color color = AppColor.white}) {
    return OutlineInputBorder(
      borderRadius: AppDif.borderRadius20,
      borderSide: BorderSide(
        width: 1,
        style: BorderStyle.solid,
        color: color,
      ),
    );
  }
}
