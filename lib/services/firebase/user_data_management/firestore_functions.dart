import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';

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
