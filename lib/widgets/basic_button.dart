import 'package:flutter/material.dart';

class BasicButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? backColor;
  final Color? textColor;

  const BasicButton({
    super.key,
    this.onPressed,
    required this.text,
    this.backColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(backgroundColor: backColor),
      onPressed: () {
        onPressed?.call();
      },
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
