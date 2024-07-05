import 'package:alrino/domain/models/user.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:get/get.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.initial()) {
    on<UpdateServerEvent>(_onUpdateServerEvent);
    on<SetIsProcessEvent>(_onSetIsProcessEvent);
  }

  /// переключаем режим фрд, фхн на данные с process
  void _onSetIsProcessEvent(SetIsProcessEvent event, Emitter<MainState> emit) {
    User user = Get.find<UserRepository>().user;
    user.isProcess = !user.isProcess;
    Get.find<UserRepository>().saveUserToLocal();
    emit(state.copyWith(isProcess: user.isProcess));
  }

  /// обновляем данные с сервера
  void _onUpdateServerEvent(
      UpdateServerEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    bool isInternet = true;
    try {
      isInternet = await Get.find<FlutterNetworkConnectivity>()
          .isInternetConnectionAvailable();
    } catch (e) {
      Logger.e('isInternetConnectionAvailable $e');
      emit(state.copyWith(
          isLoading: false, error: 'Нет интернета, попробуйте позже'));
      await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(error: ''));
    }
    if (isInternet) {
      await Get.find<MainRepository>().updateServer();
      emit(state.copyWith(isLoading: false));
    } else {
      emit(state.copyWith(
          isLoading: false, error: 'Нет интернета, попробуйте позже'));
      await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(error: ''));
    }
  }
}
