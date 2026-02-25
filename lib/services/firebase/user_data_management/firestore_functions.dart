import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sermon_tv/services/hive_box/hive_box_functions.dart';

import '../../../reusable/logger_service.dart';
import '../firestore_variables.dart';
import '../models/user_models.dart';

class FirestoreFunctions {
  Future<FirebaseUser?> getFirebaseUser({required String userId}) async {
    final userDoc = await FirebaseFirestore.instance
        .collection(FirestoreVariables.usersCollection)
        .doc(userId)
        .get();
    if (userDoc.exists) {
      FirebaseUser firebaseUser = FirebaseUser.fromJson(userDoc.data()!);
      HiveBoxFunctions().saveLoginDetails(
        FirebaseUser(
          uid: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber,
          name: firebaseUser.name,
          email: firebaseUser.email,
          subscriptionId: firebaseUser.subscriptionId,
          createdDate: firebaseUser.createdDate,
        ),
      );
      return firebaseUser;
    }
    return null; // Placeholder return value
  }

  Future<FirebaseUser?> getFirebaseUserByNumber({
  required String number,
}) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirestoreVariables.usersCollection)
        .where(FirestoreVariables.phoneField, isEqualTo: '+91$number')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final firebaseUser = FirebaseUser.fromJson(doc.data());

      // Save details in Hive
      HiveBoxFunctions().saveLoginDetails(
        FirebaseUser(
          uid: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber,
          name: firebaseUser.name,
          email: firebaseUser.email,
          subscriptionId: firebaseUser.subscriptionId,
          createdDate: firebaseUser.createdDate,
        ),
      );

      return firebaseUser;
    }

    return null; // No user found
  } catch (e) {
    AppLogger.e('❌ Error getting Firebase user by number: $e');
    return null;
  }
}


  // Example function to set user data
  Future<void> newFirebaseUserData({required FirebaseUser firebaseUser}) async {
    await FirebaseFirestore.instance
        .collection(FirestoreVariables.usersCollection)
        .doc(firebaseUser.uid)
        .set({
          FirestoreVariables.userIdField: firebaseUser.uid,
          FirestoreVariables.emailField: firebaseUser.email,
          FirestoreVariables.phoneField: firebaseUser.phoneNumber,
          FirestoreVariables.nameField: firebaseUser.name,
          FirestoreVariables.createdDateField: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> ensureCreatedDateExists({required String userId}) async {
    final CollectionReference usersRef = FirebaseFirestore.instance.collection(
      FirestoreVariables.usersCollection,
    );

    final userDoc = await usersRef.doc(userId).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;

      if (data[FirestoreVariables.createdDateField] == null) {
        await usersRef.doc(userId).set({
          FirestoreVariables.createdDateField: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> updateOrSaveSubscriptionIdFirestoreData({
    required String subscriptionId,
  }) async {
    await FirebaseFirestore.instance
        .collection(FirestoreVariables.usersCollection)
        .doc(
          FirebaseAuth.instance.currentUser?.uid ??
              HiveBoxFunctions().getUuid(),
        )
        .set(
          {FirestoreVariables.subscriptionIdField: subscriptionId},
          SetOptions(merge: true), // update if exists, create if not
        );

    await getFirebaseUser(
      userId:
          FirebaseAuth.instance.currentUser?.uid ??
          HiveBoxFunctions().getUuid(),
    );
  }
}
