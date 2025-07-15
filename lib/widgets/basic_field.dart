import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/colors.dart';
import '../utils/utility.dart';
import '../utils/widget_utils.dart';

class BasicTextField extends StatelessWidget {
  final Color? borderColor;
  final Color? textColor;
  final String? header;
  final String hint;
  final String? label;
  final TextInputType? inputType;
  final bool hideText;
  final Widget? suffix;
  final Widget? prefix;
  final bool enabled;
  final bool editable;
  final int? maxLength;
  final bool mini;
  final bool showSuffix;
  final double borderRadius;
  final Function(String)? onChanged;
  final void Function()? onTap;
  final TextEditingController? controller;
  final String? Function(String? text)? validator;
  final int maxLines;
  const BasicTextField({
    super.key,
    this.borderColor,
    this.maxLines = 1,
    this.textColor,
    this.controller,
    this.hint = '',
    this.label,
    this.header,
    this.inputType,
    this.hideText = false,
    this.suffix,
    this.borderRadius = 30,
    this.prefix,
    this.enabled = true,
    this.editable = true,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.mini = true,
    this.validator,
    this.showSuffix = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header == null
            ? const Offstage()
            : Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                header!,
                style: const TextStyle(color: AppColors.primaryColor),
              ),
            ),
        StatefulBuilder(
          builder: (context, state) {
            return TextFormField(
              onTap: onTap,
              validator: validator,
              controller: controller,
              maxLines: maxLines,
              obscureText: hideText,
              maxLength: maxLength,
              enabled: enabled,
              readOnly: !editable,
              keyboardType: inputType,
              inputFormatters: [
                if (inputType == TextInputType.number)
                  FilteringTextInputFormatter(DECIMAL_NUMBERS, allow: true),
                if (inputType == TextInputType.phone)
                  FilteringTextInputFormatter(NUMBERS, allow: true),
              ],
              onChanged:
                  onChanged ??
                  (val) {
                    state(() {});
                  },
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withValues(alpha: .2),
                labelStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: radius(borderRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: radius(borderRadius),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: radius(borderRadius),
                ),
                labelText: label,
                hintText: hint,
                suffixIcon:
                    suffix ??
                    (!showSuffix
                        ? null
                        : (((controller?.text.length ?? 0) > 0 && editable)
                            ? IconButton(
                              onPressed: () {
                                controller?.clear();
                                state(() {});
                              },
                              icon: const Icon(Icons.clear),
                            )
                            : null)),
                prefixIcon: prefix,
                contentPadding:
                    mini
                        ? EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: maxLines > 1 ? 10 : 0,
                        )
                        : null,
              ),
            );
          },
        ),
      ],
    );
  }
}
