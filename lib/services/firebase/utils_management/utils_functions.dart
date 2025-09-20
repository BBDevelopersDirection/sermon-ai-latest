import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/src/response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:sermon/models/video_data_model.dart';
import 'package:sermon/network/endpoints.dart';
import 'package:sermon/services/firebase/models/utility_model.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:uuid/uuid.dart';

import '../../log_service/log_service.dart';
import '../../log_service/log_variables.dart';
import '../firestore_variables.dart';
import '../models/user_models.dart';

class UtilsFunctions {
  Future<UtilityModel?> getFirebaseUtility({required String userId}) async {
    final userDoc = await FirebaseFirestore.instance
        .collection(FirestoreVariables.utilitiesCollection)
        .doc(userId)
        .get();
    if (userDoc.exists) {
      var data = userDoc.data();
      return UtilityModel.fromJson(data!);
    }
    return null; // Placeholder return value
  }

  // Example function to set user data
  Future<void> createFirebaseUtilityData({
    required UtilityModel utilityModel,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection(FirestoreVariables.utilitiesCollection)
        .doc(utilityModel.userId);

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({
        FirestoreVariables.userIdField: utilityModel.userId,
        FirestoreVariables.totalVideoCount: utilityModel.totalVideoCount,
        FirestoreVariables.videoCountToCheckSub:
            utilityModel.videoCountToCheckSub,
        FirestoreVariables.isRecharged: utilityModel.isRecharged,
        FirestoreVariables.rechargeStartDate: null,
        FirestoreVariables.rechargeEndDate: null,
      });
    } else {
      debugPrint(
        'Utility data already exists for user: ${utilityModel.userId}',
      );
    }
  }

  Future<void> updateFirebaseUtilityData({
    required String fieldName,
    required dynamic newValue,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && HiveBoxFunctions().getUuid().isEmpty)
      return; // User not logged in

    final docRef = FirebaseFirestore.instance
        .collection(FirestoreVariables.utilitiesCollection)
        .doc(user?.uid ?? HiveBoxFunctions().getUuid());

    // Always sets/updates the field, creates doc if it doesn't exist
    await docRef.set({fieldName: newValue}, SetOptions(merge: true));
  }

  Future<bool> canUseVideo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null && HiveBoxFunctions().getUuid().isEmpty) {
      return false; // User not logged in
    }

    final utility = await getFirebaseUtility(
      userId: user?.uid ?? HiveBoxFunctions().getUuid(),
    );

    if (utility == null) return false;

    if (utility.isRecharged) return true;

    return utility.videoCountToCheckSub <=
        FirestoreVariables.totalVideoCountUserCanSee;
  }

  Future<bool> canUseReel({required int index}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null && HiveBoxFunctions().getUuid().isEmpty)
      return false; // User not logged in

    final utility = await getFirebaseUtility(
      userId: user?.uid ?? HiveBoxFunctions().getUuid(),
    );

    if (utility == null) return false;

    if (utility.isRecharged) return true;

    return index < FirestoreVariables.totalReelCountUserCanSee;
  }

  Future<void> increaseVideoCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && HiveBoxFunctions().getUuid().isEmpty)
      return; // User not logged in

    final utility = await getFirebaseUtility(
      userId: user?.uid ?? HiveBoxFunctions().getUuid(),
    );
    if (utility != null) {
      final newCount = utility.totalVideoCount + 1;
      final newVideoCountToCheckSub;
      if (utility.isRecharged) {
        newVideoCountToCheckSub = FirestoreVariables.totalVideoCountUserCanSee;
      } else {
        newVideoCountToCheckSub = utility.videoCountToCheckSub + 1;
      }
      Future.wait([
        updateFirebaseUtilityData(
          fieldName: FirestoreVariables.videoCountToCheckSub,
          newValue: newVideoCountToCheckSub,
        ),
        updateFirebaseUtilityData(
          fieldName: FirestoreVariables.totalVideoCount,
          newValue: newCount,
        ),
      ]);
    }
  }

  Future<void> setRechargeTrue() async {
    print("inside set recharge true");
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && HiveBoxFunctions().getUuid().isEmpty)
      return; // User not logged in

    print("User Exsists");
    // Set isRecharged to true
    Future.wait([
      updateFirebaseUtilityData(
        fieldName: FirestoreVariables.isRecharged,
        newValue: true,
      ),

      updateFirebaseUtilityData(
        fieldName: FirestoreVariables.rechargeStartDate,
        newValue: FieldValue.serverTimestamp(),
      ),

      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().transistionCompleteEvent,
      ),
    ]);

    print("first future block passed");

    DateTime? dateTime;

    try {
      dateTime = await MyAppEndpoints.instance().getNetworkTime();
    } catch (e) {
      debugPrint("Error while getting network time");
      dateTime = DateTime.now();
    }

    print('walaah part 0');
    getFirebaseUtility(userId: user?.uid ?? HiveBoxFunctions().getUuid()).then((
      utility,
    ) async {
      if (utility != null) {
        // If the user has a utility document, update the video count to check subscription
        print('walaah part 1');
        var data = utility.rechargeStartDate;
        await updateFirebaseUtilityData(
          fieldName: FirestoreVariables.rechargeEndDate,
          newValue: dateTime?.add(Duration(days: 30)),
        );
        print('walaah part 2');
      }
    });
  }

  Future<void> setRechargeFalseIfRechargeExpires() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && HiveBoxFunctions().getUuid().isEmpty) return;

    final docRef = FirebaseFirestore.instance
        .collection(FirestoreVariables.utilitiesCollection)
        .doc(user?.uid ?? HiveBoxFunctions().getUuid());

    final utility = await getFirebaseUtility(
      userId: user?.uid ?? HiveBoxFunctions().getUuid(),
    );
    if (utility == null) return;

    try {
      var data = await MyAppEndpoints.instance().subscriptionStatus(
        userId: user?.uid ?? HiveBoxFunctions().getUuid(),
      );

      bool hasSubscription =
          data.data['hasSubscription'] &&
          (data.data['subscription']['status'] == 'active' ||
              data.data['subscription']['status'] == 'payment_captured');

      if (hasSubscription) {
        await docRef.set({
          FirestoreVariables.isRecharged: true,
        }, SetOptions(merge: true));
      } else {
        await docRef.set({
          FirestoreVariables.isRecharged: false,
          FirestoreVariables.rechargeStartDate: null,
          FirestoreVariables.rechargeEndDate: null,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Error while setting isRecharge");
    }

    // Step 1: Write temporary server timestamp field to same doc
    // await docRef.set({
    // 'lastChecked': FieldValue.serverTimestamp(),
    // }, SetOptions(merge: true));

    // // Step 2: Read back that server time
    // final updatedSnapshot = await docRef.get();
    // final serverTime = updatedSnapshot.data()?['lastChecked']?.toDate();

    // // Step 3: Compare and act
    // if (serverTime != null && serverTime.isAfter(utility.rechargeEndDate!)) {
    // await docRef.set({
    //   FirestoreVariables.isRecharged: false,
    //   FirestoreVariables.rechargeStartDate: null,
    //   FirestoreVariables.rechargeEndDate: null,
    //   'lastChecked': FieldValue.delete(), // clean up
    // }, SetOptions(merge: true));
    // }
    // await docRef.set({
    //   'lastChecked': FieldValue.delete(), // clean up
    // }, SetOptions(merge: true));
  }
}

extension on Response {
  void operator [](String other) {}
}
