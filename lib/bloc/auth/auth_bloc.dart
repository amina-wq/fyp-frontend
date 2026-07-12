import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/notifications/fcm_service.dart';
import '../../repositories/auth/auth_repository_interface.dart';
import '../../core/logging/app_logger.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryInterface _authRepository;
  final FcmService _fcmService;

  AuthBloc({
    required AuthRepositoryInterface authRepository,
    required FcmService fcmService,
  }) : _authRepository = authRepository,
       _fcmService = fcmService,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRefreshRequested>(_onAuthRefreshRequested);
    on<AuthNameUpdateRequested>(_onAuthNameUpdateRequested);
    on<AuthSettingsUpdateRequested>(_onAuthSettingsUpdateRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    AppLogger.info('Auth check started.', name: 'AuthBloc');

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (!isLoggedIn) {
        AppLogger.info(
          'Auth check completed: user is not logged in.',
          name: 'AuthBloc',
        );
        emit(const AuthUnauthenticated());
        return;
      }

      final user = await _authRepository.getCurrentUser();

      await _fcmService.syncTokenWithBackend();

      AppLogger.info(
        'Auth check completed: user authenticated.',
        name: 'AuthBloc',
      );

      emit(AuthAuthenticated(user: user));
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Auth check failed. Logging user out.',
        name: 'AuthBloc',
        error: error,
        stackTrace: stackTrace,
      );

      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      final user = await _authRepository.getCurrentUser();

      await _fcmService.syncTokenWithBackend();

      AppLogger.info('User registration completed.', name: 'AuthBloc');

      emit(AuthAuthenticated(user: user));
    } catch (error) {
      AppLogger.error(
        'User registration failed.',
        name: 'AuthBloc',
        error: error,
      );

      emit(
        AuthFailure(message: error.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.login(email: event.email, password: event.password);

      final user = await _authRepository.getCurrentUser();

      await _fcmService.syncTokenWithBackend();

      AppLogger.info('User login completed.', name: 'AuthBloc');

      emit(AuthAuthenticated(user: user));
    } catch (error) {
      AppLogger.error('User login failed.', name: 'AuthBloc', error: error);

      emit(
        AuthFailure(message: error.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _onAuthRefreshRequested(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.refreshTokens();

      final user = await _authRepository.getCurrentUser();

      await _fcmService.syncTokenWithBackend();

      AppLogger.info('Auth refresh completed.', name: 'AuthBloc');

      emit(AuthAuthenticated(user: user));
    } catch (_) {
      AppLogger.warning(
        'Auth refresh failed. Logging user out.',
        name: 'AuthBloc',
      );

      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthNameUpdateRequested(
    AuthNameUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;

    if (currentState is! AuthAuthenticated) {
      return;
    }

    emit(AuthActionInProgress(user: currentState.user));

    try {
      final updatedUser = await _authRepository.updateName(name: event.name);

      AppLogger.info('User name updated.', name: 'AuthBloc');

      emit(AuthAuthenticated(user: updatedUser));
    } catch (error) {
      AppLogger.error(
        'User name update failed.',
        name: 'AuthBloc',
        error: error,
      );

      emit(AuthAuthenticated(user: currentState.user));

      emit(
        AuthFailure(message: error.toString().replaceFirst('Exception: ', '')),
      );

      emit(AuthAuthenticated(user: currentState.user));
    }
  }

  Future<void> _onAuthSettingsUpdateRequested(
    AuthSettingsUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;

    if (currentState is! AuthAuthenticated) {
      return;
    }

    emit(AuthActionInProgress(user: currentState.user));

    try {
      final updatedUser = await _authRepository.updateSettings(
        notificationDaysBefore: event.notificationDaysBefore,
        expiryNotificationsEnabled: event.expiryNotificationsEnabled,
        themeMode: event.themeMode,
      );

      AppLogger.info('User settings updated.', name: 'AuthBloc');

      emit(AuthAuthenticated(user: updatedUser));
    } catch (error) {
      AppLogger.error(
        'User settings update failed.',
        name: 'AuthBloc',
        error: error,
      );

      emit(AuthAuthenticated(user: currentState.user));

      emit(
        AuthFailure(message: error.toString().replaceFirst('Exception: ', '')),
      );

      emit(AuthAuthenticated(user: currentState.user));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();

    AppLogger.info('User logged out.', name: 'AuthBloc');

    emit(const AuthUnauthenticated());
  }
}
