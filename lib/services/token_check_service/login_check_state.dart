import 'package:equatable/equatable.dart';

class LoginCheckState extends Equatable {
  final bool loading;
  final bool showRechargePage;
  final bool showPaymentInProgress;
  final int currentPlan;
  final String? error;
  final bool? isTokenPresent;

  const LoginCheckState({
    this.loading = true,
    required this.showRechargePage,
    this.showPaymentInProgress = false,
    this.error,
    required this.currentPlan,
    this.isTokenPresent,
  });

  LoginCheckState copyWith({
    bool? loading,
    bool? showRechargePage,
    bool? showPaymentInProgress,
    int? currentPlan,
    String? error,
    bool? isTokenPresent,
  }) {
    return LoginCheckState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      isTokenPresent: isTokenPresent ?? this.isTokenPresent,
      showRechargePage: showRechargePage ?? this.showRechargePage,
      showPaymentInProgress: showPaymentInProgress ?? this.showPaymentInProgress,
      currentPlan: currentPlan ?? this.currentPlan,
    );
  }

  @override
  List<Object?> get props => [loading, error, isTokenPresent, showRechargePage, showPaymentInProgress, currentPlan];
}
