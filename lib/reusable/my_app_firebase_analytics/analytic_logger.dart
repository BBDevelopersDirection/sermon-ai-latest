import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:sermon/reusable/logger_service.dart';

import 'AnalyticsEngine.dart';

class MyAppAnalitics {
  MyAppAnalitics._privateConstructor();

  static MyAppAnalitics instanse(){
    return MyAppAnalitics._privateConstructor();
  }

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  Future<void> logEvent({required String event}) async {
    try{
  await AnalyticsEngine.instance.logFirebaseEvent(FirebaseEventName: event);
  AppLogger.d('Logged firebase event: ${event}');


  _facebookAppEvents.logEvent(name: event);
  AppLogger.d('Logged Facebook event: ${event}');
    }catch (e){
      AppLogger.e('Error while logging firebase event: ${event}');
    }
  }
}