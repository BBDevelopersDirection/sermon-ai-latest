import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/screens/before_login/login_forgot_signup_state.dart';
import 'package:sermon/services/plan_service/widgets/trial_image_row.dart';
import 'package:sermon/utils/app_assets.dart';

import '../../../reusable/my_scaffold_widget.dart';
import '../login_forgot_signup_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController mobile_num;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _mobileFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    mobile_num = TextEditingController();
    context.read<LoginForgotSignupCubit>().logLoginPageAppearEvent();
    mobile_num.addListener(() {
      if (mobile_num.text.length >= 10) {
        // Dismiss the keyboard
        FocusScope.of(context).unfocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<LoginForgotSignupCubit>().send_to_otp_screen(
            context: context,
            controller: mobile_num,
          );
          // context
          //                         .read<LoginForgotSignupCubit>()
          //                         .userRegisteration(
          //                           phoneNumber: "+91${mobile_num.text}",
          //                           fullName: '',
          //                           email: '',
          //                         );
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginForgotSignupCubit>().verifyViaTruecaller(context);
    });
  }

  @override
  void dispose() {
    mobile_num.dispose();
    _scrollController.dispose();
    _mobileFocus.dispose();
    super.dispose();
  }

  void _scrollToField() {
    // Delay to make sure keyboard is fully opened
    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return MyScaffold(
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: loginBody(),
        bottomSheet: isKeyboardOpen ? null : buildBottomSheet(),
      ),
    );
  }

  Widget loginBody(){
    return SingleChildScrollView(
              controller: _scrollController,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Your TrialImageRows, texts, etc
                    TrialImageRow(
                      IsForLogin: true,
                      imagePaths: [
                        MyAppAssets.jpg_login_image_1,
                        MyAppAssets.png_login_image_2,
                        MyAppAssets.png_login_image_3,
                      ],
                    ),
                    SizedBox(height: 25),
                    TrialImageRow(
                      IsForLogin: true,
                      imagePaths: [
                        MyAppAssets.png_login_image_4,
                        MyAppAssets.png_login_image_5,
                        MyAppAssets.png_login_image_6,
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome to SermonTV',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontFamily: 'Epilogue',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextField(
                        focusNode: _mobileFocus,
                        style: const TextStyle(color: Colors.black),
                        controller: mobile_num,
                        keyboardType: TextInputType.phone,
                        onTap: () => context
                            .read<LoginForgotSignupCubit>()
                            .showPhoneSelector(
                              context: context,
                              mobile_num: mobile_num,
                            ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter your phone number',
                          hintStyle: const TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: Colors.white,
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
                    ),
                    SizedBox(height: 20),
                    // Your BlocBuilder ElevatedButton and spacing
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width - 50,
                      child:
                          BlocBuilder<
                            LoginForgotSignupCubit,
                            LoginForgotSignupState
                          >(
                            builder: (context, state) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFD89118),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                },
                                child:
                                    state.loadingStatus !=
                                        LoadingStatus.phoneNumberLoading
                                    ? Text(
                                        'Next',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : const CircularProgressIndicator.adaptive(
                                        backgroundColor: Colors.white,
                                      ),
                              );
                            },
                          ),
                    ),
                    SizedBox(height: 70),
                  ],
                ),
              ),
            );
  }

  Widget buildBottomSheet() {
    return Container(
      color: const Color.fromRGBO(16, 15, 22, 1),
      padding: EdgeInsets.only(
        top: 8,
        right: 8,
        left: 8,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
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
