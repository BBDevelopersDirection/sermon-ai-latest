import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BottomNavState extends Equatable {
  final GlobalKey<ScaffoldState>? bottomNavScaffoldKey;
  final bool hideBottomBar;
  final bool isVideoCaching;
  final int selectedIndex;
  const BottomNavState({
    required this.bottomNavScaffoldKey,
    required this.isVideoCaching,
    required this.hideBottomBar,
    required this.selectedIndex,
  });

  BottomNavState copyWith({
    GlobalKey<ScaffoldState>? bottomNavScaffoldKey,
    bool? isVideoCaching,
    bool? hideBottomBar,
    int? selectedIndex,
  }) {
    return BottomNavState(
      bottomNavScaffoldKey: bottomNavScaffoldKey ?? this.bottomNavScaffoldKey,
      isVideoCaching: isVideoCaching ?? this.isVideoCaching,
      hideBottomBar: hideBottomBar ?? this.hideBottomBar,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [bottomNavScaffoldKey, isVideoCaching ,hideBottomBar, selectedIndex];
}
