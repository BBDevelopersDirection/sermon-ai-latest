import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:sermon/reusable/logger_service.dart';
import 'package:lottie/lottie.dart'; // Add in pubspec.yaml for animations
import 'package:sermon/utils/app_assets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/token_check_service/login_check_cubit.dart';
import '../main.dart';

class PaymentInProgressPage extends StatefulWidget {
  final String subscriptionId;

  const PaymentInProgressPage({super.key, required this.subscriptionId});

  @override
  State<PaymentInProgressPage> createState() => _PaymentInProgressPageState();
}

class _PaymentInProgressPageState extends State<PaymentInProgressPage> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _listener;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    final collectionName = kDebugMode ? 'test-subscriptions' : 'subscriptions';
    _listener = FirebaseFirestore.instance
        .collection(collectionName)
        .doc(widget.subscriptionId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        final status = data['status'] as String?;
        if (status != null) {
          final s = status.toLowerCase();
          AppLogger.d('PaymentInProgressPage: subscription status -> $s');
          if (s == 'active' || s == 'payment_captured') {
            // update cubit and pop the page
            try {
              final rootCtx = navigatorKey.currentState?.context;
              if (rootCtx != null) {
                rootCtx.read<LoginCheckCubit>().emit_show_payment_in_progress(isShow: false);
                rootCtx.read<LoginCheckCubit>().checkPlanExpire();
              }
            } catch (_) {}

            // pop this page
            try {
              if (mounted) Navigator.of(context, rootNavigator: true).pop();
            } catch (_) {}
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    _listener = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fullscreen dark background
      body: SafeArea(
        child: Stack(
          children: [
            /// Animated background (optional gradient animation)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            /// Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Lottie animation (replace with your preferred animation)
                  SizedBox(
                    height: 180,
                    child: Lottie.asset(
                      MyAppAssets.lottie_payment_in_progress, // add your Lottie file
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Title
                  const Text(
                    'Payment in Progress',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Subtitle
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Please do not close the app while we complete your payment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Progress indicator with glowing effect
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 4,
                        )
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            /// Close button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm'),
                      content: const Text('Are you sure you want to cancel the payment?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    // First, try to update the cubit via a stable root context so
                    // other listeners can react.
                    try {
                      final rootCtx = navigatorKey.currentState?.context ?? context;
                      rootCtx.read<LoginCheckCubit>().emit_show_payment_in_progress(isShow: false);
                    } catch (e) {
                      // ignore
                    }

                    // Then explicitly pop this full-screen page from the root
                    // navigator so it's removed immediately.
                    try {
                      Navigator.of(context, rootNavigator: true).pop();
                    } catch (e) {
                      // fallback to local pop
                      try {
                        Navigator.of(context).pop();
                      } catch (_) {}
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
