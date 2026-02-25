import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon_tv/main.dart';
import 'package:sermon_tv/reusable/app_dialogs.dart';
import 'package:sermon_tv/reusable/payment_in_progress_page.dart';
import 'package:sermon_tv/network/endpoints.dart';
import 'package:sermon_tv/services/firebase/models/user_models.dart';
import 'package:sermon_tv/services/firebase/user_data_management/firestore_functions.dart';
import 'package:sermon_tv/services/firebase/utils_management/utils_functions.dart';
import 'package:sermon_tv/services/hive_box/hive_box_functions.dart';
import 'package:sermon_tv/services/log_service/log_service.dart';
import 'package:sermon_tv/services/log_service/log_variables.dart';
import 'package:sermon_tv/services/plan_service/models/CreateCustomerResponseModel.dart';
import 'package:sermon_tv/services/plan_service/plan_purchase_state.dart';
import 'package:sermon_tv/services/razorpay_service.dart';
import 'package:sermon_tv/services/firebase/firebase_remote_config.dart';
import 'package:sermon_tv/reusable/logger_service.dart';

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
      return isDebugMode()
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
    FirebaseUser? firebaseUser = HiveBoxFunctions().getLoginDetails();
    String? subscriptionId = firebaseUser?.subscriptionId;

    if (subscriptionId == null ||
        subscriptionId.trim() == '' ||
        subscriptionId.contains('no subscriptions')) {
      String? newSubscriptionId = await createSubscriptionId(context: context);
      if (newSubscriptionId == null) {
        emit(state.copyWith(loading: false));
        return;
      }
      subscriptionId = newSubscriptionId;
      await FirestoreFunctions().updateOrSaveSubscriptionIdFirestoreData(
        subscriptionId: subscriptionId,
      );
    }

    // subscription listening is handled by PaymentInProgressPage

    if (subscriptionId.trim() == '' ||
        subscriptionId.contains('no subscriptions')) {
      emit(state.copyWith(loading: false));
      AppLogger.e('Subscription API not working properly');
      throw Exception("Subscription API not working properly");
    }

    emit(state.copyWith(loading: false));

    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (builder) =>
            PaymentInProgressPage(subscriptionId: subscriptionId!),
      ),
    );
    final remoteConfigService = FirebaseRemoteConfigService();
    RazorpayService().openCheckout(
      apiKey: isDebugMode()
          ? remoteConfigService.razorpayTestApiKey
          : remoteConfigService.razorpayLiveApiKey,
      subscriptionId: subscriptionId,
      onSuccess: () async {
        UtilsFunctions().setRechargeTrue();
      },
    );
  }

  Future<String?> createSubscriptionId({required BuildContext context}) async {
    try {
      RazorpayCustomerResponse? razorpayCustomerResponse = await createPlan();
      if (razorpayCustomerResponse == null) {
        emit(state.copyWith(loading: false));
        return null;
      }

      AppLogger.e('${razorpayCustomerResponse.toJson()}');

      final data = await Future.wait([
        createSubscription(
          providedRazorpayCustomerResponse: razorpayCustomerResponse,
        ),
        MyAppAmplitudeAndFirebaseAnalitics().logEvent(
          event: LogEventsName.instance().subscribeNowButtonTap,
        ),
      ]);
      AppLogger.e(data.toString());
      return data[0] as String;
    } catch (e) {
      MyAppDialogs().info_dialog(
        context: context,
        title: 'Error',
        body: "Error while creating Subscription",
      );
    }
    return null;
  }
}
