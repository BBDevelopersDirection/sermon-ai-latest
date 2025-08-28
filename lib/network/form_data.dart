import 'package:dio/dio.dart';

class MyAppFormData {
  FormData login({required String login, required String pass}) {
    Map<String, String> data;
    data = {'login': login, 'pass': pass};
    return FormData.fromMap(data);
  }
}
