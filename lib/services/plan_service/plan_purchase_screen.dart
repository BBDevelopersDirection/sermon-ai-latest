import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/reusable/app_dialogs.dart';
import 'package:sermon/services/plan_service/plan_purchase_cubit.dart';
import 'package:sermon/services/plan_service/plan_purchase_state.dart';
import 'package:sermon/services/plan_service/widgets/footer.dart';
import 'package:sermon/services/plan_service/widgets/footer_text.dart';
import 'package:sermon/services/plan_service/widgets/subscription_button.dart';
import 'package:sermon/services/plan_service/widgets/trail_message.dart';
import 'package:sermon/services/plan_service/widgets/trial_image_row.dart';
import 'package:sermon/services/plan_service/widgets/trial_price_info.dart';
import 'package:sermon/utils/app_assets.dart';
import 'package:video_player/video_player.dart';

import '../firebase/utils_management/utils_functions.dart';
import '../razorpay_service.dart';
import 'widgets/header_close_button.dart';

class SubscriptionTrialScreen extends StatelessWidget {
  final VideoPlayerController? controller;
  SubscriptionTrialScreen({super.key, this.controller});

  Future<bool> _onWillPop(BuildContext context) async {
    // 👉 Your custom function here
    debugPrint("Back button pressed! Run cleanup or analytics here.");

    // Example: Resume video if controller exists
    if (controller != null && !controller!.value.isPlaying) {
      controller!.play();
    }

    // Return true to allow pop, false to block
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: BlocListener<PlanPurchaseCubit, PlanPurchaseState>(
        listener: (context, state) {
          // Handle subscription state changes if needed
        },
        child: PaywallScreen(controller: controller),
      ),
    );
  }
}




class PaywallScreen extends StatelessWidget {
  final VideoPlayerController? controller;
  const PaywallScreen({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TrialImageRow(
              onTap: () {
                controller?.play();
              },
              imagePaths: [
                MyAppAssets.png_paywall_1, // Replace with your image paths
                MyAppAssets.png_paywall_2,
                MyAppAssets.png_paywall_3,
              ],
            ),
            const SizedBox(height: 20),
            const TrialMessage(),
            const SizedBox(height: 10),
            const TrialPriceInfo(),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FeatureItem(
                  icon: Icons.translate,
                  label: "Hindi Mai\npravachan\ndekhiye",
                ),
                SizedBox(width: 30),
                FeatureItem(
                  icon: Icons.add,
                  label: "Har topic pe\npravachan\ndekhiye",
                ),
                SizedBox(width: 30),
                FeatureItem(
                  icon: Icons.play_circle_fill,
                  label: "Naye pravachan\nhar din",
                ),
              ],
            ),
            const Spacer(),
            const FooterText(),
            const SizedBox(height: 12),
            const SubscribeButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
