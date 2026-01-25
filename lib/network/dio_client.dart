import 'package:dio/dio.dart';
import 'package:sermon/services/firebase/firebase_remote_config.dart';

class MyAppDio {
  MyAppDio._();
  static String get base_url => FirebaseRemoteConfigService().apiBaseUrl;
  static Dio instance() {
    return Dio(BaseOptions(baseUrl: base_url, responseType: ResponseType.json));
  }
}