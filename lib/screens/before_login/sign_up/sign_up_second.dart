import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sermon/screens/before_login/login_forgot_signup_state.dart';

import '../../../reusable/MyAppElevatedButton.dart';
import '../../../reusable/my_scaffold_widget.dart';
import '../login_forgot_signup_cubit.dart';

class SignUpSecondScreen extends StatefulWidget {
  String number;
  SignUpSecondScreen({super.key, required this.number});
  @override
  State<SignUpSecondScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpSecondScreen> {
  late TextEditingController otp_num;
  @override
  void initState() {
    otp_num = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    otp_num.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = (screenWidth - 32) / 8;
    return MyScaffold(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(16, 15, 22, 1),
        body: SafeArea(
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AutoSizeText(
                      'Please Enter the OTP',
                      maxLines: 1,
                      minFontSize: 4,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.12,
                      ),
                    ),
                  ),
                  AutoSizeText(
                    'We Send an OTP to +91${widget.number}',
                    maxLines: 1,
                    minFontSize: 4,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.12,
                    ),
                  ),
                  SizedBox(height: 12),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: otp_num,
                    keyboardType: TextInputType.number,
                    obscureText:
                        false, // Set to true if you want to obscure the input
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: boxWidth + 8,
                      fieldWidth: boxWidth,
                      activeFillColor: Color.fromRGBO(41, 41, 56, 1),
                      inactiveFillColor: Color.fromRGBO(41, 41, 56, 1),
                      selectedFillColor: Color.fromRGBO(41, 41, 56, 1),
                      inactiveColor: Color.fromRGBO(41, 41, 56, 1),
                    ),
                    cursorColor: Colors.white,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    textStyle: TextStyle(color: Colors.white, fontSize: 16),
                    onCompleted: (value) {
                      context.read<LoginForgotSignupCubit>().otp_ver_screen(
                        context: context,
                        controller: otp_num,
                        number: widget.number,
                      );
                      // Perform actions with the entered PIN
                    },
                    onChanged: (value) {},
                  ),
                  Spacer(),
                  BlocBuilder<LoginForgotSignupCubit, LoginForgotSignupState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(31, 32, 214, 1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (state.loadingStatus ==
                                LoadingStatus.otpLoading) {
                              return; // Prevent multiple taps
                            }
                            context
                                .read<LoginForgotSignupCubit>()
                                .otp_ver_screen(
                                  isSubmit: true,
                                  context: context,
                                  controller: otp_num,
                                  number: widget.number,
                                );
                          },
                          child: state.loadingStatus != LoadingStatus.otpLoading
                              ? Text(
                                  'Verify',
                                  style: TextStyle(color: Colors.white),
                                )
                              : const CircularProgressIndicator.adaptive(
                                  backgroundColor: Colors.white,
                                ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
