import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/screens/before_login/login_forgot_signup_cubit.dart';
import 'package:sermon/screens/before_login/login_forgot_signup_state.dart';

import '../../../reusable/my_scaffold_widget.dart';

class SignUpThirdScreen extends StatefulWidget {
  String number;
  SignUpThirdScreen({super.key, required this.number});

  @override
  State<SignUpThirdScreen> createState() => _SignUpThirdScreenState();
}

class _SignUpThirdScreenState extends State<SignUpThirdScreen> {
  late TextEditingController name;
  // late TextEditingController email;

  @override
  void initState() {
    name = TextEditingController();
    // email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    name.dispose();
    // email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(16, 15, 22, 1),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: const Text(
                    'User Registration',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter following details, so we can create a personalized experience for you.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: name,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    // i want to allow alphabets only means a-z, A-Z and spaces also when put wrong correcter dont remove whole word
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: Color.fromRGBO(41, 41, 56, 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 24),
                // TextField(
                //   style: const TextStyle(color: Colors.white),
                //   controller: email,
                //   keyboardType: TextInputType.emailAddress,
                //   inputFormatters: [
                //     FilteringTextInputFormatter.allow(
                //       RegExp(r'[a-zA-Z0-9@._\-+]'),
                //     ),
                //   ],
                //   decoration: InputDecoration(
                //     hintText: 'Enter email (optional)',
                //     hintStyle: const TextStyle(color: Colors.white60),
                //     filled: true,
                //     fillColor: const Color.fromRGBO(41, 41, 56, 1),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: BorderSide.none,
                //     ),
                //     contentPadding: const EdgeInsets.symmetric(
                //         vertical: 16, horizontal: 16),
                //   ),
                // ),
                // const SizedBox(height: 24),
                SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<LoginForgotSignupCubit,
                        LoginForgotSignupState>(
                      builder: (context, state) {
                        return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(31, 32, 214, 1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (state.loadingStatus ==
                                  LoadingStatus.userRegestrationLoading) {
                                return;
                              }
                              context
                                  .read<LoginForgotSignupCubit>()
                                  .userRegistrationSignUpButton(
                                      context: context,
                                      name: name.text,
                                      // email: email.text,
                                      email: "",
                                      unverifiedMobNum: widget.number);
                            },
                            child: state.loadingStatus == LoadingStatus.noLoading
                                ? Text(
                              'Sign Up',
                              style: TextStyle(color: const Color(0xFFFFFFFF)),
                            )
                                : const CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white,
                            ),);
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
