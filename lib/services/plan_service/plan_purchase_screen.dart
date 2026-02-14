import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/reusable/app_dialogs.dart';
import 'package:sermon/reusable/progress_indicator.dart';
import 'package:sermon/services/firebase/models/utility_model.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
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
    AppLogger.d("Back button pressed! Run cleanup or analytics here.");
    if (widget.controller != null && !widget.controller!.value.isPlaying) {
      widget.controller!.play();
      widget.controller!.setVolume(1);
    }
    return true;
  }

  late Future<bool> _is30DaysFuture;

  @override
  void initState() {
    super.initState();
    _is30DaysFuture = _checkIf30DaysSubscription();
  }

  Future<bool> _checkIf30DaysSubscription() async {
    final userId =
        FirebaseAuth.instance.currentUser?.uid ?? HiveBoxFunctions().getUuid();

    final utilityModel = await UtilsFunctions().getFirebaseUtility(
      userId: userId,
    );

    return utilityModel?.is30DaysSubscriptionID ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: BlocListener<PlanPurchaseCubit, PlanPurchaseState>(
        listener: (context, state) {
          // Handle subscription state changes if needed
        },
        child: FutureBuilder<bool>(
          future: _is30DaysFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: MyAppCircularProgressIndicator(
                  ProgressIndicatorColor: Colors.white,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Something went wrong",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final is30Days = snapshot.data ?? false;

            return is30Days
                ? PaywallScreen30Days(controller: widget.controller)
                : PaywallScreen7Days(controller: widget.controller);
          },
        ),
      ),
    );
  }
}

class PaywallScreen30Days extends StatelessWidget {
  final VideoPlayerController? controller;
  const PaywallScreen30Days({super.key, this.controller});

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
                MyAppAssets.png_login_image_5, // Replace with your image paths
                MyAppAssets.png_login_image_6,
                MyAppAssets.png_login_image_2,
              ],
            ),
            const SizedBox(height: 20),
            TrialMessage(message: 'Apka free limit end hogaya ha'),
            const SizedBox(height: 10),
            const TrialPriceInfo30Days(),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(),
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
                SizedBox(),
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

class PaywallScreen7Days extends StatelessWidget {
  final VideoPlayerController? controller;
  const PaywallScreen7Days({super.key, this.controller});

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
                MyAppAssets.png_login_image_5, // Replace with your image paths
                MyAppAssets.png_login_image_6,
                MyAppAssets.png_login_image_2,
              ],
            ),
            const SizedBox(height: 20),
            TrialMessage(
              message: 'Jai masih ke, apka free limit end hogaya hai',
            ),
            const SizedBox(height: 10),
            const TrialPriceInfo7Days(),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(),
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
                SizedBox(),
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
