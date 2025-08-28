import 'package:flutter/material.dart';

class TrialMessage extends StatelessWidget {
  const TrialMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.035; // ~3.5% of width

    return Text(
      "Apka free limit end hogaya ha",
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
      ),
      textAlign: TextAlign.center,
    );
  }
}
