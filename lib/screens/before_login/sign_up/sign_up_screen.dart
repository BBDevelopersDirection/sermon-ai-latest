import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/screens/before_login/login_forgot_signup_state.dart';
import 'package:sermon/services/token_check_service/login_check_cubit.dart';

import '../../../reusable/MyAppElevatedButton.dart';
import '../../../reusable/my_scaffold_widget.dart';
import '../../../reusable/text_field_with_head.dart';
import '../login_forgot_signup_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController mobile_num;
  @override
  void initState() {
    mobile_num = TextEditingController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginForgotSignupCubit>().verifyViaTruecaller(context);
    });
  }

  @override
  void dispose() {
    // mobile_num.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return MyScaffold(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(16, 15, 22, 1),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your phone number',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We will send you a verification code.',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 24),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: mobile_num,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(
                      10,
                    ), // Limit to 10 characters
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: Color.fromRGBO(41, 41, 56, 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child:
                      BlocBuilder<
                        LoginForgotSignupCubit,
                        LoginForgotSignupState
                      >(
                        builder: (context, state) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1F20D6),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (state.loadingStatus ==
                                  LoadingStatus.phoneNumberLoading) {
                                return; // Prevent multiple taps
                              }
                              context
                                  .read<LoginForgotSignupCubit>()
                                  .send_to_otp_screen(
                                    context: context,
                                    controller: mobile_num,
                                  );
                              // context
                              //   .read<LoginForgotSignupCubit>()
                              //   .otp_ver_screen(
                              //     isSubmit: true,
                              //     context: context,
                              //     controller: mobile_num,
                              //     number: mobile_num.text,
                              //   );
                            },
                            child:
                                state.loadingStatus !=
                                    LoadingStatus.phoneNumberLoading
                                ? Text(
                                    'Get verification code',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : const CircularProgressIndicator.adaptive(
                                    backgroundColor: Colors.white,
                                  ),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 24),
                // Center(
                //   child: const Text(
                //     'Or',
                //     style: TextStyle(color: Colors.white, fontSize: 24),
                //   ),
                // ),
                // const SizedBox(height: 24),
                // SizedBox(
                //   width: double.infinity,

                //   child: OutlinedButton(
                //     style: OutlinedButton.styleFrom(
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //       side: const BorderSide(color: Color(0xFF1F20D6)),
                //     ),
                //     onPressed: () {
                //       context
                //           .read<LoginForgotSignupCubit>()
                //           .verifyViaTruecaller(context);
                //     },
                //     child: const Text(
                //       'Verify via Truecaller',
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        bottomSheet: isKeyboardOpen ? null : buildBottomSheet(),
      ),
    );
  }

  Widget buildBottomSheet() {
    return Container(
      color: const Color.fromRGBO(16, 15, 22, 1),
      padding: const EdgeInsets.all(8),
      child: const AutoSizeText(
        '*Note: For your safety, a reCAPTCHA will open in your browser—don’t worry, you’ll be back in a moment.',
        maxLines: 1,
        minFontSize: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color.fromRGBO(238, 210, 2, 1),
        ),
      ),
    );
  }
}
