import 'package:dio/dio.dart';
import 'package:sermon_tv/main.dart';
import 'package:sermon_tv/services/firebase/models/user_models.dart';
import 'package:sermon_tv/services/firebase/firebase_remote_config.dart';
import 'package:sermon_tv/services/plan_service/models/CreateCustomerResponseModel.dart';
import 'package:sermon_tv/utils/string_extensions.dart';

import 'dio_client.dart';
import 'package:sermon_tv/reusable/logger_service.dart';

class MyAppEndpoints {
  MyAppEndpoints._();
  static MyAppEndpoints instance() => MyAppEndpoints._();
  String razorPayUrl = isDebugMode() ? 'test' : '';

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
      AppLogger.d("Email is: $emailIs");
      var data = {
        'name': firebaseUser.name,
        'email': firebaseUser.email == ''
            ? firebaseUser.uid.toGmail()
            : firebaseUser.email,
        'contact': firebaseUser.phoneNumber,
        'userId': firebaseUser.uid,
      };
      AppLogger.d("data is: $data");
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
      final remoteConfig = FirebaseRemoteConfigService();
      final planId = isDebugMode()
          ? remoteConfig.razorpayTestPlanId
          : remoteConfig.razorpayLivePlanId;
      Map<String, dynamic> data = {
        'planId': planId,
        'customerId': razorpayCustomerResponse.customer?.razorpayCustomerId,
        'userId': razorpayCustomerResponse.customer?.userId,
        'planType': 'monthly',
        'totalCount': 12,
        'startDate': 7,
        'customerNotify': 1,
      };
      AppLogger.d("Data for subscription: $data");
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
      AppLogger.e('⚠️ Failed to fetch network time: $e');
    }

    return null; // fallback on failure
  }
}
