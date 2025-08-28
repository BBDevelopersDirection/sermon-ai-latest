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

import '../firebase/utils_management/utils_functions.dart';
import '../razorpay_service.dart';
import 'widgets/header_close_button.dart';

class SubscriptionTrialScreen extends StatelessWidget {
  const SubscriptionTrialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlanPurchaseCubit, PlanPurchaseState>(
      listener: (context, state) {
        // if (state.errorCode != planPurchaseErrorCode.noError) {
        //   MyAppDialogs().info_dialog(
        //     context: context,
        //     title: 'Error Occur',
        //     body: "Error is: ${state.errorCode.toString()}",
        //   );
        // }
      },
      child: PaywallScreen()
    );
  }
}



class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TrialImageRow(
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
