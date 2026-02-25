import 'package:sermon_tv/reusable/logger_service.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  late final AppLinks _appLinks;
  late final StreamController<String> _deepLinkController;
  late final Stream<String> deepLinkStream;

  factory DeepLinkService() {
    return _instance;
  }

  DeepLinkService._internal() {
    _appLinks = AppLinks();
    _deepLinkController = StreamController<String>.broadcast();
    deepLinkStream = _deepLinkController.stream;
  }

  String? _pendingDeepLink;

  String? get pendingDeepLink => _pendingDeepLink;

  Future<void> initialize() async {
    try {
      // Check for initial deep link when app starts
      try {
        final initialLink = await _appLinks.getInitialLink();
        if (initialLink != null) {
          AppLogger.d('Initial deep link: $initialLink');
          _handleDeepLink(initialLink.toString());
        }
      } catch (e) {
        AppLogger.e('Error getting initial link: $e');
      }

      // Handle deep links when app is already running
      _appLinks.uriLinkStream.listen(
        (Uri link) {
          AppLogger.d('Deep link received while app running: $link');
          _handleDeepLink(link.toString());
          // Broadcast to all listeners
          _deepLinkController.add(link.toString());
        },
        onError: (err) {
          AppLogger.e('Deep link error: $err');
        },
      );
    } catch (e) {
      AppLogger.e('Error initializing deep link service: $e');
    }
  }

  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      // Extract the path parameter from URL like https://sermontv.usedirection.com/snjsjxnjnxsj
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        _pendingDeepLink = pathSegments.first;
        AppLogger.d('Extracted deep link parameter: $_pendingDeepLink');
      }
    } catch (e) {
      AppLogger.e('Error parsing deep link: $e');
    }
  }

  String? consumePendingDeepLink() {
    final link = _pendingDeepLink;
    _pendingDeepLink = null;
    return link;
  }
  
  String? extractPathFromLink(String link) {
    try {
      final uri = Uri.parse(link);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.first;
      }
    } catch (e) {
      AppLogger.e('Error extracting path from link: $e');
    }
    return null;
  }
}
