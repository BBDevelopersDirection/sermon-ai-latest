import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/app_assets.dart';

class PulsingIconAnim extends StatefulWidget {
  Color? appLogoColor;
  PulsingIconAnim({this.appLogoColor});

  @override
  _AnimatedImageScreenState createState() => _AnimatedImageScreenState();
}

class _AnimatedImageScreenState extends State<PulsingIconAnim>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    // Define an opacity animation from 0.5 to 1.0
    _animation = Tween<double>(begin: 0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: SizedBox(
                  child: widget.appLogoColor == null
                      ? SvgPicture.asset(MyAppAssets.svg_image_icon_full)
                      : SvgPicture.asset(MyAppAssets.svg_image_icon_full,
                          theme: SvgTheme(currentColor: widget.appLogoColor!),
                          colorFilter: ColorFilter.mode(
                              widget.appLogoColor!, BlendMode.srcIn))),
            );
          },
        ),
      ),
    );
  }
}
