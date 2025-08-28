import 'package:hive/hive.dart';
import 'package:sermon/services/firebase/firestore_variables.dart';
import 'package:uuid/uuid.dart';

import '../firebase/models/user_models.dart';
import '../firebase/models/utility_model.dart';
import 'hive_box_variables.dart';

class HiveBoxFunctions {

  Future<void> init() async {
    await Hive.openBox<Map>(HiveBoxVariables.boxName); // Open as a Map box
  }

  Future<void> saveLoginDetails(FirebaseUser details) async {
    final box = Hive.box<Map>(HiveBoxVariables.boxName);
    await box.put(HiveBoxVariables.key, details.toMap());
  }

  Future<void> saveTransitionDetails(UtilityModel details) async {
    final box = Hive.box<Map>(HiveBoxVariables.transitionBoxName);
    await box.put(HiveBoxVariables.key, details.toMap());
  }

  Future<void> removeLoginDetails() async {
    final box = Hive.box<Map>(HiveBoxVariables.boxName);
    await box.delete(HiveBoxVariables.key);
  }

  bool isLoginPresent() {
    final box = Hive.box<Map>(HiveBoxVariables.boxName);
    return box.containsKey(HiveBoxVariables.key);
  }

  FirebaseUser? getLoginDetails() {
    final box = Hive.box<Map>(HiveBoxVariables.boxName);
    final data = box.get(HiveBoxVariables.key);
    if (data != null) {
      return FirebaseUser.fromMap(Map<String, dynamic>.from(data));
    }
    return null;
  }

  // create a function to get uuid
  String getUuid() {
    final box = Hive.box<Map>(HiveBoxVariables.boxName);
    final data = box.get(HiveBoxVariables.key);
    if (data != null) {
      return data[FirestoreVariables.userIdField];
    }
    return '';
  }

  // create a function to get uuid using phoneNumber
  String getUuidByPhone({required String phoneNumber}) {
    final uuid = Uuid();
    // Generate a v5 (namespace) UUID using a constant namespace UUID and the phone number
    // Using DNS namespace as a constant namespace for consistency
    return uuid.v5(Uuid.NAMESPACE_DNS, phoneNumber);
  }

  Future<void> updateLoginDetails({
    String? name,
    String? email,
    String? phone,
    String? userId,
  }) async {
    final current = getLoginDetails();
    if (current != null) {
      final updated = FirebaseUser(
        name: name ?? current.name,
        email: email ?? current.email,
        phoneNumber: phone ?? current.phoneNumber,
        uid: userId ?? current.uid,
      );
      await saveLoginDetails(updated);
    }
  }
}
