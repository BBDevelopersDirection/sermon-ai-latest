import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MyAppCircularProgressIndicator extends StatelessWidget {
  Color ProgressIndicatorColor;

  MyAppCircularProgressIndicator(
      {super.key, this.ProgressIndicatorColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    // Check platform and return the appropriate progress indicator
    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoActivityIndicator(
            color: ProgressIndicatorColor,
          ) // iOS style indicator
        : CircularProgressIndicator(
            color: ProgressIndicatorColor,
          ); // Android style indicator
  }
}
