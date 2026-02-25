import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon_tv/screens/after_login/bottom_nav/bottom_nav/bottom_nav_cubit.dart';
import 'package:sermon_tv/screens/after_login/bottom_nav/bottom_nav/bottom_nav_screen.dart';
import 'package:sermon_tv/screens/before_login/sign_up/sign_up_screen.dart';
import 'package:sermon_tv/services/firebase/firebase_remote_config.dart';
import 'package:sermon_tv/screens/before_login/sign_up/sign_up_screen_reel.dart';
import '../../reusable/progress_indicator.dart';
import 'login_check_cubit.dart';
import 'login_check_state.dart';

class LoginCheckScreen extends StatefulWidget {
  bool isLoginOrRegesterFlow;
  LoginCheckScreen({super.key, required this.isLoginOrRegesterFlow});

  @override
  State<LoginCheckScreen> createState() => _LoginCheckScreenState();
}

class _LoginCheckScreenState extends State<LoginCheckScreen> {
  @override
  void initState() {
    context.read<LoginCheckCubit>().checkToken(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isTokenPresent = context.select(
      (LoginCheckCubit cubit) => cubit.state.isTokenPresent ?? false,
    );
    final error = context.select((LoginCheckCubit cubit) => cubit.state.error);
    final loading = context.select(
      (LoginCheckCubit cubit) => cubit.state.loading,
    );

    return Scaffold(
      body: BlocBuilder<LoginCheckCubit, LoginCheckState>(
        builder: (context, LoginCheckState) {
          return _build_ui(state: LoginCheckState);
        },
      ),
    );
  }

  Widget _build_ui({required LoginCheckState state}) {
    if (state.loading) {
      return _loadingState();
    } else if (state.error != null) {
      return _error_page(errorMessage: state.error!);
    } else if (state.isTokenPresent == true) {
      return _token_found();
    } else {
      return _token_not_found();
    }
  }

  Widget _loadingState() {
    return Center(child: MyAppCircularProgressIndicator());
  }

  Widget _error_page({required String errorMessage}) {
    return Center(child: Text('Error Occur: $errorMessage'));
  }

  Widget _token_found() {
    return BlocProvider(
      create: (context) => BottomNavCubit()
        ..showRechargePage(
          isShow:
              widget.isLoginOrRegesterFlow &&
              FirebaseRemoteConfigService().shouldShowRechargePage,
        ),
      child: BottomNavScreen(),
    );
  }

  Widget _token_not_found() {
    return SignUpScreen();
    // return BlocProvider(
    //   create: (context) => BottomNavCubit(),
    //   child: BottomNavScreen(),
    // );
    // return Dashboard();
  }
}
