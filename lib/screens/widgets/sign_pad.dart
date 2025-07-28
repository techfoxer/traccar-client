import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:traccar_client/l10n/app_localizations.dart';
import 'package:traccar_client/utils/widget_utils.dart';

import '../../constants/colors.dart';

class SignaturePad extends StatefulWidget {
  final void Function(File imageFile) onSigned;
  final String label;

  const SignaturePad({super.key, required this.onSigned, required this.label});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.primaryColor,
  );
  bool _saved = false;
  Future<void> _saveSignature() async {
    final Uint8List? data = await _controller.toPngBytes();
    if (data != null) {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(data);
      widget.onSigned(file);
      setState(() {
        _saved = true;
      });
    }
  }

  @override
  void initState() {
    _controller.addListener(() {
      _saved = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            if (!_saved && _controller.isNotEmpty) ...[
              space(5),
              Text(
                '(${localization.unsaved})',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ],
            Spacer(),
            if (_controller.isNotEmpty)
              InkWell(
                onTap: () {
                  _controller.clear();
                },
                child: Text(
                  localization.clear,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
          ],
        ),
        space(10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryColor),
            borderRadius: radius(5),
          ),
          child: ClipRRect(
            borderRadius: radius(5),
            child: Signature(
              controller: _controller,
              height: 150,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        space(5),
        ElevatedButton(
          onPressed: _saved || _controller.isEmpty ? null : _saveSignature,
          child: Text(localization.saveButton),
        ),
      ],
    );
  }
}
