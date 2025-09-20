import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_zero/bottom_nav_zero_state.dart';
import 'package:sermon/services/firebase/reels_management/reels_functions.dart';

class BottomNavZeroCubit extends Cubit<BottomNavZeroState> {
  final ReelsFirestoreFunctions firestoreFunctions;

  BottomNavZeroCubit({required this.firestoreFunctions})
      : super(const BottomNavZeroState());

  Future<void> fetchReels({bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) {
      print("⏸ Skipping fetch | isLoading: ${state.isLoading}, hasMore: ${state.hasMore}, loadMore: $loadMore");
      return;
    }

    emit(state.copyWith(isLoading: true));
    print("🚀 Fetching reels | loadMore: $loadMore | currentCount: ${state.reels.length}");

    final result = await firestoreFunctions.fetchReels(
      limit: 5,
      startAfterDocId: loadMore ? state.lastDocId : null,
    );

    print("✅ Reels fetched: ${result.reels.length} | lastDocId: ${result.lastDocId}");

    emit(
      state.copyWith(
        reels: loadMore ? [...state.reels, ...result.reels] : result.reels,
        lastDocId: result.lastDocId,
        hasMore: result.hasMore,
        isLoading: false,
      ),
    );

    print("📊 State updated | totalReels: ${state.reels.length}, hasMore: ${state.hasMore}");
  }
}