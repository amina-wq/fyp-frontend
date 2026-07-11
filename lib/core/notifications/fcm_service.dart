import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../repositories/auth/auth_repository_interface.dart';

class FcmService {
  final AuthRepositoryInterface _authRepository;

  FirebaseMessaging? _firebaseMessaging;

  FcmService({
    required AuthRepositoryInterface authRepository,
  }) : _authRepository = authRepository;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    _firebaseMessaging = FirebaseMessaging.instance;

    await _requestPermission();
    _listenForTokenRefresh();
    _listenForForegroundMessages();
  }

  Future<void> syncTokenWithBackend() async {
    try {
      final messaging = _firebaseMessaging;

      if (messaging == null) {
        return;
      }

      final isLoggedIn = await _authRepository.isLoggedIn();

      if (!isLoggedIn) {
        return;
      }

      final token = await messaging.getToken();

      if (token == null) {
        return;
      }

      await _authRepository.updateFcmToken(
        fcmToken: token,
      );
    } catch (_) {
    }
  }

  Future<void> _requestPermission() async {
    final messaging = _firebaseMessaging;

    if (messaging == null) {
      return;
    }

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
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
          return;
        }

        await _authRepository.updateFcmToken(
          fcmToken: token,
        );
      } catch (_) {
      }
    });
  }

  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
    });
  }
}