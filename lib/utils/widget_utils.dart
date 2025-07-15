import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'navigation_service.dart';

space(double space) {
  return SizedBox(height: space, width: space);
}

goto({
  Widget? widget,
  String? path,
  Object? arguments,
  BuildContext? context,
}) async {
  if (path != null) {
    return await Navigator.pushNamed(
      context ?? NavigationService.navigatorKey.currentContext!,
      path,
      arguments: arguments,
    );
  } else {
    return await Navigator.push(
      context ?? NavigationService.navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => widget!),
    );
  }
}

gotoNew({Widget? widget, String? path, Object? arguments}) {
  if (path != null) {
    Navigator.pushReplacementNamed(
      NavigationService.navigatorKey.currentContext!,
      path,
      arguments: arguments,
    );
  } else {
    Navigator.pushReplacement(
      NavigationService.navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => widget!),
    );
  }
}

gotoClear({Widget? widget, String? path, Object? arguments}) {
  if (path != null) {
    Navigator.pushNamedAndRemoveUntil(
      NavigationService.navigatorKey.currentContext!,
      path,
      arguments: arguments,
      (route) => false,
    );
  } else {
    Navigator.pushAndRemoveUntil(
      NavigationService.navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => widget!),
      (route) => false,
    );
  }
}

dynamic pop({dynamic data, BuildContext? context}) {
  Navigator.of(
    context ?? NavigationService.navigatorKey.currentContext!,
  ).pop(data);
}

BorderRadius radius(
  double size, {
  bool topLeft = false,
  bool topRight = false,
  bool bottomLeft = false,
  bool bottomRight = false,
}) {
  if (topLeft || topRight || bottomLeft || bottomRight) {
    return BorderRadius.only(
      bottomLeft: bottomLeft ? Radius.circular(size) : Radius.zero,
      bottomRight: bottomRight ? Radius.circular(size) : Radius.zero,
      topLeft: topLeft ? Radius.circular(size) : Radius.zero,
      topRight: topRight ? Radius.circular(size) : Radius.zero,
    );
  }
  return BorderRadius.circular(size);
}

/// Displays a confirmation dialog with customizable title and message.
///
/// - [title]: The title of the dialog (defaults to a localized 'Confirm' title).
/// - [message]: The message displayed in the dialog (defaults to a localized confirmation message).
/// - [onConfirm]: A required callback function that executes when the user confirms.
///
/// The dialog provides two options:
/// - **Cancel**: Dismisses the dialog without taking action.
/// - **Proceed**: Executes the [onConfirm] callback and dismisses the dialog.
Future<void> confirm({
  String? title,
  String? message,
  required VoidCallback onConfirm,
}) async {
  await showDialog(
    context: NavigationService.navigatorKey.currentContext!,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.8;

      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Text(title ?? 'Confirmation'),
        content: ConstrainedBox(
          constraints: BoxConstraints(minWidth: dialogWidth),
          child: Text(message ?? 'Do you want to proceed?'),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          const SizedBox(width: 5),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm();
            },
            child: Text('Proceed', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

/// Displays an informational message dialog with an optional confirmation action.
///
/// - [title]: The title of the dialog (defaults to a localized 'Message' title).
/// - [message]: The content of the dialog (required).
/// - [onConfirm]: An optional callback function that executes when the user acknowledges the message.
///
/// The dialog provides a single **OK** button to dismiss the dialog.
Future<void> showMessage({
  String? title,
  required String message,
  VoidCallback? onConfirm,
}) async {
  await showDialog(
    context: NavigationService.navigatorKey.currentContext!,
    builder: (context) {
      return AlertDialog(
        title: Text(title ?? 'Message'),
        content: Text(message),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm?.call();
            },
            child: Text('Ok', style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

enum SnackType { success, error }

showSnack({
  required String message,
  String? title,
  SnackType type = SnackType.error,
}) {
  Get.snackbar(
    title ?? (type == SnackType.error ? 'Error' : 'Success'),
    message,
    backgroundColor: type == SnackType.error ? Colors.red : Colors.green,
    colorText: Colors.white,
  );
}
