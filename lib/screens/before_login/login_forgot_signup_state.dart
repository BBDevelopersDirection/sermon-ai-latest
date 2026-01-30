import 'package:equatable/equatable.dart';

enum LoadingStatus {
  noLoading,
  phoneNumberLoading,
  otpLoading,
  userRegestrationLoading,
}

class LoginForgotSignupState extends Equatable {
  LoadingStatus loadingStatus;
  bool isShowRecapchaWarning;

  LoginForgotSignupState({required this.loadingStatus, required this.isShowRecapchaWarning});

  LoginForgotSignupState copyWith({
    LoadingStatus? loadingStatus,
    bool? isShowRecapchaWarning,
  }) {
    return LoginForgotSignupState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      isShowRecapchaWarning: isShowRecapchaWarning ?? this.isShowRecapchaWarning,
    );
  }

  @override
  List<Object> get props => [loadingStatus, isShowRecapchaWarning];
}
