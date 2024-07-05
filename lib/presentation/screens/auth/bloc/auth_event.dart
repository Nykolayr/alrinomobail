part of 'auth_bloc.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// авторизация по логину и паролю
class AuthUserEvent extends AuthEvent {
  final String login;
  final String pass;
  const AuthUserEvent({required this.login, required this.pass});
}
