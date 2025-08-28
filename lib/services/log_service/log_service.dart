import 'dart:developer';
import 'dart:math' hide log;
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/default_tracking.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:sermon/services/firebase/models/user_models.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:sermon/services/shared_pref/shared_preference.dart';

import '../../reusable/my_app_firebase_analytics/AnalyticsEngine.dart';

class MyAppAmplitudeAndFirebaseAnalitics {
  MyAppAmplitudeAndFirebaseAnalitics._privateConstructor();

  static final MyAppAmplitudeAndFirebaseAnalitics _instance =
      MyAppAmplitudeAndFirebaseAnalitics._privateConstructor();

  factory MyAppAmplitudeAndFirebaseAnalitics() {
    return _instance;
  }

  // final Amplitude _amplitude = Amplitude.getInstance(instanceName: "default");
  final Amplitude _amplitude = Amplitude(
    Configuration(
      apiKey: 'c125d139ecadb9a3cec11be6a18c052a',
      logLevel: LogLevel.debug,
      defaultTracking: DefaultTrackingOptions.all(),
    ),
  );
  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  Future<void> init() async {
    final userId = await SharedPreferenceLogic().getUserId();
    _amplitude.setUserId(userId);
  }

  Future<void> logEvent({required String event}) async {
    // Amplitude Event
    FirebaseUser? firebaseUser = HiveBoxFunctions().getLoginDetails();
    try {
      _amplitude.track(
        BaseEvent(
          event,
          eventProperties: {
            'uuid': firebaseUser?.uid,
            'name': firebaseUser?.name,
            'phone_number': firebaseUser?.phoneNumber,
          },
        ),
      );
      debugPrint('🚀🔥 "$event" event logged successfully in Amplitude! 🎉✅');
    } catch (e) {
      log('Error logging Amplitude event: $e');
    }

    // Firebase
    try {
      await AnalyticsEngine.instance.logFirebaseEvent(FirebaseEventName: event);
      debugPrint('🚀🔥 "$event" event logged successfully in Firebase! 🎉✅');
    } catch (e) {
      debugPrint('Error logging Firebase event: $e');
    }

    // Facebook
    try {
      _facebookAppEvents.logEvent(name: event);
    } catch (e) {
      log('Error logging Facebook event: $e');
    }
  }
}
