import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String? svgAsset;
  final String label;
  const FeatureItem({
    super.key,
    required this.icon,
    required this.label,
    this.svgAsset,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Scale sizes based on screen width
    final double iconSize = screenWidth * 0.07; // ~7% of screen width
    final double fontSize = screenWidth * 0.035; // ~3.5% of screen width
    final double spacing = screenHeight * 0.01; // vertical space

    return Column(
      children: [
        svgAsset == null
            ? Icon(
                icon,
                color: const Color.fromRGBO(255, 182, 57, 1),
                size: iconSize,
              )
            : SizedBox(
                width: iconSize,
                height: iconSize,
                child: SvgPicture.asset(svgAsset!),
              ),
        SizedBox(height: spacing),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
        ),
      ],
    );
  }
}
