import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:signature/signature.dart';
import 'package:traccar_client/constants/colors.dart';
import 'package:traccar_client/l10n/app_localizations.dart';
import 'package:traccar_client/utils/widget_utils.dart';
import 'package:traccar_client/widgets/basic_button.dart';

import '../../utils/progress_dialog.dart';

class SignatureCapture extends StatefulWidget {
  const SignatureCapture({super.key});

  @override
  State<SignatureCapture> createState() => _SignatureCaptureState();
}

class _SignatureCaptureState extends State<SignatureCapture> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.green,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width - 40;
    return Scaffold(
      appBar: AppBar(title: Text(localization.deliver)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${localization.packageId}:",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                space(5),
                Expanded(
                  child: Text(
                    'DSAD323-32342342-SSFSDJ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            space(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.sign,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                if (_controller.isNotEmpty)
                  InkWell(
                    onTap: () {
                      _controller.undo();
                    },
                    child: Text(
                      localization.undo,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            space(10),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryColor),
                  borderRadius: radius(5),
                ),
                width: width,
                height: width,
                child: ClipRRect(
                  borderRadius: radius(5),
                  child: Signature(
                    controller: _controller,
                    width: width,
                    height: width,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            space(10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Notes (Optional)',
              ),
              maxLines: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BasicButton(
                  text: localization.cancelButton,
                  backColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 10),
                BasicButton(
                  text: localization.okButton,
                  onPressed: () async {
                    if (_controller.isEmpty) {
                      showSnack(message: localization.sign);
                    } else {
                      PleaseWait.show();
                      final png = await _controller.toPngBytes();
                      final location =
                          await bg.BackgroundGeolocation.getCurrentPosition();
                      final time = DateTime.now().millisecondsSinceEpoch;
                      print('DEVLOG - Location: $location');
                      PleaseWait.close();
                      pop();
                      showSnack(
                        message: localization.delivered,
                        type: SnackType.success,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
