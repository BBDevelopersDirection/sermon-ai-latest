import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await _setupMessageHandlers();
      await setupFlutterNotifications();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> requestPermissionAndGetToken() async {
    await _requestPermission();
    final token = await _messaging.getToken();
    await _messaging.subscribeToTopic('all');
    print('Fcm token: $token');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: true,
      carPlay: true,
      criticalAlert: false,
    );
    print('Permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

    const channel = AndroidNotificationChannel(
      'chat_notification',
      'Pastor Notification Channel',
      description: 'This channel is used to show pastor notification.',
      importance: Importance.max,
    );

    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettingsDarwin = DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  /// Unified method to display notification with optional image
  Future<void> showNotification(RemoteMessage message) async {
    final title = message.notification?.title;
    final body = message.notification?.body;
    final imageUrl = message.data['image'] ?? message.data['image_url'];

    BigPictureStyleInformation? bigPictureStyleInformation;
    List<DarwinNotificationAttachment> iosAttachments = [];

    // Load image if present
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final byteArray = response.bodyBytes;

          // Android big picture style
          bigPictureStyleInformation = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(byteArray),
            largeIcon: ByteArrayAndroidBitmap(byteArray),
            contentTitle: title,
            summaryText: body,
          );

          // iOS attachment
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/notification_image.png';
          final file = File(filePath);
          await file.writeAsBytes(byteArray);
          iosAttachments = [DarwinNotificationAttachment(filePath)];
        }
      } catch (e) {
        print('Failed to fetch image: $e');
      }
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'chat_notification',
        'Pastor Notification Channel',
        channelDescription: 'This channel is used to show pastor notifications.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        colorized: true,
        styleInformation: bigPictureStyleInformation,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: iosAttachments,
      ),
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  Future<void> _setupMessageHandlers() async {
    // Foreground
    FirebaseMessaging.onMessage.listen((message) async {
      print('[Foreground] Notification: ${message.notification?.title}');
      await showNotification(message);
    });

    // Background tapped
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('[Background - Tapped] Data: ${message.data}');
      _handleBackgroundMessage(message);
    });

    // App opened via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('[App Opened via Notification] Data: ${initialMessage.data}');
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Handling background notification: ${message.data}');
    if (message.data['type'] == 'chat') {
      // Handle chat-specific logic here
    }
  }
}
