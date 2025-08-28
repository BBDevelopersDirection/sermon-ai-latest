import 'package:equatable/equatable.dart';

enum planPurchaseErrorCode{
  noError,
  firebaseUserNotFound,
  customerApiError,
  createSubscriptionApiError
}

class PlanPurchaseState extends Equatable {
  bool loading;
  planPurchaseErrorCode errorCode;

  PlanPurchaseState({required this.loading, required this.errorCode});

  PlanPurchaseState copyWith({bool? loading, planPurchaseErrorCode? errorCode}) {
    return PlanPurchaseState(
      loading: loading ?? this.loading,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  List<Object> get props => [loading, errorCode];
}
