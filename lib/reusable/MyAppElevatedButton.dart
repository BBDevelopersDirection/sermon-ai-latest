import 'package:flutter/material.dart';

import 'progress_indicator.dart';

class Myappelevatedbutton extends StatefulWidget {
  String text;
  Function onPress;
  bool isExpanded;
  Color buttonColor;
  Color loadingColor;
  bool isLoading;

  Myappelevatedbutton(
      {super.key,
      required this.text,
      required this.buttonColor,
      required this.onPress,
      this.loadingColor = Colors.white,
      this.isLoading = false,
      this.isExpanded = false});
  @override
  State<Myappelevatedbutton> createState() => _MyappelevatedbuttonState();
}

class _MyappelevatedbuttonState extends State<Myappelevatedbutton> {
  ButtonStyle style() {
    return ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: widget.buttonColor);
  }

  TextStyle textStyle() {
    return const TextStyle(color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return widget.isExpanded
        ? SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: style(),
                onPressed: () {
                  if (!widget.isLoading) {
                    widget.onPress();
                  }
                },
                child: widget.isLoading
                    ? MyAppCircularProgressIndicator(
                        ProgressIndicatorColor: widget.loadingColor)
                    : Text(
                        widget.text,
                        style: textStyle(),
                      )),
          )
        : ElevatedButton(
            style: style(),
            onPressed: () {
              if (!widget.isLoading) {
                widget.onPress();
              }
            },
            child: widget.isLoading
                ? MyAppCircularProgressIndicator(
                    ProgressIndicatorColor: widget.loadingColor)
                : Text(widget.text, style: textStyle()));
  }
}
