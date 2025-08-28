import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sermon/services/firebase/models/transition_model.dart';
import 'package:sermon/services/firebase/models/utility_model.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import '../../../../services/firebase/utils_management/utils_functions.dart';
import 'bottom_nav_second_state.dart';

class BottomNavSecondCubit extends Cubit<BottomNavSecondState> {
  BottomNavSecondCubit() : super(BottomNavSecondState(utilityModel: null));

  Future<void> initProfile() async {
    await UtilsFunctions()
        .getFirebaseUtility(
          userId:
              FirebaseAuth.instance.currentUser?.uid ??
              HiveBoxFunctions().getUuid(),
        )
        .then((value) {
          print('utilityModel is: $value');
          // state.copyWith(utilityModel: value);
          emit(state.copyWith(utilityModel: value));
        })
        .catchError((error) {
          // Handle error if needed
          print("Error fetching utility data: $error");
          emit(state.copyWith(utilityModel: null));
        });
  }
}
