import 'package:dio/dio.dart';

class MyAppDio {
  MyAppDio._();
  static String base_url = 'https://razorpayapi-huqydr5fsq-el.a.run.app';
  static Dio instance() {
    return Dio(BaseOptions(baseUrl: base_url, responseType: ResponseType.json));
  }
}
