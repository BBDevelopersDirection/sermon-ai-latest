import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/reusable/payment_in_progress_page.dart';
import 'package:sermon/network/endpoints.dart';
import 'package:sermon/services/firebase/models/user_models.dart';
import 'package:sermon/services/firebase/utils_management/utils_functions.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:sermon/services/log_service/log_service.dart';
import 'package:sermon/services/log_service/log_variables.dart';
import 'package:sermon/services/plan_service/models/CreateCustomerResponseModel.dart';
import 'package:sermon/services/plan_service/plan_purchase_state.dart';
import 'package:sermon/services/razorpay_service.dart';
import 'package:sermon/services/token_check_service/login_check_cubit.dart';
import 'package:sermon/reusable/logger_service.dart';

class PlanPurchaseCubit extends Cubit<PlanPurchaseState> {
  PlanPurchaseCubit()
    : super(
        PlanPurchaseState(
          loading: false,
          errorCode: planPurchaseErrorCode.noError,
        ),
      );

  Future<RazorpayCustomerResponse?> createPlan() async {
    FirebaseUser? firebaseUser = HiveBoxFunctions().getLoginDetails();

    if (firebaseUser == null) {
      emit(
        state.copyWith(errorCode: planPurchaseErrorCode.firebaseUserNotFound),
      );
      return null;
    }

    try {
      Response response = await MyAppEndpoints.instance().createCustomer(
        firebaseUser: firebaseUser,
      );
      AppLogger.d("response data: ${response.data}");
      RazorpayCustomerResponse razorpayCustomerResponse =
          RazorpayCustomerResponse.fromJson(response.data);
      return razorpayCustomerResponse;
    } catch (e) {
      emit(state.copyWith(errorCode: planPurchaseErrorCode.customerApiError));
      return null;
    }
  }

  Future<String?> createSubscription({
    required RazorpayCustomerResponse providedRazorpayCustomerResponse,
  }) async {
    FirebaseUser? firebaseUser = HiveBoxFunctions().getLoginDetails();

    if (firebaseUser == null) {
      emit(
        state.copyWith(errorCode: planPurchaseErrorCode.firebaseUserNotFound),
      );
      return null;
    }
    try {
      Response response = await MyAppEndpoints.instance().createSubscription(
        razorpayCustomerResponse: providedRazorpayCustomerResponse,
      );
      return kDebugMode
          ? response.data['subscription']['id']
          : response.data['subscription']['id'];
    } catch (e) {
      emit(
        state.copyWith(
          errorCode: planPurchaseErrorCode.createSubscriptionApiError,
        ),
      );
      return null;
    }
  }

  Future<void> rechargeNowCallBack({required BuildContext context}) async {
    emit(state.copyWith(loading: true));
    RazorpayCustomerResponse? razorpayCustomerResponse = await createPlan();
    if (razorpayCustomerResponse == null) {
      emit(state.copyWith(loading: false));
      return;
    }

    String? subscriptionId;
    final data = await Future.wait([
      createSubscription(
        providedRazorpayCustomerResponse: razorpayCustomerResponse,
      ),
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().subscribeNowButtonTap,
      ),
    ]);

    subscriptionId = data[0] as String;

    // subscription listening is handled by PaymentInProgressPage

    if (subscriptionId == null) {
      emit(state.copyWith(loading: false));
      return;
    }

    emit(state.copyWith(loading: false));

    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (builder) =>
            PaymentInProgressPage(subscriptionId: subscriptionId!),
      ),
    );
    RazorpayService().openCheckout(
      apiKey: kDebugMode
          ? 'rzp_test_zFue9vNxhSABQ6'
          : 'rzp_live_d5McFTkC2w2nZd',
      subscriptionId: subscriptionId,
      onSuccess: () async {
        UtilsFunctions().setRechargeTrue();
      },
    );
  }
}
