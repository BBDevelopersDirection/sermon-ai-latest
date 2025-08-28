import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sermon/reusable/MyAppElevatedButton.dart';
import 'package:sermon/services/token_check_service/login_check_cubit.dart';
import 'package:sermon/services/token_check_service/login_check_state.dart';
import 'package:sermon/utils/app_assets.dart';

import 'my_app_firebase_analytics/analytic_logger.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  @override
  void initState() {
    super.initState();
    // Lock to portrait mode when the page is displayed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Reset orientation preferences when leaving the page
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackgroundImage(screenHeight),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildContent(),
            ],
          ),
          SafeArea(
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ))),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(double screenHeight) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: screenHeight * 0.6,
        child: Image.asset(
          MyAppAssets.png_recharge_background,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white,
            Colors.white,
            Colors.white,
            Colors.transparent
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                child: SvgPicture.asset(MyAppAssets.svg_recharge_now),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select one of these plans to subscribe now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF52525B),
                  fontSize: 12,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w500,
                  height: 2,
                  letterSpacing: 0.12,
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<LoginCheckCubit, LoginCheckState>(
                builder: (context, state) => Column(
                  children: [
                    _card(
                      isActive: state.currentPlan == 0,
                      leadingText: 'Monthly',
                      actualAmount: 11,
                      discountAmount: 10,
                      onTap: () => context
                          .read<LoginCheckCubit>()
                          .emit_change_plan(updateInt: 0, context: context),
                    ),
                    const SizedBox(height: 18),
                    _card(
                      isActive: state.currentPlan == 1,
                      leadingText: 'Yearly',
                      actualAmount: 132,
                      discountAmount: 60,
                      onTap: () => context
                          .read<LoginCheckCubit>()
                          .emit_change_plan(updateInt: 1, context: context),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
              Myappelevatedbutton(
                text: 'Subscribe Now',
                buttonColor: const Color(0xFFD89118),
                onPress: () {
                  if (context.read<LoginCheckCubit>().state.currentPlan == 0) {
                    MyAppAnalitics.instanse().logEvent(
                        event: 'monthly_plan_clicked_and_press_subscribe');
                  } else {
                    MyAppAnalitics.instanse().logEvent(
                        event: 'yearly_plan_clicked_and_press_subscribe');
                  }

                  context
                      .read<LoginCheckCubit>()
                      .increase_three_days(context: context);
                  context
                      .read<LoginCheckCubit>()
                      .emit_show_recharge_page(isShow: false);
                },
                isExpanded: true,
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
      {required bool isActive,
      required String leadingText,
      required int discountAmount,
      required int actualAmount,
      required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: isActive
                ? BorderSide(width: 2, color: Color(0xFFD89118))
                : BorderSide(width: 1, color: Colors.white),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isActive
                ? Container(
                    width: 15.20,
                    height: 15.20,
                    decoration: BoxDecoration(
                      color: Color(0xFFD89118),
                      shape: BoxShape.circle,
                    ))
                : Container(
                    width: 15.20,
                    height: 15.20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color(0xFFD9DCE1),
                        width: 1.0, // Border width
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                // height: 60,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      leadingText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF424245),
                        fontSize: 16,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.29,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '\$$actualAmount',
                                  style: const TextStyle(
                                    color: Color(0xFF52525B),
                                    fontSize: 14,
                                    fontFamily: 'Gilroy',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.29,
                                    decoration: TextDecoration
                                        .lineThrough, // Add this for a strikethrough
                                    decorationColor: Color(
                                        0xFF52525B), // Optional: Strikethrough color
                                    decorationThickness:
                                        2, // Optional: Thickness of the line
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$$discountAmount',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFF52525B),
                                    fontSize: 20,
                                    fontFamily: 'Gilroy',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.29,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              '${(((actualAmount - discountAmount) / actualAmount) * 100).toStringAsFixed(0)}% Off',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFFD89118),
                                fontSize: 10,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.29,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      width: 15.2,
      height: 15.2,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD89118) : Colors.white,
        shape: BoxShape.circle,
        border: isActive
            ? null
            : Border.all(
                color: const Color(0xFFD9DCE1),
                width: 1.0,
              ),
      ),
    );
  }

  Widget _buildPlanDetails({
    required String leadingText,
    required int actualAmount,
    required int discountAmount,
  }) {
    final int discountPercentage =
        (((actualAmount - discountAmount) / actualAmount) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leadingText,
              style: const TextStyle(
                color: Color(0xFF424245),
                fontSize: 16,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w600,
                height: 2.25,
                letterSpacing: 0.29,
              ),
            ),
            Spacer(),
            Text(
              '\$$actualAmount',
              style: const TextStyle(
                color: Color(0xFF52525B),
                fontSize: 14,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w700,
                height: 1.20,
                letterSpacing: 0.29,
                decoration:
                    TextDecoration.lineThrough, // Add this for a strikethrough
                decorationColor:
                    Color(0xFF52525B), // Optional: Strikethrough color
                decorationThickness: 2, // Optional: Thickness of the line
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$$discountAmount',
              style: const TextStyle(
                color: Color(0xFF52525B),
                fontSize: 20,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w700,
                height: 1.20,
                letterSpacing: 0.29,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Spacer(),
            Text(
              '$discountPercentage% Off',
              style: const TextStyle(
                color: Color(0xFFD89118),
                fontSize: 10,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w700,
                height: 1.20,
                letterSpacing: 0.29,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
