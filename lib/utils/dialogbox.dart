import 'package:flutter/material.dart';

Future<void> _actionButton() async {
  var context;
  switch (await showDialog<Department>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('What '),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, Department);
              },
              child: const Text('Treasury department'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, Department);
              },
              child: const Text('State department'),
            ),
          ],
        );
      })) {
    case Department:
      // Let's go.
      // ...
      break;
    case Department:
      // ...
      break;
    case null:
      // dialog dismissed
      break;
  }
}

class Department {}
