import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/src/response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/network/endpoints.dart';
import 'package:sermon/services/firebase/models/subscription_model.dart';
import 'package:sermon/services/firebase/models/user_models.dart';
import 'package:sermon/services/firebase/models/utility_model.dart';
import 'package:sermon/services/firebase/subscription_management/subscription_function.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';

import 'package:sermon/reusable/logger_service.dart';
import 'package:sermon/services/plan_service/plan_purchase_cubit.dart';
import '../firestore_variables.dart';

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

    await setFirebaseUtilityFieldsIfAbsent({
      FirestoreVariables.isFreeTrialOpted: false,
    });

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
      AppLogger.d(
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

  /// Sets Firebase Utility fields in bulk if they are absent.
  /// [fields] is a map containing field names and their default values.
  Future<void> setFirebaseUtilityFieldsIfAbsent(
    Map<String, dynamic> fields,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final uuid = HiveBoxFunctions().getUuid();
    if (user == null && uuid.isEmpty) {
      AppLogger.e("User not logged in to create utility data if not exists");
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection(FirestoreVariables.utilitiesCollection)
        .doc(user?.uid ?? uuid);

    final docSnapshot = await docRef.get();
    Map<String, dynamic> data = docSnapshot.data() ?? {};

    // Collect only the fields that are absent
    final Map<String, dynamic> fieldsToSet = {};
    fields.forEach((key, value) {
      if (!data.containsKey(key)) {
        fieldsToSet[key] = value;
      }
    });

    // Only update Firestore if there's something new to set
    if (fieldsToSet.isNotEmpty) {
      await docRef.set(fieldsToSet, SetOptions(merge: true));
    }
  }

  Future<void> createFirebaseUtilityDataForFieldIfNotExists({
    required String fieldName,
    required dynamic newValue,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && HiveBoxFunctions().getUuid().isEmpty) {
      AppLogger.e("User not logged in to create utility data if not exists");
      return; // User not logged in
    }

    final docRef = FirebaseFirestore.instance
        .collection(FirestoreVariables.utilitiesCollection)
        .doc(user?.uid ?? HiveBoxFunctions().getUuid());

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({fieldName: newValue}, SetOptions(merge: true));
    } else {
      final data = docSnapshot.data();
      if (data == null || !data.containsKey(fieldName)) {
        await docRef.set({fieldName: newValue}, SetOptions(merge: true));
      }
    }
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

  Future<void> setRechargeFalseIfRechargeExpires({
    required BuildContext context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && HiveBoxFunctions().getUuid().isEmpty) return;

    final utilityDocRef = FirebaseFirestore.instance
        .collection(FirestoreVariables.utilitiesCollection)
        .doc(user?.uid ?? HiveBoxFunctions().getUuid());

    final subscription = await SubscriptionFirestoreFunction()
        .getFirebaseUserSubscription();

    DateTime serverCurrentTime =
        await MyAppEndpoints.instance().getNetworkTime() ?? DateTime.now();

    if (subscription == null) {
      // this thing is to handel edge case in which recharge will set to false.
      checkAndChangeRechargeStatus(
        docRef: utilityDocRef,
        isGracePeriodActive: false,
        subscription: SubscriptionCollectionOfUser(
          status: SubscriptionStatus.nullStatus,
          uid: user?.uid ?? HiveBoxFunctions().getUuid(),
        ),
        newSubscriptionCreationCallback: () {
          context
              .read<PlanPurchaseCubit>()
              .newSubscriptionCreationAndStoreCallback();
        },
      );
      AppLogger.e(
        "No subscription collection of user found for user ${user?.uid}",
      );
      return;
    }

    if (subscription.currentStart!.isAfter(serverCurrentTime)) {
      checkAndChangeRechargeStatus(
        docRef: utilityDocRef,
        isGracePeriodActive: false,
        subscription: subscription,
        newSubscriptionCreationCallback: () {
          context
              .read<PlanPurchaseCubit>()
              .newSubscriptionCreationAndStoreCallback();
        },
      );
      return;
    } else {
      checkAndChangeRechargeStatus(
        docRef: utilityDocRef,
        isGracePeriodActive: true,
        subscription: subscription,
        newSubscriptionCreationCallback: () {
          context
              .read<PlanPurchaseCubit>()
              .newSubscriptionCreationAndStoreCallback();
        },
      );
      return;
    }
  }

  void checkAndChangeRechargeStatus({
    required DocumentReference docRef,
    required bool isGracePeriodActive,
    required SubscriptionCollectionOfUser subscription,
    required Function() newSubscriptionCreationCallback,
  }) async {
    try {
      final bool hasSubscription;
      bool isNewSubscriptionStatusRequired = false;

      FirebaseUser? loggedInUncheckFirebaseUser = HiveBoxFunctions()
          .getLoginDetails();
      if (loggedInUncheckFirebaseUser == null) {
        hasSubscription = false;
      } else if (loggedInUncheckFirebaseUser.subscriptionId == null ||
          loggedInUncheckFirebaseUser.subscriptionId!.trim() == '' ||
          loggedInUncheckFirebaseUser.subscriptionId!.contains(
            'no subscriptions',
          )) {
        hasSubscription = false;
        isNewSubscriptionStatusRequired = true;
      } else {
        SubscriptionStatus subscriptionStatus = subscription.status;

        switch (subscriptionStatus) {
          case SubscriptionStatus.active:
            hasSubscription = true;
            break;

          case SubscriptionStatus.cancelled:
            hasSubscription = false;
            isNewSubscriptionStatusRequired = true;
            break;

          case SubscriptionStatus.payment_captured:
            hasSubscription = true;
            break;

          case SubscriptionStatus.nullStatus:
            hasSubscription = false;
            isNewSubscriptionStatusRequired = true;
            break;

          case SubscriptionStatus.created:
            hasSubscription = false;
            break;

          case SubscriptionStatus.subscription_authenticated:
            if (isGracePeriodActive) {
              hasSubscription = true;
              await docRef.set({
                FirestoreVariables.isFreeTrialOpted: true,
              }, SetOptions(merge: true));
            } else {
              hasSubscription = false;
            }
            break;

          case SubscriptionStatus.halted:
            hasSubscription = false;
            isNewSubscriptionStatusRequired = true;
            break;
        }
      }
      // Its not dead code for ide i wrote this so it wont give me warning.
      // ignore: dead_code
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

      if (isNewSubscriptionStatusRequired) {
        await newSubscriptionCreationCallback();
      }
    } catch (e) {
      AppLogger.e("Error while setting isRecharge: $e");
    }
  }
}

extension on Response {
  void operator [](String other) {}
}
