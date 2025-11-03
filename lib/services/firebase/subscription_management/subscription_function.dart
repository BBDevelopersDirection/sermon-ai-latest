import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sermon/main.dart';
import 'package:sermon/reusable/logger_service.dart';
import 'package:sermon/services/firebase/firestore_variables.dart';
import 'package:sermon/services/firebase/models/subscription_model.dart';
import 'package:sermon/services/firebase/models/user_models.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';

class SubscriptionFirestoreFunction {
  Future<SubscriptionStatus> getFirebaseUserSubscriptionStatus({
    required String subscriptionId,
  }) async {
    try {
      String _subscriptionCollection = isDebugMode()
          ? FirestoreVariables.subscriptionCollectionTest
          : FirestoreVariables.subscriptionCollection;

      final user = FirebaseAuth.instance.currentUser;
      final userDoc = await FirebaseFirestore.instance
          .collection(_subscriptionCollection)
          .doc(subscriptionId)
          .get();
      if (userDoc.exists) {
        SubscriptionCollectionOfUser subscriptionCollectionOfUser =
            SubscriptionCollectionOfUser.fromJson(userDoc.data()!);
        return subscriptionCollectionOfUser.status;
      }
      return SubscriptionStatus.nullStatus; // Placeholder return value
    } catch (e) {
      AppLogger.e('Error in getting SubscriptionStatus');
      return SubscriptionStatus.nullStatus;
    }
  }

  Future<SubscriptionCollectionOfUser?> getFirebaseUserSubscription() async {
    FirebaseUser? firebaseUser = HiveBoxFunctions().getLoginDetails();

    if (firebaseUser == null ||
        firebaseUser.subscriptionId == null ||
        firebaseUser.subscriptionId!.trim() == '' ||
        firebaseUser.subscriptionId!.contains('no subscriptions')) {
      AppLogger.e('No subscription id for user ${firebaseUser?.uid}');
      return null;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection(FirestoreVariables.subscriptionCollection)
        .doc(firebaseUser.subscriptionId)
        .get();
    if (userDoc.exists) {
      return SubscriptionCollectionOfUser.fromJson(userDoc.data()!);
    }
    return null;
  }
}
