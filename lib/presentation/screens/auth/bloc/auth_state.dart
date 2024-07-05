part of 'auth_bloc.dart';

class AuthState {
  final String login;
  final String pass;
  final String error;
  final bool isSucsess;
  final bool isLoading;

  const AuthState({
    required this.login,
    required this.pass,
    required this.error,
    required this.isLoading,
    required this.isSucsess,
  });

  factory AuthState.initial() => const AuthState(
        login: '',
        pass: '',
        error: '',
        isLoading: false,
        isSucsess: false,
      );
  AuthState copyWith({
    String? login,
    String? pass,
    String? error,
    bool? isSucsess,
    bool? isLoading,
  }) {
    return AuthState(
      login: login ?? this.login,
      pass: pass ?? this.pass,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      isSucsess: isSucsess ?? this.isSucsess,
    );
  }
}
