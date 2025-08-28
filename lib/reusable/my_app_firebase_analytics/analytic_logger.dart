import 'package:facebook_app_events/facebook_app_events.dart';

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
      print('Logged firebase event: ${event}');


      _facebookAppEvents.logEvent(name: event);
      print('Logged Facebook event: ${event}');

    }catch (e){
      print('Error while logging firebase event: ${event}');
    }
  }
}