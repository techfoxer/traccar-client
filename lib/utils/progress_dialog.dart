import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../constants/colors.dart';
import 'navigation_service.dart';

class PleaseWait {
  static final ProgressDialog _progressDialog = ProgressDialog(
    context: NavigationService.navigatorKey.currentContext,
    msg: 'Please wait..',
    backgroundColor: AppColors.primaryColor,
    msgColor: AppColors.secondaryColor,
    progressValueColor: AppColors.secondaryColor,
    msgMaxLines: 2,
    barrierColor: Colors.white.withValues(alpha: .5),
    hideValue: true,
  );

  static Future<void> show({String? msg}) async {
    await _progressDialog.show(msg: msg ?? 'Please wait..');
  }

  static void update({String? msg, int? value}) {
    _progressDialog.update(msg: msg, value: value);
  }

  static void close() {
    _progressDialog.close();
  }
}
