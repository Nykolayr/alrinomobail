import 'package:alrino/data/api/dio_client.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState.initial()) {
    on<AuthUserEvent>(_onAuthEvent);
  }

  /// авторизация по логину и паролю
  Future<void> _onAuthEvent(
      AuthUserEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    final answer = await Get.find<UserRepository>()
        .authUser(login: event.login, pass: event.pass);
    emit(state.copyWith(
      isLoading: false,
    ));
    if (answer.isEmpty) {
      emit(state.copyWith(isSucsess: true));
      Get.find<DioClient>().options.headers!['Authorization'] =
          'Bearer ${Get.find<UserRepository>().token}';
      Get.find<MainRepository>().init();
      Get.find<FrdRepository>().init();
      Get.find<FhnRepository>().init();
    } else {
      emit(state.copyWith(error: answer));
    }
  }
}
