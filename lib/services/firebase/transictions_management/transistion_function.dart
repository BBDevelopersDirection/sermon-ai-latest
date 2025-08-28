import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_variables.dart';
import '../models/transition_model.dart';

class TransistionFirestoreFunctions {
  // Example function to set user data
  Future<void> newFirebaseTransitionData({
    required TransactionModelFirebase firebaseTransition,
  }) async {
    await FirebaseFirestore.instance
        .collection(FirestoreVariables.transactionsCollection)
        .doc(firebaseTransition.transactionId)
        .set({
          FirestoreVariables.updatedAtField: firebaseTransition.updatedAt,
          FirestoreVariables.createdAtField: firebaseTransition.createdAt,
          FirestoreVariables.amountField: firebaseTransition.amount,
          FirestoreVariables.userIdField: firebaseTransition.userId,
        }, SetOptions(merge: true));
  }
}
