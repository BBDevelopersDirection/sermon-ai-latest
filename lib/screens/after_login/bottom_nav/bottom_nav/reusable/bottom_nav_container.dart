import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavContainer extends StatelessWidget {
  IconData asset;
  BottomNavContainer({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          // color: Color.fromRGBO(99, 0, 4, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          asset, // Replace with your icon
          color: Colors.white, // Active icon color
        ),
      ));
  }
}
