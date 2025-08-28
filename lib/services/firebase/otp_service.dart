import 'package:firebase_auth/firebase_auth.dart';

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
  Future<UserCredential> verifyOTP({
    required String smsCode,
  }) async {
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

    return await _auth.signInWithCredential(credential);
  }
}
