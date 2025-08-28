import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sermon/services/firebase/models/user_models.dart';
import 'package:sermon/services/plan_service/models/CreateCustomerResponseModel.dart';
import 'package:sermon/utils/string_extensions.dart';

import 'dio_client.dart';

class MyAppEndpoints {
  MyAppEndpoints._();
  static MyAppEndpoints instance() => MyAppEndpoints._();
  String razorPayUrl = kDebugMode ? 'test' : '';

  Future<Response> subscriptionStatus({required String userId}) async {
    try {
      return await MyAppDio.instance().get(
        '/$razorPayUrl/subscription-status/$userId',
      );
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response> createCustomer({required FirebaseUser firebaseUser}) async {
    try {
      String emailIs = "69bbe1ae-c3f3-54a5-ab9b-86b8202d193d".toGmail();
      print("Email is: $emailIs");
      var data = {
              'name': firebaseUser.name,
              'email': firebaseUser.email == ''
                  ? firebaseUser.uid.toGmail()
                  : firebaseUser.email,
              'contact': firebaseUser.phoneNumber,
              'userId': firebaseUser.uid,
            };
      print("data is: ${data}");
      return await MyAppDio.instance().post(
        '/$razorPayUrl/create-customer',
        data: data,
      );
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response> createSubscription({
    required RazorpayCustomerResponse razorpayCustomerResponse,
  }) async {
    try {
      Map<String, dynamic> data = {
              'planId': kDebugMode ? 'plan_Qwe6q0fZBLxs0L' : 'plan_PvgYi6MEgXZKPB',
              'customerId':
                  razorpayCustomerResponse.customer?.razorpayCustomerId,
              'userId': razorpayCustomerResponse.customer?.userId,
              'planType': 'monthly',
              'totalCount': 12,
              'customerNotify': 1,
            };
      print("Data for subscription: $data");
      return await MyAppDio.instance().post(
        '/$razorPayUrl/create-subscription',
        data: data,
      );
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<DateTime?> getNetworkTime() async {
    try {
      final response = await Dio().get(
        'http://worldtimeapi.org/api/timezone/Etc/UTC',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['utc_datetime'] != null) {
          return DateTime.parse(data['utc_datetime']);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to fetch network time: $e');
    }

    return null; // fallback on failure
  }
}