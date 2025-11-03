import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TrialPriceInfo extends StatelessWidget {
  final bool isFreeTrialSubscription;
  const TrialPriceInfo({super.key, this.isFreeTrialSubscription = true});

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
              isFreeTrialSubscription
                  ? TextSpan(
                      text: 'Try 7 days for just ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Epilogue',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    )
                  : TextSpan(
                      text: '₹99/- for per month',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Epilogue',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
              isFreeTrialSubscription
                  ? TextSpan(
                      text: '₹5',
                      style: TextStyle(
                        color: Color(0xFFD89118),
                        fontSize: 28,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    )
                  : TextSpan(
                      text: '',
                      style: TextStyle(
                        color: Color(0xFFD89118),
                        fontSize: 28,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 1, // force it to stay in one line
          minFontSize: 14, // shrink down if needed
          overflow: TextOverflow.ellipsis, // optional
        ),
        SizedBox(height: spacing),
        AutoSizeText.rich(
          TextSpan(
            children: [
              isFreeTrialSubscription
                  ? TextSpan(
                      text: 'Then Rs 99/month. Unlimited sermons dekhiye. ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: 0.12,
                      ),
                    )
                  : TextSpan(
                      text: 'Unlimited Sermons Dekhiye',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: 0.12,
                      ),
                    ),
              TextSpan(
                text: '\nCancel anytime.',
                style: TextStyle(
                  color: Color(0xFF918989),
                  fontSize: 12,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                  letterSpacing: 0.12,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 2, // you can allow multiple lines if needed
          minFontSize: 8, // the minimum size it will shrink to
          overflow: TextOverflow.ellipsis, // optional
        ),
      ],
    );
  }
}
