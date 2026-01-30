import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sermon/services/log_service/log_service.dart';
import 'package:sermon/services/log_service/log_variables.dart';

import '../main.dart';
import '../services/token_check_service/login_check_cubit.dart';
import '../services/token_check_service/login_check_screen.dart';
import '../utils/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _changePage() async {
  await context.read<LoginCheckCubit>().checkForUpdate();

  await Future.delayed(const Duration(milliseconds: 500));

  if (!mounted) return;

  // Splash END happens here
  await MyAppAmplitudeAndFirebaseAnalitics().logEvent(
    event: LogEventsName.instance().splashscreenEnd,
  );

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) =>
          LoginCheckScreen(isLoginOrRegesterFlow: false),
    ),
  );
}

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().splashscreenStart,
    );

    if (!mounted) return;
    await _changePage();
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.45,
              child: SvgPicture.asset(MyAppAssets.svg_image_icon_full),
            ),
          ],
        ),
      ),
    );
  }
}
