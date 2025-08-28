import '../firestore_variables.dart';

class TransactionModelFirebase {
  final String transactionId;
  final double amount;
  final String createdAt;
  final String updatedAt;
  final String userId;

  TransactionModelFirebase({
    required this.transactionId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory TransactionModelFirebase.fromJson(Map<String, dynamic> json) {
    return TransactionModelFirebase(
      transactionId: json[FirestoreVariables.transactionIdField] as String,
      amount: (json[FirestoreVariables.amountField] as num).toDouble(),
      createdAt: json[FirestoreVariables.createdAtField] as String,
      updatedAt: json[FirestoreVariables.updatedAtField] as String,
      userId: json[FirestoreVariables.userIdField] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreVariables.transactionIdField: transactionId,
      FirestoreVariables.amountField: amount,
      FirestoreVariables.createdAtField: createdAt,
      FirestoreVariables.updatedAtField: updatedAt,
      FirestoreVariables.userIdField: userId,
    };
  }

  // Convert to Map (for Hive)
  Map<String, dynamic> toMap() {
    return {
      FirestoreVariables.transactionIdField: transactionId,
      FirestoreVariables.amountField: amount,
      FirestoreVariables.createdAtField: createdAt,
      FirestoreVariables.updatedAtField: updatedAt,
      FirestoreVariables.userIdField: userId,
    };
  }

  // Create from Map
  factory TransactionModelFirebase.fromMap(Map<String, dynamic> map) {
    return TransactionModelFirebase(
      transactionId: map[FirestoreVariables.transactionIdField] as String,
      amount: (map[FirestoreVariables.amountField] as num).toDouble(),
      createdAt: map[FirestoreVariables.createdAtField] as String,
      updatedAt: map[FirestoreVariables.updatedAtField] as String,
      userId: map[FirestoreVariables.userIdField] as String,
    );
  }
}
