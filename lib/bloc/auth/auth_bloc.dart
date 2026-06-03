import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth/auth_repository_interface.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryInterface _authRepository;

  AuthBloc({
    required AuthRepositoryInterface authRepository,
  })  : _authRepository = authRepository, super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRefreshRequested>(_onAuthRefreshRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (!isLoggedIn) {
        emit(const AuthUnauthenticated());
        return;
      }

      final user = await _authRepository.getCurrentUser();

      emit(AuthAuthenticated(user: user));
    } catch (_) {
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

      emit(AuthAuthenticated(user: user));
    } catch (error) {
      emit(
        AuthFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      final user = await _authRepository.getCurrentUser();

      emit(AuthAuthenticated(user: user));
    } catch (error) {
      emit(
        AuthFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
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

      emit(AuthAuthenticated(user: user));
    } catch (_) {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
      AuthLogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await _authRepository.logout();

    emit(const AuthUnauthenticated());
  }
}