import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_face_ai_project/constants/colors.dart';

errorSnackBar(BuildContext context, String content) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

successSnackBar(BuildContext context, String content) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      backgroundColor: accentColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
