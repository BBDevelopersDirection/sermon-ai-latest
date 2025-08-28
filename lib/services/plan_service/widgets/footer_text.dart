import 'package:flutter/material.dart';

class FooterText extends StatelessWidget {
  const FooterText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "Payment will be charged to your Google Play account at the end of the trial. "
        "Subscriptions automatically renew unless you turn off auto-renew at least "
        "24 hours before the end of the current period.",
        style: TextStyle(
          color: Colors.white60,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
