import 'package:flutter/material.dart';

class MyAppDialogs {
  void info_dialog({
    required BuildContext context,
    required String title,
    required String body,
    Function? onOkCallback,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            AlertDialog.adaptive(
              backgroundColor: Colors.white,
              title: Text(title, style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),),
              content: Text(body, style: TextStyle(color: Colors.black)),
              actions: [
                TextButton(
                    onPressed: () {
                      if (onOkCallback != null) {
                        onOkCallback();
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ));
  }

  void conf_dialog({
    required BuildContext context,
    required String title,
    required String body,
    Function? onOkCallback,
    Function? onCancelCallback,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            AlertDialog.adaptive(
              title: Text(title),
              content: Text(body),
              actions: [
                TextButton(
                    onPressed: () {
                      if (onCancelCallback != null) {
                        onCancelCallback();
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    )),
                TextButton(
                    onPressed: () {
                      if (onOkCallback != null) {
                        onOkCallback();
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ));
  }
}