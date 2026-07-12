import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../repositories/auth/auth_repository_interface.dart';
import '../logging/app_logger.dart';

class FcmService {
  final AuthRepositoryInterface _authRepository;

  FirebaseMessaging? _firebaseMessaging;

  FcmService({required AuthRepositoryInterface authRepository})
    : _authRepository = authRepository;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    AppLogger.info('Firebase initialized.', name: 'FcmService');

    _firebaseMessaging = FirebaseMessaging.instance;

    await _requestPermission();
    _listenForTokenRefresh();
    _listenForForegroundMessages();
  }

  Future<void> syncTokenWithBackend() async {
    try {
      final messaging = _firebaseMessaging;

      if (messaging == null) {
        AppLogger.warning(
          'FCM token sync skipped because FirebaseMessaging is not initialized.',
          name: 'FcmService',
        );

        return;
      }

      final isLoggedIn = await _authRepository.isLoggedIn();

      if (!isLoggedIn) {
        AppLogger.info(
          'FCM token sync skipped because user is not logged in.',
          name: 'FcmService',
        );

        return;
      }

      final token = await messaging.getToken();

      if (token == null) {
        AppLogger.warning(
          'FCM token sync skipped because token is null.',
          name: 'FcmService',
        );

        return;
      }

      await _authRepository.updateFcmToken(fcmToken: token);

      AppLogger.info('FCM token synced with backend.', name: 'FcmService');
    } catch (error, stackTrace) {
      AppLogger.error(
        'FCM token sync failed.',
        name: 'FcmService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _requestPermission() async {
    final messaging = _firebaseMessaging;

    if (messaging == null) {
      return;
    }

    final settings = await messaging.requestPermission();

    AppLogger.info(
      'Notification permission status: ${settings.authorizationStatus.name}.',
      name: 'FcmService',
    );
  }

  void _listenForTokenRefresh() {
    final messaging = _firebaseMessaging;

    if (messaging == null) {
      return;
    }

    messaging.onTokenRefresh.listen((token) async {
      try {
        final isLoggedIn = await _authRepository.isLoggedIn();

        if (!isLoggedIn) {
          AppLogger.info(
            'FCM token refresh skipped because user is not logged in.',
            name: 'FcmService',
          );

          return;
        }

        await _authRepository.updateFcmToken(fcmToken: token);

        AppLogger.info(
          'Refreshed FCM token synced with backend.',
          name: 'FcmService',
        );
      } catch (error, stackTrace) {
        AppLogger.error(
          'Failed to sync refreshed FCM token.',
          name: 'FcmService',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
  }

  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      AppLogger.info(
        'Foreground push notification received: messageId=${message.messageId}.',
        name: 'FcmService',
      );
    });
  }
}
