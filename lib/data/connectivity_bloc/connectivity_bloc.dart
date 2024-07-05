import 'package:alrino/data/api/api.dart';
import 'package:alrino/data/local_data.dart';
import 'package:alrino/domain/models/document.dart';
import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/models/response_api.dart';
import 'package:alrino/domain/models/sz/file.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  bool isConnection;
  ConnectivityBloc(this.isConnection)
      : super(ConnectivityState.initial(isConnection)) {
    on<ConnectionEvent>(_onConnectionEvent);
  }

  /// при изменении интернета, передаем отложенные данные на сервер
  void _onConnectionEvent(
      ConnectionEvent event, Emitter<ConnectivityState> emit) async {
    emit(state.copyWith(isConnection: event.isConnection));
    if (Get.find<UserRepository>().user.token.isEmpty) return;
    List<TypeApi> typeApi = Get.find<UserRepository>().typeApi;
    if (event.isConnection && typeApi.isNotEmpty) {
      List dataArr = Get.find<UserRepository>().dataArr;
      emit(state.copyWith(isLoading: true));
      await Get.find<MainRepository>().updateServer();
      for (int index = 0; index < typeApi.length; index++) {
        final apiType = typeApi[index];
        final data = dataArr[index];
        final ResponseApi answer = await apiType.getApi(data);
        if (answer is ResSuccess) {
        } else if (answer is ResError) {
          Logger.e('Ошибка при отправке на сервер: ${answer.errorMessage}');
        }
      }
      Get.find<UserRepository>().dateClear();
      emit(state.copyWith(isLoading: false));
    } else {
      // showErrorDialog(
      //     'Данные были сохранены, как только будет подключение к серверу, файл будет загружен на сервер');
    }
  }

  /// добавляем отложенную передачу данных на сервер
}
