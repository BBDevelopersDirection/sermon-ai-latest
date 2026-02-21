import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sermon/reusable/logger_service.dart';

class ReelVideoDownloader {
  final Dio _dio = Dio();
  Directory? _reelCacheDir;

  Future<Directory> _getReelCacheDir() async {
    if (_reelCacheDir != null) return _reelCacheDir!;
    final dir = await getTemporaryDirectory();
    _reelCacheDir = Directory('${dir.path}/reels_cache');
    if (!await _reelCacheDir!.exists()) {
      await _reelCacheDir!.create(recursive: true);
    }
    return _reelCacheDir!;
  }

  Future<bool> reelExistsInCache(String reelId) async {
    final reelCacheDir = await _getReelCacheDir();
    final reelCachePath = '${reelCacheDir.path}/reel_$reelId.mp4';
    final reelFile = File(reelCachePath);

    if (await reelFile.exists() && await reelFile.length() > 0) {
      return true;
    }
    return false;
  }

  /// Returns the cached reel file. Must only be called after [reelExistsInCache]
  /// has returned true or after [getReel] has ensured the cache dir is ready.
  File getCachedReel(String reelId) {
    final reelCachePath = '${_reelCacheDir!.path}/reel_$reelId.mp4';
    return File(reelCachePath);
  }

  Future<File> getReel(
    String reelId,
    String videoUrl, {
    void Function(int, int)? onProgress,
  }) async {
    final reelCacheDir = await _getReelCacheDir();
    if (await reelExistsInCache(reelId)) {
      return getCachedReel(reelId);
    }
    return downloadReelAndAddToCache(
      videoUrl: videoUrl,
      filePath: '${reelCacheDir.path}/reel_$reelId.mp4',
      onProgress: onProgress,
    );
  }

  Future<File> downloadReelAndAddToCache({
    required String videoUrl,
    required String filePath,
    void Function(int, int)? onProgress,
  }) async {
    await _dio.download(
      videoUrl,
      filePath,
      onReceiveProgress: onProgress,
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    return File(filePath);
  }

  Future<File?> getCachedFile(String reelId) async {
    final reelCacheDir = await _getReelCacheDir();
    final file = File('${reelCacheDir.path}/reel_$reelId.mp4');
    if (await file.exists() && await file.length() > 0) {
      return file;
    }
    return null;
  }

  Future<void> clearAllCachedReels() async {
    try {
      final reelCacheDir = await _getReelCacheDir();
      if (await reelCacheDir.exists()) {
        await reelCacheDir.delete(recursive: true);
      }
    } catch (e) {
      AppLogger.e('Error clearing reel cache: $e');
    }
  }
}
