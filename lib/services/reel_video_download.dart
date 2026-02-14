import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sermon/reusable/logger_service.dart';

class ReelVideoDownloader {
  final Dio _dio = Dio();

  Future<File> getCachedOrDownload({
    required String videoUrl,
    required String reelId,
    void Function(int, int)? onProgress,
  }) async {
    final dir = await getTemporaryDirectory();

    final reelDir = Directory('${dir.path}/reels_cache');

    if (!await reelDir.exists()) {
      await reelDir.create(recursive: true);
    }

    final filePath = '${reelDir.path}/reel_$reelId.mp4';
    final file = File(filePath);

    // 🚀 FAST PATH
    if (await file.exists() && await file.length() > 0) {
      return file;
    }

    await _dio.download(
      videoUrl,
      filePath,
      onReceiveProgress: onProgress,
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    return file;
  }

  Future<File?> getCachedFile(String reelId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/reels/$reelId.mp4');

    return file.existsSync() ? file : null;
  }

  Future<void> clearAllCachedReels() async {
    try {
      final dir = await getTemporaryDirectory();
      final reelDir = Directory('${dir.path}/reels_cache');

      if (await reelDir.exists()) {
        await reelDir.delete(recursive: true);
      }
    } catch (e) {
      AppLogger.e('Error clearing reel cache: $e');
    }
  }
}
