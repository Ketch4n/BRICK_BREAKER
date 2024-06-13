// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showAlertDialog(
    BuildContext context, String title, String message, String status) async {
  await showDialog<String>(
    // barrierColor: status == "Warning" ? Colors.transparent : null,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(
              color: status == "Warning" ? Colors.orange : Colors.green),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 18,
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
