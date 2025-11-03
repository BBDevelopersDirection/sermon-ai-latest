import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/reusable/app_dialogs.dart';
import 'package:sermon/services/firebase/models/utility_model.dart';
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
import 'package:sermon/reusable/logger_service.dart';

class SubscriptionTrialScreen extends StatefulWidget {
  final VideoPlayerController? controller;
  SubscriptionTrialScreen({super.key, this.controller});

  @override
  State<SubscriptionTrialScreen> createState() =>
      _SubscriptionTrialScreenState();
}

class _SubscriptionTrialScreenState extends State<SubscriptionTrialScreen> {
  Future<bool> _onWillPop(BuildContext context) async {
    // 👉 Your custom function here
    AppLogger.d("Back button pressed! Run cleanup or analytics here.");
    if (widget.controller != null && !widget.controller!.value.isPlaying) {
      widget.controller!.play();
      widget.controller!.setVolume(1);
    }

    // Return true to allow pop, false to block
    return true;
  }

  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: BlocListener<PlanPurchaseCubit, PlanPurchaseState>(
        listener: (context, state) {
          // Handle subscription state changes if needed
        },
        child: BlocBuilder<PlanPurchaseCubit, PlanPurchaseState>(
          builder: (context, state) {
            if (state.subscriptionType == subscriptionTypes.freeTrial) {
              return PaywallScreen(
                controller: widget.controller,
                isFreeTrialSubscription: true,
              );
            } else if (state.subscriptionType ==
                subscriptionTypes.normalSubscription) {
              return PaywallScreen(
                controller: widget.controller,
                isFreeTrialSubscription: false,
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

class PaywallScreen extends StatelessWidget {
  final VideoPlayerController? controller;
  final bool isFreeTrialSubscription;
  const PaywallScreen({
    super.key,
    this.controller,
    required this.isFreeTrialSubscription,
  });

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
                controller?.setVolume(1);
              },
              imagePaths: [
                MyAppAssets.png_login_image_6, // Replace with your image paths
                MyAppAssets.png_login_image_5,
                MyAppAssets.png_login_image_2,
              ],
            ),
            const SizedBox(height: 20),
            const TrialMessage(),
            const SizedBox(height: 10),
            TrialPriceInfo(isFreeTrialSubscription: isFreeTrialSubscription),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(width: 1),
                const FeatureItem(
                  icon: Icons.translate,
                  label: "Hindi Mai\npravachan\ndekhiye",
                ),
                const SizedBox(width: 1),
                FeatureItem(
                  icon: Icons.add,
                  svgAsset: MyAppAssets.svg_christ_plus,
                  label: "Har topic pe\npravachan\ndekhiye",
                ),
                const SizedBox(width: 1),
                const FeatureItem(
                  icon: Icons.play_circle_fill,
                  label: "Naye pravachan\nhar din",
                ),
                const SizedBox(width: 1),
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
