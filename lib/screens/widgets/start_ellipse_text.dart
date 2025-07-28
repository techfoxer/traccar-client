import 'package:flutter/material.dart';

class StartEllipsisText extends StatelessWidget {
  final String text;
  final Color? color;
  final int maxLines;

  const StartEllipsisText(
    this.text, {
    super.key,
    this.color,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = DefaultTextStyle.of(
      context,
    ).style.copyWith(color: color);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullTextPainter = TextPainter(
          text: TextSpan(text: text, style: effectiveStyle),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (!fullTextPainter.didExceedMaxLines) {
          return Text(text, style: effectiveStyle, maxLines: maxLines);
        }

        // Measure ellipsis width only once
        final ellipsisPainter = TextPainter(
          text: TextSpan(text: '...', style: effectiveStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        final ellipsisWidth = ellipsisPainter.width;

        // Now measure how many characters from the end can fit after that
        int left = 0;
        int right = text.length;
        String visible = '';

        while (left < right) {
          final mid = (left + right) ~/ 2;
          final sub = text.substring(text.length - mid);

          final subPainter = TextPainter(
            text: TextSpan(text: sub, style: effectiveStyle),
            maxLines: maxLines,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth - ellipsisWidth);

          if (subPainter.didExceedMaxLines) {
            right = mid;
          } else {
            visible = sub;
            left = mid + 1;
          }
        }

        return Text(
          '...$visible',
          style: effectiveStyle,
          maxLines: maxLines,
          overflow: TextOverflow.clip,
        );
      },
    );
  }
}
