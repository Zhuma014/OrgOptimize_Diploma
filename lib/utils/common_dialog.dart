// ignore: depend_on_referenced_packages
// ignore_for_file: sort_child_properties_last, depend_on_referenced_packages, duplicate_ignore

import 'package:flutter/material.dart';

showCustomDialog({
  required BuildContext context,
  required String title,
  required String description,
  required String positiveText,
  String? negativeText,
  required Function onPositivePressed,
  Function? onNegativePressed,
  bool barrierDismissible = true,
  WidgetBuilder? builder, 
  Color? positiveButtonColor, 
  Color? negativeButtonColor, 
}) {
  List<TextButton> actions = [];
  if (negativeText != null) {
    actions.add(TextButton(
      child: Text(negativeText),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        onNegativePressed?.call();
      },
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(negativeButtonColor),
      ),
    ));
  }

  actions.add(TextButton(
    child: Text(positiveText),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
      onPositivePressed();
    },
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(positiveButtonColor),
    ),
  ));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      if (barrierDismissible) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: actions,
        );
      } else {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: actions,
          ),
        );
      }
    },
  );
}