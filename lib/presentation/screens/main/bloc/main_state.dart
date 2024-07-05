part of 'main_bloc.dart';

class MainState {
  final bool isLoading;
  final String error;
  final bool isProcess;

  MainState(
      {required this.isLoading, required this.error, required this.isProcess});

  MainState copyWith({bool? isLoading, String? error, bool? isProcess}) {
    return MainState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        isProcess: isProcess ?? this.isProcess);
  }

  factory MainState.initial() => MainState(
        isLoading: false,
        error: '',
        isProcess: Get.find<UserRepository>().user.isProcess,
      );
}
