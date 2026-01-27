import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BottomNavState extends Equatable {
  final GlobalKey<ScaffoldState>? bottomNavScaffoldKey;
  final bool hideBottomBar;
  final int selectedIndex;
  BottomNavState({
    required this.bottomNavScaffoldKey,
    required this.hideBottomBar,
    required this.selectedIndex,
  });

  BottomNavState copyWith({
    GlobalKey<ScaffoldState>? bottomNavScaffoldKey,
    bool? hideBottomBar,
    int? selectedIndex,
  }) {
    return BottomNavState(
      bottomNavScaffoldKey: bottomNavScaffoldKey ?? this.bottomNavScaffoldKey,
      hideBottomBar: hideBottomBar ?? this.hideBottomBar,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [bottomNavScaffoldKey, hideBottomBar, selectedIndex];
}
