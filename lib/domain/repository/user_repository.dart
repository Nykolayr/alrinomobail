// ignore_for_file: avoid_catches_without_on_clauses

import 'package:alrino/data/api/api.dart';
import 'package:alrino/data/connectivity_bloc/connectivity_bloc.dart';
import 'package:alrino/data/local_data.dart';
import 'package:alrino/domain/models/response_api.dart';
import 'package:alrino/domain/models/user.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';

/// репо для юзера
class UserRepository extends GetxController {
  User user = User.initial();
  List dataArr = [];
  List<TypeApi> typeApi = [];
  String get token => user.token;
  static final UserRepository _instance = UserRepository._internal();
  UserRepository._internal();
  factory UserRepository() => _instance;
  Future<bool> deleteUser() async {
    return false;
  }

  Future<bool> getUser() async {
    return false;
  }

  /// Начальная загрузка пользователя из локального хранилища
  Future init() async {
    await loadUserFromLocal();

    await loadTypeApi();

    /// загрузка отложенных данных из локального хранилища
    for (int index = 0; index < typeApi.length; index++) {
      final data = await typeApi[index].getFromLocal(index);

      dataArr.add(data);
    }
  }


  Future initUser() async {
    if (user.id.isNotEmpty) {
      bool status = await getUserStatus(id: user.id);
      if (!status) {
        user = User.initial();
        saveUserToLocal();
      }
    }
  }

  /// очищаем после отправки на сервер
  dateClear() {
    dataArr.clear();
    typeApi.clear();
    saveTypeApi();
  }

  saveData(TypeApi type, dynamic data) async {
    int index = typeApi.length;
    typeApi.add(type);
    await saveTypeApi();
    dataArr.add(data);
    await type.saveToLocal(data, index);
  }

  Future<bool> getUserStatus({required String id}) async {
    if (user.token.isEmpty) return false;
    final response = await Api().getUserStatusApi(id: id);

    if (response is ResSuccess) {
      return response.data == 0 ? false : true;
    }
    return true;
  }

  Future<String> loadUser({
    required String id,
  }) async {
    final ResponseApi answer = await Api().getUser(id: id);
    if (answer is ResSuccess) {
      if (answer.data['status'] == 0) {
        return 'Этому пользователю, закрыт вход в систему';
      }
      return '';
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  saveAudio(bool isPermissonAudio) {
    user.isPermissonAudio = isPermissonAudio;
    saveUserToLocal();
  }

  saveFile(bool isPermissonFile) {
    user.isPermissonFile = isPermissonFile;
    saveUserToLocal();
  }

  saveAudioFirst(bool isFirstAudio) {
    user.isFirstAudio = isFirstAudio;
    saveUserToLocal();
  }

  saveFileFirst(bool isFirstFile) {
    user.isFirstFile = isFirstFile;
    saveUserToLocal();
  }

  /// Удаление пользователя из локального хранилища и инициализация
  Future clearUser() async {
    await LocalData().clear();
    user = User.initial();
  }

  /// авторизация по логину и паролю, возвращает строку ошибки,
  /// если ошибки нет возвращается пустая строка
  Future<String> authUser({
    required String login,
    required String pass,
  }) async {
    user.token = 'begin';
    final ResponseApi answer = await Api().authUser(
      login: login,
      pass: pass,
    );
    if (answer is ResSuccess) {
      Logger.e(
          'authUser: ${answer.data['status']} ${answer.data['status'].runtimeType}');
      if (answer.data['status'] == 0) {
        return 'Этому пользователю, закрыт вход в систему';
      }
      user = User.fromJson(answer.data);
      saveUserToLocal();
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  Future<bool> userEdit() async {
    return false;
  }

  loadTypeApi() async {
    List<String> data = await LocalData.loadList(key: LocalDataKey.typeApi);
    if (data.isNotEmpty) {
      typeApi = data
          .map((e) => TypeApi.values.firstWhere((t) => t.name == e))
          .toList();
    } else {
      await saveTypeApi();
    }
  }

  saveTypeApi() async {
    await LocalData.saveList(
        list: typeApi.map((e) => e.name).toList(), key: LocalDataKey.typeApi);
  }

  Future<void> loadUserFromLocal() async {
    try {
      final data = await LocalData.loadJson(key: LocalDataKey.user);
      if (data['error'] == null) {
        user = User.fromJson(data);
      } else {
        await saveUserToLocal();
      }
    } catch (e) {
      await saveUserToLocal();
    }
  }

  Future<void> saveUserToLocal() async {
    await LocalData.saveJson(json: user.toJson(), key: LocalDataKey.user);
  }
}
