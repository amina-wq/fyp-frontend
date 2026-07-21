// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: States for the authentication bloc.
// First Written on: Wednesday, 03-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:equatable/equatable.dart';

import '../../models/auth/auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthActionInProgress extends AuthState {
  final UserModel user;

  const AuthActionInProgress({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
