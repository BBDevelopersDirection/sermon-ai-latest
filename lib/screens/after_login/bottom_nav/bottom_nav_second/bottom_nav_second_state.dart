import 'package:equatable/equatable.dart';
import 'package:sermon/services/firebase/models/utility_model.dart';

import '../../../../services/firebase/models/transition_model.dart';

class BottomNavSecondState extends Equatable {
  UtilityModel? utilityModel;

  BottomNavSecondState({required this.utilityModel});

  BottomNavSecondState copyWith({
    UtilityModel? utilityModel,
  }) {
    return BottomNavSecondState(
      utilityModel:
      utilityModel ?? this.utilityModel,
    );
  }

  @override
  List<Object?> get props => [utilityModel];
}
