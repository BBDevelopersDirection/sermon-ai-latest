import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sermon/models/video_data_model.dart';
import 'package:sermon/services/firebase/video_management/video_functions.dart';

import 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit()
    : super(BottomNavState(bottomNavScaffoldKey: null, hideBottomBar: false));

  void saveKeyBottomNav({
    required GlobalKey<ScaffoldState> bottomNavScaffoldKey,
  }) {
    emit(state.copyWith(bottomNavScaffoldKey: bottomNavScaffoldKey));
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
  
  void hideBottomNavBar(){
    emit(state.copyWith(hideBottomBar: true));
  }

  void unhideBottomNavBar(){
    emit(state.copyWith(hideBottomBar: false));
  }
}
