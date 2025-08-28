import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sermon/services/firebase/models/transition_model.dart';
import 'package:sermon/services/firebase/transictions_management/transistion_function.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:uuid/uuid.dart';

import 'log_service/log_service.dart';
import 'log_service/log_variables.dart';

class RazorpayService {
  final Razorpay _razorpay = Razorpay();
  late double money;

  RazorpayService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  late Future<void> Function() _onSuccessCallback;

  void openCheckout({
    required String apiKey,
    // required int amount,
    required String subscriptionId,
    required Future<void> Function() onSuccess,
  }) {
    _onSuccessCallback = onSuccess;

    // money = amount.toDouble();

    // var options = {
    //   'key': apiKey,
    //   'subscription_id': subscriptionId,
    //   'amount': amount * 100, // in paise
    //   'name': "SermonTV",
    //   'description': "Recharge Plan Activation",
    //   'theme': {'color': '#1F20D6'},
    // };

    var options = {
      "key": apiKey,
      "subscription_id": subscriptionId,
      "recurring": true,
      'method': 'wallet',
      "name": "SermonTV",
      // "callback_url": kDebugMode? "https://asia-south1-sermon-ai-test.cloudfunctions.net/razorpayApi/test/webhook":"https://asia-south1-sermon-ai-test.cloudfunctions.net/razorpayApi/webhook",
      "description": 'Recharge Plan Activation',
      'theme': {'color': '#1F20D6'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("Payment Success: ${response.paymentId}");
    final String transactionId = response.paymentId ?? const Uuid().v4();

    TransistionFirestoreFunctions().newFirebaseTransitionData(
      firebaseTransition: TransactionModelFirebase(
        transactionId: transactionId,
        amount: money,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().add(Duration(days: 30)).toString(),
        userId:
            FirebaseAuth.instance.currentUser?.uid ??
            HiveBoxFunctions().getUuid(),
      ),
    );
    await _onSuccessCallback();
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    debugPrint("Payment Error: ${response.code} - ${response.message}");
    TransistionFirestoreFunctions().newFirebaseTransitionData(
      firebaseTransition: TransactionModelFirebase(
        transactionId: const Uuid().v4(),
        amount: -1,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().add(Duration(days: 30)).toString(),
        userId:
            FirebaseAuth.instance.currentUser?.uid ??
            HiveBoxFunctions().getUuid(),
      ),
    );
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().transistionFailEvent,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet selected: ${response.walletName}");
  }

  void dispose() {
    _razorpay.clear();
  }
}
