import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_variables.dart';
import '../models/user_models.dart';

class FirestoreFunctions {

  Future<FirebaseUser?> getFirebaseUser({required String userId}) async {
    final userDoc = await FirebaseFirestore.instance
        .collection(FirestoreVariables.usersCollection)
        .doc(userId)
        .get();
    if (userDoc.exists) {
      return FirebaseUser.fromJson(userDoc.data()!);
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
    }, SetOptions(merge: true));
  }
}
