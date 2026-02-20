import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'no_internet_page.dart';

class MyScaffold extends StatefulWidget {
  final Widget child;

  const MyScaffold({super.key, required this.child});

  @override
  State<MyScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<MyScaffold>
    with WidgetsBindingObserver {
  StreamSubscription? connectivitySubscription;
  ValueNotifier<bool> isNetworkDisabled = ValueNotifier(false);

  void _checkCurrentNetworkState() {
    Connectivity().checkConnectivity().then((connectivityResult) {
      isNetworkDisabled.value = connectivityResult == ConnectivityResult.none;
    });
  }

  void initStateFunc() {
    _checkCurrentNetworkState();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      isNetworkDisabled.value = result == ConnectivityResult.none;
    });
    // ignore: avoid_print
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initStateFunc();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkCurrentNetworkState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: isNetworkDisabled,
          builder: (_, bool networkDisabled, __) => Visibility(
            visible: !networkDisabled,
            child: KeyboardDismissOnTap(child: widget.child),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: isNetworkDisabled,
          builder: (_, bool networkDisabled, __) => Visibility(
            visible: networkDisabled,
            child: const NoInternetPage(),
          ),
        ),
      ],
    );
  }
}
