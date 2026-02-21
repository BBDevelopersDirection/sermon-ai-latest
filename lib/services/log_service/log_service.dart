import 'dart:async';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:linkrunner/linkrunner.dart';
import 'package:linkrunner/models/lr_user_data.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/default_tracking.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:sermon/reusable/logger_service.dart';
import 'package:sermon/services/firebase/models/user_models.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:sermon/services/shared_pref/shared_preference.dart';

import '../../reusable/my_app_firebase_analytics/AnalyticsEngine.dart';

/// Central analytics singleton: Amplitude, Firebase, Facebook, and Linkrunner.
/// Handles attribution (Linkrunner), user identity, and deep link event logging.
class MyAppAmplitudeAndFirebaseAnalitics {
  MyAppAmplitudeAndFirebaseAnalitics._privateConstructor();

  static final MyAppAmplitudeAndFirebaseAnalitics _instance =
      MyAppAmplitudeAndFirebaseAnalitics._privateConstructor();

  factory MyAppAmplitudeAndFirebaseAnalitics() {
    return _instance;
  }

  // --- Amplitude ---
  final Amplitude _amplitude = Amplitude(
    Configuration(
      apiKey: 'c125d139ecadb9a3cec11be6a18c052a',
      logLevel: LogLevel.debug,
      defaultTracking: DefaultTrackingOptions.all(),
    ),
  );

  // --- Facebook ---
  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  /// Replace with your project token from https://dashboard.linkrunner.io/dashboard
  static const String _linkrunnerProjectToken = 'oghGjA2JICNz4efgns0k7wcI';

  /// Called once at app startup (e.g. from main()). Initializes Amplitude user id,
  /// Linkrunner SDK, sets user for Linkrunner when already logged in, and sets up
  /// deep link listeners (deferred + in-app stream).
  Future<void> init() async {
    // 1. Set Amplitude user id from stored preference (existing behavior)
    final userId = await SharedPreferenceLogic().getUserId();
    _amplitude.setUserId(userId);

    // 2. Initialize Linkrunner for attribution and deferred deep links
    try {
      await LinkRunner().init(
        _linkrunnerProjectToken,
        null, // secretKey (optional)
        null, // keyId (optional)
        false, // disableIdfa (iOS)
        kReleaseMode ? false : true, // debug
      );
      AppLogger.d('Linkrunner SDK initialized');
    } catch (e) {
      AppLogger.e('Linkrunner init error: $e');
    }

    // 3. Set Linkrunner user when already logged in (e.g. app opened from background)
    final firebaseUser = HiveBoxFunctions().getLoginDetails();
    if (firebaseUser?.uid != null && firebaseUser!.uid.isNotEmpty) {
      await setLinkrunnerUserId(firebaseUser.uid);
    }
  }

  /// Registers Linkrunner user for attribution. Call after sign-in with the authenticated userId.
  /// Also call from init() when user is already logged in (setUserData each app open).
  Future<void> setLinkrunnerUserId(String userId) async {
    if (userId.isEmpty) return;
    try {
      await LinkRunner().setUserData(
        userData: LRUserData(id: userId),
      );
      AppLogger.d('Linkrunner user id set: $userId');
    } catch (e) {
      AppLogger.e('Linkrunner setUserData error: $e');
    }
  }

  /// Logs [event] to Amplitude, Firebase, and Facebook. Optionally [eventProperties] are sent to Amplitude and Firebase.
  Future<void> logEvent({
    required String event,
    Map<String, dynamic>? eventProperties,
  }) async {
    final FirebaseUser? firebaseUser = HiveBoxFunctions().getLoginDetails();
    final Map<String, dynamic> baseProps = {
      'uuid': firebaseUser?.uid,
      'name': firebaseUser?.name,
      'phone_number': firebaseUser?.phoneNumber,
    };
    final Map<String, dynamic> props = Map<String, dynamic>.from(baseProps);
    if (eventProperties != null && eventProperties.isNotEmpty) {
      props.addAll(eventProperties);
    }

    // Amplitude
    try {
      _amplitude.track(
        BaseEvent(
          event,
          eventProperties: props,
          userProperties: {
            'uuid': firebaseUser?.uid,
            'name': firebaseUser?.name,
            'phone_number': firebaseUser?.phoneNumber,
          },
        ),
      );
      AppLogger.d('🚀🔥 "$event" event logged successfully in Amplitude! 🎉✅');
    } catch (e) {
      AppLogger.e('Error logging Amplitude event: $e');
    }

    // Firebase
    try {
      final Map<String, Object>? firebaseParams =
          eventProperties?.map((k, v) => MapEntry(k, v as Object));
      await AnalyticsEngine.instance.logFirebaseEvent(
        FirebaseEventName: event,
        parameters: firebaseParams,
      );
      AppLogger.d('🚀🔥 "$event" event logged successfully in Firebase! 🎉✅');
    } catch (e) {
      AppLogger.e('Error logging Firebase event: $e');
    }

    // Facebook
    try {
      _facebookAppEvents.logEvent(name: event);
      AppLogger.d('🚀🔥 "$event" event logged successfully in Facebook! 🎉✅');
    } catch (e) {
      AppLogger.e('Error logging Facebook event: $e');
    }

    // Linkrunner (attribution + event tracking)
    try {
      await LinkRunner().trackEvent(
        eventName: event,
        eventData: props.isNotEmpty ? props : null,
      );
      AppLogger.d('🚀🔥 "$event" event logged successfully in Linkrunner! 🎉✅');
    } catch (e) {
      AppLogger.e('Error logging Linkrunner event: $e');
    }
  }
}
