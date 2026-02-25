import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sermon_tv/services/hive_box/hive_box_functions.dart';
import '../../../../services/firebase/utils_management/utils_functions.dart';
import 'package:sermon_tv/reusable/logger_service.dart';
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
          AppLogger.d('utilityModel is: $value');
          // state.copyWith(utilityModel: value);
          emit(state.copyWith(utilityModel: value));
        })
        .catchError((error) {
          // Handle error if needed
          AppLogger.e("Error fetching utility data: $error");
          emit(state.copyWith(utilityModel: null));
        });
  }
}
