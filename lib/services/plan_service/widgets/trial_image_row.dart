import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:sermon/services/plan_service/widgets/header_close_button.dart';

class TrialImageRow extends StatelessWidget {
  final List<String> imagePaths;
  final VoidCallback? onTap;
  final bool IsForLogin;

  const TrialImageRow({super.key, required this.imagePaths, this.onTap, this.IsForLogin=false});

  Widget _buildImage(BuildContext context, String? path, double width, double height, {double rotation = 0}) {
    if (path == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Transform.rotate(
      angle: rotation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          width: width,
          height: height,
          errorBuilder: (ctx, err, stack) => Container(
            width: width,
            height: height,
            color: Colors.grey.shade800,
            child: const Center(child: Icon(Icons.broken_image, color: Colors.white70)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = IsForLogin? MediaQuery.of(context).size.height * 0.28 : MediaQuery.of(context).size.height * 0.35;
    final double imageWidth = MediaQuery.of(context).size.width * 0.6;
    final double sideVisibleWidth = imageWidth / 2;
    final double gapBetweenImages = 22; // gap only between images

    // Safe accessors: fallback to nearest available image or null
    String? leftImage;
    String? centerImage;
    String? rightImage;

    if (imagePaths.isEmpty) {
      leftImage = centerImage = rightImage = null;
    } else if (imagePaths.length == 1) {
      leftImage = centerImage = rightImage = imagePaths[0];
    } else if (imagePaths.length == 2) {
      leftImage = imagePaths[0];
      centerImage = imagePaths[1];
      rightImage = imagePaths[1];
    } else {
      leftImage = imagePaths[0];
      centerImage = imagePaths[1];
      rightImage = imagePaths[2];
    }

    return SizedBox(
      height: imageHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left image (half visible, tilted)
          Positioned(
            left: (MediaQuery.of(context).size.width / 2) - imageWidth - gapBetweenImages,
            child: SizedBox(
              width: sideVisibleWidth,
              height: imageHeight,
              child: _buildImage(context, leftImage, sideVisibleWidth, imageHeight, rotation: -8 * math.pi / 180),
            ),
          ),

          // Center image (straight)
          SizedBox(
            width: imageWidth,
            height: imageHeight,
            child: _buildImage(context, centerImage, imageWidth, imageHeight, rotation: 0),
          ),

          // Right image (half visible, tilted)
          Positioned(
            right: (MediaQuery.of(context).size.width / 2) - imageWidth - gapBetweenImages,
            child: SizedBox(
              width: sideVisibleWidth,
              height: imageHeight,
              child: _buildImage(context, rightImage, sideVisibleWidth, imageHeight, rotation: 8 * math.pi / 180),
            ),
          ),

          // Top gradient
          Visibility(
            visible: IsForLogin == false,
            child: Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.15,
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
          ),

          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.15,
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

          // Close button
          Visibility(
            visible: IsForLogin == false,
            child: Positioned(
              top: MediaQuery.of(context).padding.top + 8, // safe area + small margin
              left: 8,
              child: HeaderCloseButton(onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}
