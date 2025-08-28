import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utils/app_assets.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen dimensions
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the size of the Lottie animation dynamically
    final double lottieSize =
        (screenHeight < screenWidth ? screenHeight : screenWidth) * 0.7;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                MyAppAssets.lottie_no_internet,
                width: lottieSize,
                height: lottieSize,
                fit: BoxFit.contain,
              ),
              // No Internet Text
              const Text(
                "No Internet Connection",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
