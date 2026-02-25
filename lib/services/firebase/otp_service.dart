import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sermon_tv/reusable/app_dialogs.dart';
import 'package:sermon_tv/services/log_service/log_variables.dart';

class OTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  /// Sends OTP to the given phone number.
  Future<void> sendOTP({
    required String phoneNumber,
    required void Function() onCodeSent,
    required void Function(UserCredential credential) onVerificationCompleted,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function() onAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Called if verification is completed automatically (on some Android devices)
        final result = await _auth.signInWithCredential(credential);
        onVerificationCompleted(result);
      },
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        onAutoRetrievalTimeout();
      },
    );
  }

  /// Verifies the OTP entered by the user
  Future<UserCredential> verifyOTP({required String smsCode}) async {
    if (_verificationId == null) {
      throw FirebaseAuthException(
        code: 'verification-id-null',
        message: 'Verification ID is null. Please request OTP first.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    return userCredential;
  }

  FirebaseOtpException handleFirebaseOtpError({
    required FirebaseAuthException e,
    required BuildContext context,
  }) {
    String message = "Something went wrong. Please try again.";
    bool isNavigateToLogin = false;
    String? eventLog;

    switch (e.code) {
      case 'invalid-verification-code':
        message = "Invalid OTP. Please try again.";
        eventLog = LogEventsName.instance().invalidVerificationCode;
        break;

      case 'session-expired':
        message = "OTP has expired. Please request a new one.";
        isNavigateToLogin = true;
        eventLog = LogEventsName.instance().sessionExpired;
        break;

      case 'too-many-requests':
        message =
            "You have requested OTP too many times. Please try again later.";
        isNavigateToLogin = true;
        eventLog = LogEventsName.instance().tooManyRequests;
        break;

      case 'invalid-phone-number':
        message = "The phone number entered is invalid.";
        isNavigateToLogin = true;
        break;

      case 'quota-exceeded':
        message = "SMS quota exceeded. Please try again later.";
        isNavigateToLogin = true;
        eventLog = LogEventsName.instance().quotaExceeded;
        break;

      case 'network-request-failed':
        message = "Network error. Please check your internet connection.";
        isNavigateToLogin = true;
        break;

      case 'app-not-authorized':
        message = "App is not authorized. Please contact support.";
        isNavigateToLogin = true;
        break;

      case 'captcha-check-failed':
        message = "Captcha verification failed. Please try again.";
        isNavigateToLogin = true;
        break;

      default:
        message = e.message ?? message;
    }

    return FirebaseOtpException(
      message: message,
      isNavigateToLogin: isNavigateToLogin,
      eventLog: eventLog,
    );
  }
}

class FirebaseOtpException {
  final String message;
  final bool isNavigateToLogin;
  final String? eventLog;

  FirebaseOtpException({
    required this.message,
    required this.isNavigateToLogin,
    this.eventLog,
  });
}
