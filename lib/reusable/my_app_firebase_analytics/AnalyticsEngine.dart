import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsEngine {
  AnalyticsEngine._();

  static final AnalyticsEngine instance = AnalyticsEngine._();

  final _analytics = FirebaseAnalytics.instance;

  Future<void> logFirebaseEvent({required String FirebaseEventName}) async {
    try {
      // await _analytics.setAnalyticsCollectionEnabled(true);

      await _analytics.logEvent(
        name: FirebaseEventName,
      );
      if (kDebugMode) {
        print('Firebase Analytics Event Logged: $FirebaseEventName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Analytics Error: $e');
      }
    }
  }
}
