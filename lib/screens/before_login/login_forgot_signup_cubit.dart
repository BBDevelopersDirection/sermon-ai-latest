import 'dart:async';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/screens/before_login/login_forgot_signup_state.dart';
import 'package:sermon/screens/before_login/sign_up/sign_up_third_screen.dart';
import 'package:sermon/services/firebase/firestore_variables.dart';
import 'package:sermon/services/firebase/models/utility_model.dart';
import 'package:sermon/services/firebase/user_data_management/firestore_functions.dart';
import 'package:sermon/services/firebase/models/user_models.dart';
import 'package:sermon/services/firebase/utils_management/utils_functions.dart';
import 'package:sermon/services/firebase_notification_mine.dart';
import 'package:sermon/services/hive_box/hive_box_variables.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart';
import '../../reusable/app_dialogs.dart';
import '../../services/firebase/otp_service.dart';
import '../../services/hive_box/hive_box_functions.dart';
import '../../services/log_service/log_service.dart';
import '../../services/log_service/log_variables.dart';
import '../../services/shared_pref/shared_preference.dart';
import '../../services/token_check_service/login_check_screen.dart';
import 'sign_up/sign_up_second.dart';

class LoginForgotSignupCubit extends Cubit<LoginForgotSignupState> {
  LoginForgotSignupCubit()
    : super(LoginForgotSignupState(loadingStatus: LoadingStatus.noLoading));

  final OTPService otpService = OTPService();
  StreamSubscription? _streamSubscription;
  String? _codeVerifier;

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }

  void send_to_otp_screen({
    required BuildContext context,
    required TextEditingController controller,
  }) {
    String unverifiedMobNum = controller.text.toString();

    final RegExp mobileRegex = RegExp(r'^[6-9]\d{9}$');

    if (!mobileRegex.hasMatch(unverifiedMobNum)) {
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().phoneNumberIncorrectEntry,
      );
      MyAppDialogs().info_dialog(
        context: context,
        title: 'Failed',
        body: 'Please Enter 10 Digit Valid Number.',
      );
      return;
    } else {
      emit(state.copyWith(loadingStatus: LoadingStatus.phoneNumberLoading));
      // 1. Send OTP
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().phoneNumberCorrectEntry,
      );
      otpService.sendOTP(
        phoneNumber: "+91${controller.text}",
        onCodeSent: () {
          emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: this,
                child: SignUpSecondScreen(number: unverifiedMobNum),
              ),
            ),
          );
        },
        onVerificationCompleted: (credential) {
          emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));
          print("Auto-verification completed. User signed in.");
        },
        onVerificationFailed: (e) {
          emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));
          print("Verification failed: ${e.message}");
        },
        onAutoRetrievalTimeout: () {
          emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));
          print("OTP auto retrieval timeout.");
        },
      );
      // Show an error message or handle invalid input
    }
  }

  Future<void> otp_ver_screen({
    required BuildContext context,
    isSubmit = false,
    required String number,
    required TextEditingController controller,
  }) async {
    String unverifiedOtp = controller.text.toString();

    print(unverifiedOtp.length);

    if (unverifiedOtp.length != 6) {
      // never reach here
      return;
    } else {
      try {
        emit(state.copyWith(loadingStatus: LoadingStatus.otpLoading));
        final result = await otpService.verifyOTP(smsCode: controller.text);
        emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));

        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          // If user is null, it means the verification failed
          emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));
          throw FirebaseAuthException(
            code: 'user-null',
            message: 'User is null after OTP verification.',
          );
        }

        FirestoreFunctions()
            .getFirebaseUser(
              userId:
                  FirebaseAuth.instance.currentUser?.uid ??
                  HiveBoxFunctions().getUuid(),
            )
            .then((value) async {
              if (value == null) {
                // If user data is null, create a new user
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: this,
                      child: SignUpThirdScreen(number: number),
                    ),
                  ),
                );
                return;
              }
              Future.wait([
                MyAppAmplitudeAndFirebaseAnalitics().logEvent(
                  event: LogEventsName.instance().otpEntryCorrect,
                ),
                HiveBoxFunctions().saveLoginDetails(
                  FirebaseUser(
                    uid: value.uid,
                    phoneNumber: value.phoneNumber,
                    name: value.name,
                    email: value.email,
                  ),
                ),
                NotificationService.instance.requestPermissionAndGetToken(),
              ]);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginCheckScreen()),
                (route) => false,
              );
            });
      } catch (e) {
        // print("OTP verification failed: $e");
        emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));
        MyAppDialogs().info_dialog(
          context: context,
          title: 'Failed',
          body: e.toString().contains('verification-id-null')
              ? 'Please request OTP first.'
              : 'Invalid OTP. Please try again.',
        );
        MyAppAmplitudeAndFirebaseAnalitics().logEvent(
          event: LogEventsName.instance().otpEntryIncorrect,
        );
      }
    }
  }

  void showTruecallerLogin({required BuildContext context}) {
    TcSdk.initializeSDK(sdkOption: TcSdkOptions.OPTION_VERIFY_ONLY_TC_USERS);

    TcSdk.isOAuthFlowUsable.then((isOAuthFlowUsable) {
      if (isOAuthFlowUsable) {
        final state = Uuid().v1();
        TcSdk.setOAuthState(state);
        TcSdk.setOAuthScopes(['profile', 'phone', 'openid', 'offline_access']);

        TcSdk.generateRandomCodeVerifier.then((codeVerifier) {
          TcSdk.generateCodeChallenge(codeVerifier).then((codeChallenge) {
            if (codeChallenge != null) {
              // Save this codeVerifier to use later when you receive the OAuth result
              // (either in a global variable, in state, or as argument)
              TcSdk.setCodeChallenge(codeChallenge);

              /// ✅ Finally trigger the login box here
              TcSdk.getAuthorizationCode();
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Device not supported")));
            }
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Truecaller OAuth not usable on this device")),
        );
      }
    });
  }

  void verifyViaTruecaller(BuildContext context) async {
    try {
      // Step 1: Initialize SDK (⚠️ this mode does NOT return profile)
      TcSdk.initializeSDK(
        sdkOption: TcSdkOptions.OPTION_VERIFY_ONLY_TC_USERS,
        consentHeadingOption: TcSdkOptions.SDK_CONSENT_HEADING_LOG_IN_TO,
        footerType: TcSdkOptions.FOOTER_TYPE_SKIP,
        ctaText: TcSdkOptions.CTA_TEXT_ACCEPT,
        buttonShapeOption: TcSdkOptions.BUTTON_SHAPE_RECTANGLE,
        buttonColor: 0xFF1F20D6,
        buttonTextColor: 0xFFFFFFFF,
      );

      // Step 2: Check if OAuth flow is usable
      bool isUsable = await TcSdk.isOAuthFlowUsable;

      if (!isUsable) {
        print('⚠️ OAuth flow not usable');
        return;
      }

      // Step 3: Setup OAuth state, scopes, code verifier/challenge
      const oAuthState = "voiceclub.app";
      TcSdk.setOAuthState(oAuthState);
      TcSdk.setOAuthScopes([
        'profile',
        'phone',
        'email',
        'openid',
        'offline_access',
      ]);

      _streamSubscription?.cancel();
      _codeVerifier = await TcSdk.generateRandomCodeVerifier;
      if (_codeVerifier == null) {
        print('❌ Failed to generate code verifier');
        return;
      }

      final codeChallenge = await TcSdk.generateCodeChallenge(_codeVerifier!);
      if (codeChallenge == null) {
        print('❌ Code challenge NULL. Device not supported');
        return;
      }

      TcSdk.setCodeChallenge(codeChallenge);

      // Step 4: Start listening before requesting authorization code
      _streamSubscription = TcSdk.streamCallbackData.listen(
        (tcSdkCallback) async {
          switch (tcSdkCallback.result) {
            case TcSdkCallbackResult.success:
              final tcOAuthData = tcSdkCallback.tcOAuthData!;
              final authCode = tcOAuthData.authorizationCode;
              final stateReceived = tcOAuthData.state;

              if (stateReceived == oAuthState &&
                  _codeVerifier != null &&
                  _codeVerifier!.isNotEmpty &&
                  authCode.isNotEmpty) {
                print('✅ Auth Code: $authCode');
                print('🔐 Code Verifier: $_codeVerifier');
                print("🔄 Requesting access token 1...");
                getData(authCode: authCode);
                print(
                  '⚠️ Note: Profile will be null in OPTION_VERIFY_ALL_USERS',
                );
              }
              break;

            case TcSdkCallbackResult.verifiedBefore:
              final tcOAuthData = tcSdkCallback.tcOAuthData!;
              final authCode = tcOAuthData.authorizationCode;
              final stateReceived = tcOAuthData.state;

              if (stateReceived == oAuthState &&
                  _codeVerifier != null &&
                  _codeVerifier!.isNotEmpty &&
                  authCode.isNotEmpty) {
                print('✅ Auth Code: $authCode');
                print('🔐 Code Verifier: $_codeVerifier');
                print("🔄 Requesting access token 2...");
                getData(authCode: authCode);
                print(
                  '⚠️ Note: Profile will be null in OPTION_VERIFY_ALL_USERS',
                );
              }
              break;

            case TcSdkCallbackResult.failure:
              final error = tcSdkCallback.error!;
              print(
                '❌ ErrorCode: ${error.code}, Reason: ${error.message ?? "Unknown"}',
              );
              break;

            case TcSdkCallbackResult.verification:
              // Not expected with OPTION_VERIFY_ALL_USERS
              break;

            default:
              print('❌ Invalid callback result');
          }
        },
        onError: (e) {
          print('❌ SDK Error: $e');
        },
      );

      // Step 5: Request authorization code (⚠️ this is a method call, not a property)
      // Attempting to isolate the call to prevent NoSuchMethodError
      await Future.value(TcSdk.getAuthorizationCode());
    } catch (e) {
      print('❌ Exception: $e');
    }
  }

  Future<void> getData({required String authCode}) async {
    final dio = Dio();
    try {
      if (_codeVerifier == null || _codeVerifier!.isEmpty) {
        print('❌ Stored Code Verifier is missing!');
        return;
      }
      print("🔄 Requesting access token...");

      final tokenResponse = await dio.post(
        'https://oauth-account-noneu.truecaller.com/v1/token',
        data: {
          'grant_type': 'authorization_code',
          'client_id': 'geccxmob7lmixsk6unz06-wwb91d9wksd8il0hmc-5i',
          'code': authCode,
          'code_verifier': _codeVerifier,
          // Optional: 'redirect_uri': 'your.registered.uri',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      print("✅ Token Response: ${tokenResponse.data}");

      final accessToken = tokenResponse.data['access_token'];
      if (accessToken == null || accessToken.isEmpty) {
        print("❗ Access token not found.");
        return;
      }

      print("🔐 Access Token: $accessToken");
      print("📡 Requesting user info...");

      final profileResponse = await dio.get(
        'https://oauth-account-noneu.truecaller.com/v1/userinfo',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final profile = profileResponse.data;
      print("👤 Full User Profile: $profile");

      final fullName =
          '${profile['given_name'] ?? ''} ${profile['family_name'] ?? ''}'
              .trim();
      final phone = profile['phone_number'] ?? 'Not Available';
      final email = profile['email'] ?? 'Not Available';

      if (phone == 'Not Available') {
        throw Exception('Phone number not available from Truecaller');
      }

      print("✅ Name: $fullName");
      print("📞 Phone: $phone");
      print("📧 Email: $email");

      // in phone number add + in front of the phone number
      final phoneNumber = '+$phone';

      // First, check if user exists in Firestore by phone number
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirestoreVariables.usersCollection)
          .where(FirestoreVariables.phoneField, isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint("👤 User exists in Firestore");
        final userData = querySnapshot.docs.first.data();
        final existingUser = FirebaseUser.fromJson(userData);

        var data = FirebaseUser(
          uid: userData[FirestoreVariables.userIdField],
          email: userData[FirestoreVariables.emailField],
          phoneNumber: userData[FirestoreVariables.phoneField],
          name: userData[FirestoreVariables.nameField],
        );

        print("👤 Existing User: $data");
        // Save login details to Hive
        await HiveBoxFunctions().saveLoginDetails(data);

        // Navigate to login check screen
        Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginCheckScreen()),
          (route) => false,
        );
      } else {
        // User doesn't exist - proceed with registration
        debugPrint("👤 User doesn't exist - proceeding with registration");
        userRegistrationSignUpButton(
          context: navigatorKey.currentContext!,
          name: fullName,
          unverifiedMobNum: phoneNumber,
          email: email,
          isTruecaller: true,
        );
      }
    } on DioException catch (e) {
      print("❌ Dio error: ${e.response?.data ?? e.message}");
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  void userRegistrationSignUpButton({
    required BuildContext context,
    required String name,
    required String unverifiedMobNum,
    required String email,
    bool isTruecaller = false,
  }) {
    // this block will pass if email is empty and if nort empty then it will validate email and also name
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Name is required.')));
      return;
    } else if (email.isEmpty || EmailValidator.validate(email)) {
      // Email is either empty or valid — and name is not empty

      debugPrint('proceeding with registration');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email or leave it blank.'),
        ),
      );
      return;
    }

    emit(state.copyWith(loadingStatus: LoadingStatus.userRegestrationLoading));

    print('👤 name: $name');
    print('👤 email: $email');
    print('👤 unverifiedMobNum: $unverifiedMobNum');
    print('👤 isTruecaller: $isTruecaller');
    print('👤 uid: ${FirebaseAuth.instance.currentUser?.uid}');
    print('👤 uuid: ${HiveBoxFunctions().getUuid()}');

    // if truecaller is true then get uuid by phone number
    String? uuid;
    if (isTruecaller) {
      uuid = HiveBoxFunctions().getUuidByPhone(phoneNumber: unverifiedMobNum);
      print('👤 uuid: $uuid');
    }

    FirestoreFunctions()
        .newFirebaseUserData(
          firebaseUser: FirebaseUser(
            uid:
                uuid ??
                FirebaseAuth.instance.currentUser?.uid ??
                HiveBoxFunctions().getUuid(),
            phoneNumber: isTruecaller
                ? unverifiedMobNum
                : "+91$unverifiedMobNum",
            name: name,
            email: email.isNotEmpty ? email : '',
          ),
        )
        .then((value) async {
          Future.wait([
            MyAppAmplitudeAndFirebaseAnalitics().logEvent(
              event: LogEventsName.instance().regestrationName,
            ),
            MyAppAmplitudeAndFirebaseAnalitics().logEvent(
              event: LogEventsName.instance().regestredUser,
            ),
            UtilsFunctions().createFirebaseUtilityData(
              utilityModel: UtilityModel(
                userId: isTruecaller
                    ? HiveBoxFunctions().getUuidByPhone(
                        phoneNumber: unverifiedMobNum,
                      )
                    : FirebaseAuth.instance.currentUser!.uid,
                totalVideoCount: 0,
                isRecharged: false,
                videoCountToCheckSub: 0,
              ),
            ),
            if (email.isNotEmpty)
              MyAppAmplitudeAndFirebaseAnalitics().logEvent(
                event: LogEventsName.instance().regestrationEmail,
              ),
            HiveBoxFunctions().saveLoginDetails(
              FirebaseUser(
                uid: isTruecaller
                    ? HiveBoxFunctions().getUuidByPhone(
                        phoneNumber: unverifiedMobNum,
                      )
                    : FirebaseAuth.instance.currentUser!.uid,
                phoneNumber: isTruecaller
                    ? unverifiedMobNum
                    : "+91$unverifiedMobNum",
                name: name,
                email: email.isNotEmpty ? email : '',
              ),
            ),
          ]);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginCheckScreen()),
            (route) => false,
          );
        })
        .catchError((error) {
          emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));
          MyAppDialogs().info_dialog(
            context: context,
            title: 'Failed',
            body: error.toString(),
          );
        });
  }
}
