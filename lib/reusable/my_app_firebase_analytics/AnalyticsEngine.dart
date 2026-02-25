import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sermon_tv/main.dart';
import 'package:sermon_tv/reusable/logger_service.dart';

class AnalyticsEngine {
  AnalyticsEngine._();

  static final AnalyticsEngine instance = AnalyticsEngine._();

  final _analytics = FirebaseAnalytics.instance;

  Future<void> logFirebaseEvent({
    required String FirebaseEventName,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: FirebaseEventName,
        parameters: parameters,
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
