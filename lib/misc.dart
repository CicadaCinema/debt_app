import 'package:flutter/material.dart';

class CustomException implements Exception {
  String cause;
  CustomException(this.cause);
}

Future<void> showDialogBox(String title, String message, BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}