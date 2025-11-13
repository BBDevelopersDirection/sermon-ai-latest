import 'package:flutter/material.dart';

class TrialMessage extends StatelessWidget {
  String message;
  TrialMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.035; // ~3.5% of width

    return Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: fontSize),
      textAlign: TextAlign.center,
    );
  }
}
