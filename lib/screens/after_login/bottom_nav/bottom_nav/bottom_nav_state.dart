import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BottomNavState extends Equatable {
  final GlobalKey<ScaffoldState>? bottomNavScaffoldKey;
  final bool hideBottomBar;
  BottomNavState({
    required this.bottomNavScaffoldKey,
    required this.hideBottomBar,
  });

  BottomNavState copyWith({
    GlobalKey<ScaffoldState>? bottomNavScaffoldKey,
    bool? hideBottomBar,
  }) {
    return BottomNavState(
      bottomNavScaffoldKey: bottomNavScaffoldKey ?? this.bottomNavScaffoldKey,
      hideBottomBar: hideBottomBar ?? this.hideBottomBar,
    );
  }

  @override
  List<Object?> get props => [bottomNavScaffoldKey, hideBottomBar];
}
