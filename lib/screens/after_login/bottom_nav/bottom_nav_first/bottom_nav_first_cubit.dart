import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'bottom_nav_first_state.dart';

class BottomNavFirstCubit extends Cubit<BottomNavFirstState> {
  BottomNavFirstCubit() : super(BottomNavFirstInitial());
}
