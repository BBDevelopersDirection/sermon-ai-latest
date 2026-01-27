import 'package:equatable/equatable.dart';

enum LoadingStatus {
  noLoading,
  phoneNumberLoading,
  otpLoading,
  userRegestrationLoading,
}

class LoginForgotSignupState extends Equatable {
  LoadingStatus loadingStatus;

  LoginForgotSignupState({required this.loadingStatus});

  LoginForgotSignupState copyWith({
    LoadingStatus? loadingStatus,
  }) {
    return LoginForgotSignupState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
    );
  }

  @override
  List<Object> get props => [loadingStatus];
}
