import 'dart:async';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:sermon/reusable/logger_service.dart';

import '../../main.dart';
import '../../reusable/app_dialogs.dart';
import '../../services/firebase/otp_service.dart';
import '../../services/firebase/firebase_remote_config.dart';
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

  void logLoginPageAppearEvent() {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().loginScreenOpen,
    );
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
          AppLogger.d("Auto-verification completed. User signed in.");
        },
        onVerificationFailed: (e) {
          emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));
          MyAppDialogs().info_dialog(
            context: context,
            title: "Error",
            body: '${e.message}',
          );
          AppLogger.e("Verification failed: ${e.message}");
        },
        onAutoRetrievalTimeout: () {
          emit(state.copyWith(loadingStatus: LoadingStatus.noLoading));
          MyAppDialogs().info_dialog(
            context: context,
            title: "Sorry",
            body: 'OTP auto retrieval timeout.',
          );
          AppLogger.d("OTP auto retrieval timeout.");
        },
      );
      // Show an error message or handle invalid input
    }
  }

  Future<void> showPhoneSelector({
    required BuildContext context,
    required TextEditingController mobile_num,
  }) async {
    if (await Permission.phone.request().isGranted) {
      List<String> numbers = [];

      try {
        String? mainNumber = await MobileNumber.mobileNumber;
        List<SimCard>? sims = await MobileNumber.getSimCards;

        if (mainNumber != null) numbers.add(mainNumber);
        if (sims != null) {
          for (final sim in sims) {
            if (sim.number != null && sim.number!.isNotEmpty) {
              numbers.add(sim.number!);
            }
          }
        }
      } catch (e) {
        AppLogger.e("Error reading numbers: $e");
      }

      /// Keep only last 10 digits
      numbers = numbers.map((n) {
        String digits = n.replaceAll(RegExp(r'\D'), '');
        return digits.length >= 10
            ? digits.substring(digits.length - 10)
            : digits;
      }).toList();

      /// Remove duplicates
      numbers = numbers.toSet().toList();

      if (numbers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No phone numbers found. Enter manually."),
          ),
        );
        return;
      }

      MyAppDialogs().phoneNumberDialog(
        context: context,
        numbers: numbers,
        onNumberSelected: (selectedNumber) {
          mobile_num.text = selectedNumber;
        },
      );
    } else {
      // openAppSettings();
    }
  }

  Future<void> otp_ver_screen({
    required BuildContext context,
    isSubmit = false,
    required String number,
    required TextEditingController controller,
  }) async {
    String unverifiedOtp = controller.text.toString();

    AppLogger.d(unverifiedOtp.length.toString());

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
        FirestoreFunctions().getFirebaseUserByNumber(number: number).then((
          value,
        ) async {
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
          await FirestoreFunctions().ensureCreatedDateExists(userId: value.uid);
          Future.wait([
            MyAppAmplitudeAndFirebaseAnalitics().logEvent(
              event: LogEventsName.instance().loginFirebase,
            ),
            HiveBoxFunctions().saveLoginDetails(
              FirebaseUser(
                uid: value.uid,
                phoneNumber: value.phoneNumber,
                name: value.name,
                email: value.email,
                subscriptionId: value.subscriptionId,
                createdDate: value.createdDate,
              ),
            ),
            NotificationService.instance.requestPermissionAndGetToken(),
          ]);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  LoginCheckScreen(isLoginOrRegesterFlow: true),
            ),
            (route) => false,
          );
        });
      } catch (e) {
        // AppLogger.d("OTP verification failed: $e");
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
        AppLogger.w('⚠️ OAuth flow not usable');
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
        AppLogger.e('❌ Failed to generate code verifier');
        return;
      }

      final codeChallenge = await TcSdk.generateCodeChallenge(_codeVerifier!);
      if (codeChallenge == null) {
        AppLogger.e('❌ Code challenge NULL. Device not supported');
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
                AppLogger.d('✅ Auth Code: $authCode');
                AppLogger.d('🔐 Code Verifier: $_codeVerifier');
                AppLogger.d("🔄 Requesting access token 1...");
                getData(authCode: authCode);
                AppLogger.d(
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
                AppLogger.d('✅ Auth Code: $authCode');
                AppLogger.d('🔐 Code Verifier: $_codeVerifier');
                AppLogger.d("🔄 Requesting access token 2...");
                getData(authCode: authCode);
                AppLogger.d(
                  '⚠️ Note: Profile will be null in OPTION_VERIFY_ALL_USERS',
                );
              }
              break;

            case TcSdkCallbackResult.failure:
              final error = tcSdkCallback.error!;
              AppLogger.e(
                '❌ ErrorCode: ${error.code}, Reason: ${error.message ?? "Unknown"}',
              );
              break;

            case TcSdkCallbackResult.verification:
              // Not expected with OPTION_VERIFY_ALL_USERS
              break;

            default:
              AppLogger.e('❌ Invalid callback result');
          }
        },
        onError: (e) {
          AppLogger.e('❌ SDK Error: $e');
        },
      );

      // Step 5: Request authorization code (⚠️ this is a method call, not a property)
      // Attempting to isolate the call to prevent NoSuchMethodError
      await Future.value(TcSdk.getAuthorizationCode());
    } catch (e) {
      AppLogger.e('❌ Exception: $e');
    }
  }

  Future<void> getData({required String authCode}) async {
    final dio = Dio();
    try {
      if (_codeVerifier == null || _codeVerifier!.isEmpty) {
        AppLogger.e('❌ Stored Code Verifier is missing!');
        return;
      }
      AppLogger.d("🔄 Requesting access token...");

      final remoteConfig = FirebaseRemoteConfigService();
      final tokenResponse = await dio.post(
        remoteConfig.truecallerTokenEndpoint,
        data: {
          'grant_type': 'authorization_code',
          'client_id': remoteConfig.truecallerClientId,
          'code': authCode,
          'code_verifier': _codeVerifier,
          // Optional: 'redirect_uri': 'your.registered.uri',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      AppLogger.d("✅ Token Response: ${tokenResponse.data}");

      final accessToken = tokenResponse.data['access_token'];
      if (accessToken == null || accessToken.isEmpty) {
        AppLogger.w("❗ Access token not found.");
        return;
      }

      AppLogger.d("🔐 Access Token: $accessToken");
      AppLogger.d("📡 Requesting user info...");

      final profileResponse = await dio.get(
        remoteConfig.truecallerUserinfoEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final profile = profileResponse.data;
      AppLogger.d("👤 Full User Profile: $profile");

      final fullName =
          '${profile['given_name'] ?? ''} ${profile['family_name'] ?? ''}'
              .trim();
      final phone = profile['phone_number'] ?? 'Not Available';
      final email = profile['email'] ?? 'Not Available';

      if (phone == 'Not Available') {
        throw Exception('Phone number not available from Truecaller');
      }

      AppLogger.d("✅ Name: $fullName");
      AppLogger.d("📞 Phone: $phone");
      AppLogger.d("📧 Email: $email");

      // in phone number add + in front of the phone number
      final phoneNumber = '+$phone';
      userRegisteration(
        phoneNumber: phoneNumber,
        fullName: fullName.isNotEmpty ? fullName : 'No Name',
        email: email,
      );

      // First, check if user exists in Firestore by phone number
    } on DioException catch (e) {
      AppLogger.e("❌ Dio error: ${e.response?.data ?? e.message}");
    } catch (e) {
      AppLogger.e("❌ Error: $e");
    }
  }

  Future<void> userRegisteration({
    required String phoneNumber,
    required String fullName,
    required String email,
  }) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirestoreVariables.usersCollection)
        .where(FirestoreVariables.phoneField, isEqualTo: phoneNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      AppLogger.d("👤 User exists in Firestore");
      final userData = querySnapshot.docs.first.data();
      final existingUser = FirebaseUser.fromJson(userData);

      var data = FirebaseUser(
        uid: userData[FirestoreVariables.userIdField],
        email: userData[FirestoreVariables.emailField],
        phoneNumber: userData[FirestoreVariables.phoneField],
        name: userData[FirestoreVariables.nameField],
        subscriptionId: userData[FirestoreVariables.subscriptionIdField],
        createdDate: userData[FirestoreVariables.createdDateField] != null
            ? (userData[FirestoreVariables.createdDateField] is Timestamp
                  ? (userData[FirestoreVariables.createdDateField] as Timestamp)
                        .toDate()
                  : DateTime.tryParse(
                          userData[FirestoreVariables.createdDateField]
                              .toString(),
                        ) ??
                        DateTime.now())
            : DateTime.now(),
      );

      AppLogger.d("👤 Existing User: $data");
      await FirestoreFunctions().ensureCreatedDateExists(userId: data.uid);
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().loginTruecaller,
      );
      // Save login details to Hive
      await HiveBoxFunctions().saveLoginDetails(data);

      // Navigate to login check screen
      Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginCheckScreen(isLoginOrRegesterFlow: true),
        ),
        (route) => false,
      );
    } else {
      // User doesn't exist - proceed with registration
      AppLogger.d("👤 User doesn't exist - proceeding with registration");
      userRegistrationSignUpButton(
        context: navigatorKey.currentContext!,
        name: fullName,
        unverifiedMobNum: phoneNumber,
        email: email,
        isTruecaller: true,
      );
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

      AppLogger.d('proceeding with registration');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email or leave it blank.'),
        ),
      );
      return;
    }

    emit(state.copyWith(loadingStatus: LoadingStatus.userRegestrationLoading));

    AppLogger.d('👤 name: $name');
    AppLogger.d('👤 email: $email');
    AppLogger.d('👤 unverifiedMobNum: $unverifiedMobNum');
    AppLogger.d('👤 isTruecaller: $isTruecaller');
    AppLogger.d('👤 uid: ${FirebaseAuth.instance.currentUser?.uid}');
    AppLogger.d('👤 uuid: ${HiveBoxFunctions().getUuid()}');

    // if truecaller is true then get uuid by phone number
    String? uuid;
    if (isTruecaller) {
      uuid = HiveBoxFunctions().getUuidByPhone(phoneNumber: unverifiedMobNum);
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().registeredUserTruecaller,
      );
      AppLogger.d('👤 uuid: $uuid');
    } else {
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().registeredUserFirebase,
      );
    }

    if (!isTruecaller && email != '') {
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().registeredEmailTyped,
      );
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
            subscriptionId: null,
            createdDate:
                DateTime.now(), // Use current time, Firestore will override with serverTimestamp()
          ),
        )
        .then((value) async {
          Future.wait([
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
                is30DaysSubscriptionID: false,
              ),
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
                subscriptionId: null,
                createdDate: DateTime.now(),
              ),
            ),
          ]);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  LoginCheckScreen(isLoginOrRegesterFlow: true),
            ),
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
