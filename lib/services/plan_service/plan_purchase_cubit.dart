import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/main.dart';
import 'package:sermon/reusable/payment_in_progress_page.dart';
import 'package:sermon/network/endpoints.dart';
import 'package:sermon/services/firebase/firestore_variables.dart';
import 'package:sermon/services/firebase/models/user_models.dart';
import 'package:sermon/services/firebase/models/utility_model.dart';
import 'package:sermon/services/firebase/user_data_management/firestore_functions.dart';
import 'package:sermon/services/firebase/utils_management/utils_functions.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:sermon/services/log_service/log_service.dart';
import 'package:sermon/services/log_service/log_variables.dart';
import 'package:sermon/services/plan_service/models/CreateCustomerResponseModel.dart';
import 'package:sermon/services/plan_service/plan_purchase_state.dart';
import 'package:sermon/services/razorpay_service.dart';
import 'package:sermon/reusable/logger_service.dart';

class PlanPurchaseCubit extends Cubit<PlanPurchaseState> {
  PlanPurchaseCubit()
    : super(
        PlanPurchaseState(
          errorCode: planPurchaseErrorCode.noError,
          LoadingFreeTrialNormal: loadingStates.buttonLoadingStop,
          subscriptionType: subscriptionTypes.subscriptionTypeLoading,
        ),
      );

  void checkSubscriptionType({required UtilityModel utilityModel}) async {
    if (conditionToCheckSubscriptionType(utilityModel: utilityModel)) {
      emit(
        state.copyWith(subscriptionTypes: subscriptionTypes.normalSubscription),
      );
    } else {
      emit(state.copyWith(subscriptionTypes: subscriptionTypes.freeTrial));
    }
  }

  bool conditionToCheckSubscriptionType({required UtilityModel utilityModel}) {
    bool retutnType = false;

    if (utilityModel.isFreeTrialOpted) {
      retutnType = true;
    } else {
      retutnType = false;
    }
    return retutnType;
  }

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

  Future<void> updateSubscriptionType() async {
    UtilityModel? utilityModel = await UtilsFunctions().getFirebaseUtility(
      userId:
          FirebaseAuth.instance.currentUser?.uid ??
          HiveBoxFunctions().getUuid(),
    );

    if (utilityModel == null) {
      emit(
        state.copyWith(errorCode: planPurchaseErrorCode.firebaseUserNotFound),
      );
      return;
    }

    if (utilityModel.isFreeTrialSubscription) {
      emit(state.copyWith(subscriptionTypes: subscriptionTypes.freeTrial));
    }else{
      emit(state.copyWith(subscriptionTypes: subscriptionTypes.normalSubscription));
    }
  }

  Future<String?> createSubscription({
    required RazorpayCustomerResponse providedRazorpayCustomerResponse,
    required bool isFreeTrialSubscription,
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
        isFreeTrialSubscription: isFreeTrialSubscription,
      );
      await UtilsFunctions().updateFirebaseUtilityData(
        fieldName: FirestoreVariables.isFreeTrialSubscription,
        newValue: isFreeTrialSubscription,
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
    emit(state.copyWith(LoadingFreeTrialNormal: loadingStates.buttonLoading));
    FirebaseUser? firebaseUser = HiveBoxFunctions().getLoginDetails();
    String? subscriptionId = firebaseUser?.subscriptionId;
    UtilityModel? utilityModel = await UtilsFunctions().getFirebaseUtility(
      userId:
          FirebaseAuth.instance.currentUser?.uid ??
          HiveBoxFunctions().getUuid(),
    );

    if (subscriptionId == null ||
        subscriptionId.trim() == '' ||
        subscriptionId.contains('no subscriptions')) {
      subscriptionId = await newSubscriptionCreationAndStoreCallback(
        utilityModel: utilityModel,
      );
    }
    // subscription listening is handled by PaymentInProgressPage

    if (subscriptionId == null ||
        subscriptionId.trim() == '' ||
        subscriptionId.contains('no subscriptions')) {
      emit(
        state.copyWith(LoadingFreeTrialNormal: loadingStates.buttonLoadingStop),
      );
      return;
    }

    emit(
      state.copyWith(LoadingFreeTrialNormal: loadingStates.buttonLoadingStop),
    );

    if (utilityModel?.isFreeTrialOpted ?? false) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(
          builder: (builder) => PaymentInProgressPage(
            subscriptionId: subscriptionId!,
            isFreeTrialCheck: false,
          ),
        ),
      );
    } else {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(
          builder: (builder) => PaymentInProgressPage(
            subscriptionId: subscriptionId!,
            isFreeTrialCheck: true,
          ),
        ),
      );
    }
    RazorpayService().openCheckout(
      apiKey: isDebugMode()
          ? 'rzp_test_zFue9vNxhSABQ6'
          : 'rzp_live_d5McFTkC2w2nZd',
      subscriptionId: subscriptionId,
      onSuccess: () async {
        // UtilsFunctions().setRechargeTrue();
      },
    );
  }

  Future<String?> newSubscriptionCreationAndStoreCallback({
    UtilityModel? utilityModel,
  }) async {
    if (utilityModel == null) {
      utilityModel = await UtilsFunctions().getFirebaseUtility(
        userId:
            FirebaseAuth.instance.currentUser?.uid ??
            HiveBoxFunctions().getUuid(),
      );

      bool isFreeTrialSubscription = false;

      if (utilityModel?.isFreeTrialOpted ?? false) {
        isFreeTrialSubscription = true;
      } else {
        isFreeTrialSubscription = false;
      }

      RazorpayCustomerResponse? razorpayCustomerResponse = await createPlan();
      if (razorpayCustomerResponse == null) {
        emit(
          state.copyWith(
            LoadingFreeTrialNormal: loadingStates.buttonLoadingStop,
          ),
        );
        return null;
      }

      final data = await Future.wait([
        createSubscription(
          providedRazorpayCustomerResponse: razorpayCustomerResponse,
          isFreeTrialSubscription: isFreeTrialSubscription,
        ),
        MyAppAmplitudeAndFirebaseAnalitics().logEvent(
          event: LogEventsName.instance().subscribeNowButtonTap,
        ),
      ]);

      String subscriptionId = data[0] as String;
      await FirestoreFunctions().updateOrSaveSubscriptionIdFirestoreData(
        subscriptionId: subscriptionId,
      );

      return subscriptionId;
    }
    return null;
  }
}
