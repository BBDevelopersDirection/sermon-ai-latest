import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TrialPriceInfo30Days extends StatelessWidget {
  const TrialPriceInfo30Days({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizes
    final double titleFontSize = screenWidth * 0.055; // ~5.5% of width
    final double subtitleFontSize = screenWidth * 0.035; // ~3.5% of width
    final double spacing = screenHeight * 0.008; // ~0.8% of height

    return Column(
      children: [
        AutoSizeText(
          "100/- per month ka subscription lijiye",
          maxLines: 1,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        AutoSizeText(
          "Aur unlimited sermons dekhiye. Cancel anytime.",
          maxLines: 1,
          style: TextStyle(color: Colors.white70, fontSize: subtitleFontSize),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class TrialPriceInfo7Days extends StatelessWidget {
  const TrialPriceInfo7Days({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizes
    final double titleFontSize = screenWidth * 0.055; // ~5.5% of width
    final double subtitleFontSize = screenWidth * 0.035; // ~3.5% of width
    final double spacing = screenHeight * 0.008; // ~0.8% of height

    return Column(
      children: [
        AutoSizeText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Try 7 days for just ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "₹5",
                style: TextStyle(
                  color: Color(0xFFD89118),
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing),
        AutoSizeText(
          "Then Rs 99/month. Unlimited sermons dekhiye.",
          maxLines: 1,
          style: TextStyle(color: Colors.white70, fontSize: subtitleFontSize),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing),
        AutoSizeText(
          "Cancel anytime.",
          maxLines: 1,
          style: TextStyle(
          color: Color(0xFF918989),
          fontSize: 12,
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w700,
          height: 1.5,
          letterSpacing: 0.12,
        ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
