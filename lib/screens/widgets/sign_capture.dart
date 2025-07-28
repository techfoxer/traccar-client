import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:traccar_client/constants/colors.dart';
import 'package:traccar_client/l10n/app_localizations.dart';
import 'package:traccar_client/utils/widget_utils.dart';
import 'package:traccar_client/widgets/basic_button.dart';

import '../../utils/progress_dialog.dart';

class SignatureCapture extends StatefulWidget {
  final bool isFailed;
  const SignatureCapture({super.key, this.isFailed = false});

  @override
  State<SignatureCapture> createState() => _SignatureCaptureState();
}

class _SignatureCaptureState extends State<SignatureCapture> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.green,
    exportBackgroundColor: Colors.transparent,
  );

  File? _attachment;
  File? _selfie;

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
      appBar: AppBar(
        title: Text(
          widget.isFailed ? localization.failed : localization.deliver,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              if (!widget.isFailed) ..._buildSign(localization, width),
              space(10),
              _buildAttachment(localization),
              _buildSelfie(localization),
              space(10),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Notes${widget.isFailed ? '' : ' (Optional)'}',
                ),
                maxLines: 3,
              ),
              _buildActions(localization, context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSign(AppLocalizations localization, double width) {
    return [
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
    ];
  }

  Row _buildActions(AppLocalizations localization, BuildContext context) {
    return Row(
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
          backColor: widget.isFailed ? Colors.red[200] : null,
          textColor: widget.isFailed ? Colors.white : null,
          text: localization.okButton,
          onPressed: () async {
            if (!widget.isFailed && _controller.isEmpty) {
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
    );
  }

  Row _buildSelfie(AppLocalizations localization) {
    return Row(
      children: [
        Text(
          localization.selfieLabel,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        space(5),
        Expanded(
          child: Text(
            _selfie == null
                ? ''
                : _selfie!.path.split(Platform.pathSeparator).last,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.primaryColor),
          ),
        ),
        IconButton(
          icon: Icon(Icons.camera_alt),
          tooltip: localization.selfieLabel,
          onPressed: () async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(
              source: ImageSource.camera,
            );

            if (pickedFile != null) {
              final location =
                  await bg.BackgroundGeolocation.getCurrentPosition();
              final timestamp = DateTime.now().toIso8601String();

              print('Selfie taken at $timestamp, Location: ${location.coords}');
              _selfie = File(pickedFile.path);
            }
          },
        ),
      ],
    );
  }

  Row _buildAttachment(AppLocalizations localization) {
    return Row(
      children: [
        Text(
          localization.attachmentLabel,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        space(5),
        Expanded(
          child: Text(
            _attachment == null
                ? ''
                : _attachment!.path.split(Platform.pathSeparator).last,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.primaryColor),
          ),
        ),
        IconButton(
          onPressed: () async {
            final file = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              type: FileType.custom,
              allowedExtensions: [
                'jpg',
                'png',
                'jpeg',
                'mp4',
                'mov',
                'mkv',
                'flv',
                '3gp',
                'pdf',
              ],
            );
            if (file != null) {
              setState(() {
                _attachment = File(file.files.first.path!);
              });
            }
          },
          icon: Icon(Icons.attachment),
        ),
      ],
    );
  }
}
