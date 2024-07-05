import 'package:alrino/presentation/theme/different.dart';
import 'package:alrino/presentation/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AutoComplitFormField extends StatelessWidget {
  final TextEditingController? controller;
  final List<String> suggestions;
  final String? hint;
  final Widget? suffix;
  final String? suffixText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? prefix;
  final String? textPrefix;
  final String? errorText;
  final bool obscureText;
  final int? maxLength;
  final int maxLines;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final String? initialValue;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function()? onEditingComplete;
  final Function(String)? onFieldSubmitted;
  final Function(String?)? onSaved;
  final bool isDense;
  final bool readOnly;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final String? subText;
  final bool isTitle;
  final Function(String)? updateSuggestions;
  final bool autoFocus;

  const AutoComplitFormField({
    super.key,
    this.controller,
    this.hint,
    this.suffix,
    this.suffixText,
    this.suffixIcon,
    this.prefixIcon,
    this.prefix,
    this.textPrefix,
    this.errorText,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.textAlign,
    this.keyboardType,
    this.initialValue,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.isDense = true,
    this.readOnly = false,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.subText,
    required this.suggestions,
    this.isTitle = false,
    this.updateSuggestions,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isTitle)
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 3, top: 10),
            child: Text(
              hint ?? '',
              style: AppText.text14,
            ),
          ),
        TypeAheadField<String>(
          autoFlipDirection: true,
          controller: controller,
          suggestionsCallback: (search) {
            return suggestions
                .where(
                    (item) => item.toLowerCase().contains(search.toLowerCase()))
                .toList();
          },
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Совпадений не найдено'),
          ),
          builder: (context, controller, focusNode) {
            return TextFormField(
              autofocus: autoFocus,
              focusNode: focusNode,
              onChanged: onChanged,
              obscureText: obscureText,
              maxLength: maxLength,
              readOnly: readOnly,
              maxLines: maxLines,
              inputFormatters: inputFormatters,
              onTap: onTap,
              textAlign: textAlign ?? TextAlign.start,
              keyboardType: keyboardType,
              onEditingComplete: onEditingComplete,
              onFieldSubmitted: onFieldSubmitted,
              onSaved: onSaved,
              validator: validator,
              controller: controller,
              textInputAction: textInputAction,
              decoration: AppDif.getInputDecoration(
                  hint: hint ?? '', clear: () => controller.clear()),
            );
          },
          itemBuilder: (context, item) => ListTile(
            title: Text(item),
          ),
          onSelected: (item) {
            if (updateSuggestions != null) updateSuggestions!(item);
            controller!.text = item;
          },
        ),
      ],
    );
  }
}
