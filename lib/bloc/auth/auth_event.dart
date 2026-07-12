import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRefreshRequested extends AuthEvent {
  const AuthRefreshRequested();
}

class AuthNameUpdateRequested extends AuthEvent {
  final String name;

  const AuthNameUpdateRequested({required this.name});

  @override
  List<Object?> get props => [name];
}

class AuthSettingsUpdateRequested extends AuthEvent {
  final List<int> notificationDaysBefore;
  final bool expiryNotificationsEnabled;
  final String themeMode;

  const AuthSettingsUpdateRequested({
    required this.notificationDaysBefore,
    required this.expiryNotificationsEnabled,
    required this.themeMode,
  });

  @override
  List<Object?> get props => [
    notificationDaysBefore,
    expiryNotificationsEnabled,
    themeMode,
  ];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
