import 'package:flutter/material.dart';

void showIdentifyingLoader(BuildContext context, {bool show = true}) {
  if (show) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Identifying...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  } else {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

void showSuccessDialog({
  required BuildContext context,
  required String name,
  required VoidCallback onOkPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Identification Successful'),
        content: Text('Hey, $name! You have been identified.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              onOkPressed(); // Execute callback
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void showErrorDialog({
  required BuildContext context,
  required String message,
  VoidCallback? onOkPressed, // Optional callback
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Identification Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              onOkPressed?.call(); // Execute callback if provided
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}