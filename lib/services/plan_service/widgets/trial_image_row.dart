import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:sermon/services/plan_service/widgets/header_close_button.dart';

class TrialImageRow extends StatelessWidget {
  final List<String> imagePaths;
  const TrialImageRow({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height * 0.35;
    final double imageWidth = MediaQuery.of(context).size.width * 0.6;
    final double sideVisibleWidth = imageWidth / 2;
    final double gapBetweenImages = 22; // gap only between images

    return SizedBox(
      height: imageHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left image (half visible, tilted)
          Positioned(
            left: (MediaQuery.of(context).size.width / 2) -
                imageWidth -
                gapBetweenImages,
            child: Transform.rotate(
              angle: 8 * math.pi / 180, // rotate left image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: sideVisibleWidth,
                  height: imageHeight,
                  child: Image.asset(
                    imagePaths[0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Center image (straight)
          Transform.rotate(
            angle: 8 * math.pi / 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePaths[1],
                fit: BoxFit.cover,
                width: imageWidth,
                height: imageHeight,
              ),
            ),
          ),

          // Right image (half visible, tilted)
          Positioned(
            right: (MediaQuery.of(context).size.width / 2) -
                imageWidth -
                gapBetweenImages,
            child: Transform.rotate(
              angle: 8 * math.pi / 180, // rotate right image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: sideVisibleWidth,
                  height: imageHeight,
                  child: Image.asset(
                    imagePaths[2],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height*0.15,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height*0.15,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
  top: MediaQuery.of(context).padding.top + 8, // safe area + small margin
  left: 8,
  child: const HeaderCloseButton(),
),
        ],
      ),
    );
  }
}
