import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/main.dart';
import 'package:sermon/models/video_data_model.dart';
import 'package:sermon/services/firebase/firebase_remote_config.dart';
import 'package:sermon/services/firebase/utils_management/utils_functions.dart';
import 'package:sermon/services/firebase/video_management/video_functions.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:sermon/services/plan_service/plan_purchase_cubit.dart';
import 'package:sermon/services/plan_service/plan_purchase_screen.dart';

import 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit()
    : super(BottomNavState(
        bottomNavScaffoldKey: null,
        hideBottomBar: false,
        selectedIndex: 0,
      ));

  void saveKeyBottomNav({
    required GlobalKey<ScaffoldState> bottomNavScaffoldKey,
  }) {
    emit(state.copyWith(bottomNavScaffoldKey: bottomNavScaffoldKey));
  }

  void setSelectedIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> showRechargePage({required bool isShow}) async {
    if (!isShow) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && HiveBoxFunctions().getUuid().isEmpty) {
      return; // User not logged in
    }
    final utility = await UtilsFunctions().getFirebaseUtility(
      userId: user?.uid ?? HiveBoxFunctions().getUuid(),
    );
    if (utility == null) return;
    if (utility.isRecharged) return;

    Timer(Duration(seconds: FirebaseRemoteConfigService().rechargePageDelaySecondsAfterLogin), () {
      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => PlanPurchaseCubit(),
            child: SubscriptionTrialScreen(),
          ),
        ),
      );
    });
  }

  void openDrawer() {
    if (state.bottomNavScaffoldKey != null) {
      state.bottomNavScaffoldKey!.currentState?.openDrawer();
    }
  }

  void closeDrawer() {
    if (state.bottomNavScaffoldKey != null) {
      state.bottomNavScaffoldKey!.currentState?.closeDrawer();
    }
  }

  // Future<SectionDetail?> getSliderVideo() async {
  //   // await VideoFunctions().uploadSectionsToFirestore();
  //   return await VideoFunctions().getSliderVideo();
  // }

  // Future<List<SectionDetail>> getAllVideo() async {
  //   // await VideoFunctions().uploadSectionsToFirestore();
  //   return await VideoFunctions().getAllSections();
  // }

  void hideBottomNavBar() {
    emit(state.copyWith(hideBottomBar: true));
  }

  void unhideBottomNavBar() {
    emit(state.copyWith(hideBottomBar: false));
  }
}
