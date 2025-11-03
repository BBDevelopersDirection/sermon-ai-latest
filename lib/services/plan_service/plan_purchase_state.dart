import 'package:equatable/equatable.dart';
import 'package:sermon/services/plan_service/plan_purchase_state.dart';

enum planPurchaseErrorCode {
  noError,
  firebaseUserNotFound,
  customerApiError,
  createSubscriptionApiError,
}

enum loadingStates {
  buttonLoading,
  buttonLoadingStop,
}

enum subscriptionTypes {
  subscriptionTypeLoading,
  freeTrial,
  normalSubscription,
}

class PlanPurchaseState extends Equatable {
  loadingStates LoadingFreeTrialNormal;
  planPurchaseErrorCode errorCode;
  subscriptionTypes subscriptionType;

  PlanPurchaseState({
    required this.LoadingFreeTrialNormal,
    required this.errorCode,
    required this.subscriptionType,
  });

  PlanPurchaseState copyWith({
    loadingStates? LoadingFreeTrialNormal,
    planPurchaseErrorCode? errorCode,
    subscriptionTypes? subscriptionTypes,
  }) {
    return PlanPurchaseState(
      LoadingFreeTrialNormal:
          LoadingFreeTrialNormal ?? this.LoadingFreeTrialNormal,
      errorCode: errorCode ?? this.errorCode,
      subscriptionType: subscriptionTypes ?? this.subscriptionType,
    );
  }

  @override
  List<Object> get props => [LoadingFreeTrialNormal, errorCode, subscriptionType];
}
