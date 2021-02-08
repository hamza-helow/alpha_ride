import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

dialog(Widget child,context,
    {List<Widget> widgets, barrierDismissible = true , Widget title , EdgeInsets padding =const EdgeInsets.all(16.0)  }) async {
  await showDialog<String>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => new AlertDialog(
            title: title,
            contentPadding: padding,
            content: child,
            actions: widgets),
      ));
}