import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  void change_page({required BuildContext context}) {
    Future.delayed(Duration(seconds: 1)).then((_) async {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) =>
          LoginCheckScreen()));
    });
  }

  @override
  void initState() {
    change_page(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery
            .sizeOf(context)
            .width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(MyAppAssets.svg_image_icon_full)
          ],
        ),
      ),
    );
  }
}
