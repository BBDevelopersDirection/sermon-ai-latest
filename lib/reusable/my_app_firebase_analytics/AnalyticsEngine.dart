import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sermon/main.dart';
import 'package:sermon/reusable/logger_service.dart';

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
      if (isDebugMode() || kDebugMode) {
        AppLogger.d('Firebase Analytics Event Logged: $FirebaseEventName');
      }
    } catch (e) {
      if (isDebugMode() || kDebugMode) {
        AppLogger.e('Firebase Analytics Error: $e');
      }
    }
  }
}
