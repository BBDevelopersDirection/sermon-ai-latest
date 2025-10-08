import '../firestore_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // for Timestamp

class FirebaseUser {
  final String uid;
  final String email;
  final String phoneNumber;
  final String name;
  final String? subscriptionId;
  final DateTime createdDate;

  FirebaseUser({
    required this.uid,
    required this.email,
    required this.phoneNumber,
    required this.name,
    this.subscriptionId,
    required this.createdDate,
  });

  factory FirebaseUser.fromJson(Map<String, dynamic> json) {
    return FirebaseUser(
      uid: json[FirestoreVariables.userIdField] as String,
      email: json[FirestoreVariables.emailField] as String,
      phoneNumber: json[FirestoreVariables.phoneField] as String,
      name: json[FirestoreVariables.nameField] as String,
      subscriptionId: json[FirestoreVariables.subscriptionIdField] as String?,
      createdDate: json[FirestoreVariables.createdDateField] != null
          ? (json[FirestoreVariables.createdDateField] is Timestamp
                ? (json[FirestoreVariables.createdDateField] as Timestamp)
                      .toDate()
                : DateTime.tryParse(
                        json[FirestoreVariables.createdDateField].toString(),
                      ) ??
                      DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreVariables.userIdField: uid,
      FirestoreVariables.emailField: email,
      FirestoreVariables.phoneField: phoneNumber,
      FirestoreVariables.nameField: name,
      FirestoreVariables.subscriptionIdField: subscriptionId,
      FirestoreVariables.createdDateField: Timestamp.fromDate(createdDate),
    };
  }

  // Convert to Map (for Hive)
  Map<String, dynamic> toMap() {
    return {
      FirestoreVariables.nameField: name,
      FirestoreVariables.emailField: email,
      FirestoreVariables.phoneField: phoneNumber,
      FirestoreVariables.userIdField: uid,
      FirestoreVariables.subscriptionIdField: subscriptionId,
      FirestoreVariables.createdDateField: createdDate.toIso8601String(),
    };
  }

  // Create from Map
  factory FirebaseUser.fromMap(Map<String, dynamic> map) {
    return FirebaseUser(
      name: map[FirestoreVariables.nameField],
      email: map[FirestoreVariables.emailField],
      phoneNumber: map[FirestoreVariables.phoneField],
      uid: map[FirestoreVariables.userIdField],
      subscriptionId: map[FirestoreVariables.subscriptionIdField],
      createdDate: map[FirestoreVariables.createdDateField] != null
          ? DateTime.tryParse(
                  map[FirestoreVariables.createdDateField].toString(),
                ) ??
                DateTime.now()
          : DateTime.now(),
    );
  }
}
