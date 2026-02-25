import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon_tv/reusable/logger_service.dart';
import 'package:sermon_tv/screens/after_login/bottom_nav/bottom_nav_zero/bottom_nav_zero_state.dart';
import 'package:sermon_tv/services/firebase/models/meels_model.dart';
import 'package:sermon_tv/services/firebase/reels_management/reels_functions.dart';
import 'package:sermon_tv/services/hive_box/hive_box_functions.dart';
import 'package:sermon_tv/services/shared_pref/shared_preference.dart';

class _UniqueFetchResult {
  final List<ReelsModel> reels;
  final bool hasMore;
  final String? lastDocId;

  const _UniqueFetchResult({
    required this.reels,
    required this.hasMore,
    required this.lastDocId,
  });
}

class BottomNavZeroCubit extends Cubit<BottomNavZeroState> {
  final ReelsFirestoreFunctions firestoreFunctions;
  static const int _pageSize = 5;

  BottomNavZeroCubit({required this.firestoreFunctions})
    : super(const BottomNavZeroState());

  Future<void> refreshUniqueReels() async {
    emit(state.copyWith(reels: [], lastDocId: null, hasMore: true));
    await fetchReels(loadMore: false, resetIfExhausted: true);
  }

  Future<void> fetchReels({
    bool loadMore = false,
    bool resetIfExhausted = false,
  }) async {
    if (state.isLoading || (!state.hasMore && loadMore)) {
      AppLogger.d(
        "⏸ Skipping fetch | isLoading: ${state.isLoading}, hasMore: ${state.hasMore}, loadMore: $loadMore",
      );
      return;
    }

    emit(state.copyWith(isLoading: true));
    AppLogger.d(
      "🚀 Fetching reels | loadMore: $loadMore | currentCount: ${state.reels.length}",
    );

    final userId = await _resolveUserId();
    final seenIds = await SharedPreferenceLogic.getSeenReelIds(userId: userId);
    final startAfterDocId = loadMore ? state.lastDocId : null;
    _UniqueFetchResult uniqueResult = await _collectUniqueReels(
      seenIds: seenIds,
      startAfterDocId: startAfterDocId,
    );

    if (uniqueResult.reels.isEmpty &&
        !uniqueResult.hasMore &&
        resetIfExhausted) {
      AppLogger.d("🔁 All reels seen. Resetting seen list and reshuffling.");
      await SharedPreferenceLogic.resetSeenReelIds(userId: userId);
      seenIds.clear();
      uniqueResult = await _collectUniqueReels(
        seenIds: seenIds,
        startAfterDocId: null,
      );
      uniqueResult.reels.shuffle(Random());
    }

    await SharedPreferenceLogic.addSeenReelIds(
      userId: userId,
      ids: uniqueResult.reels.map((reel) => reel.id),
    );

    AppLogger.d(
      "✅ Reels fetched: ${uniqueResult.reels.length} | lastDocId: ${uniqueResult.lastDocId}",
    );

    emit(
      state.copyWith(
        reels: loadMore
            ? [...state.reels, ...uniqueResult.reels]
            : uniqueResult.reels,
        lastDocId: uniqueResult.lastDocId,
        hasMore: uniqueResult.hasMore,
        isLoading: false,
      ),
    );

    AppLogger.d(
      "📊 State updated | totalReels: ${state.reels.length}, hasMore: ${state.hasMore}",
    );
  }

  Future<_UniqueFetchResult> _collectUniqueReels({
    required Set<String> seenIds,
    required String? startAfterDocId,
  }) async {
    List<ReelsModel> collected = [];
    bool hasMore = true;
    String? lastDocId = startAfterDocId;

    while (collected.length < _pageSize && hasMore) {
      final result = await firestoreFunctions.fetchReels(
        limit: _pageSize,
        startAfterDocId: lastDocId,
      );
      hasMore = result.hasMore;
      lastDocId = result.lastDocId;

      final unseen = result.reels.where((reel) => !seenIds.contains(reel.id));
      collected.addAll(unseen);

      if (result.reels.isEmpty) {
        break;
      }
    }

    return _UniqueFetchResult(
      reels: collected.take(_pageSize).toList(),
      hasMore: hasMore,
      lastDocId: lastDocId,
    );
  }

  Future<String> _resolveUserId() async {
    final authId = FirebaseAuth.instance.currentUser?.uid;
    if (authId != null && authId.isNotEmpty) {
      return authId;
    }
    final hiveId = HiveBoxFunctions().getUuid();
    if (hiveId.isNotEmpty) {
      return hiveId;
    }
    return SharedPreferenceLogic().getUserId();
  }
}
