import 'package:alrino/data/api/dio_client.dart';
import 'package:alrino/domain/models/document.dart';
import 'package:alrino/domain/models/response_api.dart';
import 'package:get/get.dart';

class Api {
  final DioClient dio = Get.find<DioClient>();

// Получение статуса пользователя
  Future<ResponseApi> getUserStatusApi({required String id}) async {
    final path = '/user/get_status/$id';
    return await dio.get(path);
  }

// Получение списка PatternFhn
  Future<ResponseApi> loadPatternFhnApi() async {
    const path = '/patterns/load_patterns';
    return await dio.get(path);
  }

// Добавление нескольких  PatternFhn
  Future<ResponseApi> addPatternsFhnApi(
      List<Map<String, dynamic>> patternFhnData) async {
    for (Map<String, dynamic> pattern in patternFhnData) {
      pattern['isMy'] = false;
      if (pattern['id'] == -1) {
        pattern.remove('id');
      }
    }

    const path = '/patterns/add_multiple_patterns';
    return await dio.post(path, data: patternFhnData);
  }

// Обновление PatternFhn по ID
  Future<ResponseApi> updatePatternFhnApi(
      int id, Map<String, dynamic> patternFhnData) async {
    patternFhnData['isMy'] = false;
    final path = '/patterns/update_pattern/$id';
    return await dio.put(path, data: patternFhnData);
  }

// Удаление PatternFhn по ID
  Future<ResponseApi> deletePatternFhnApi(int id) async {
    final path = '/patterns/delete_fhn/$id';
    return await dio.delete(path);
  }

  /// загрузка пользователя по id
  Future<ResponseApi> getUser({required String id}) async {
    final path = '/user/get_user/$id';
    return await dio.get(
      path,
    );
  }

  /// сохранение ФРД
  Future<ResponseApi> saveFrd() async {
    const path = '/frd';
    return await dio.get(path);
  }

  /// загрузка  списка подразделений,
  Future<ResponseApi> getDivisitionApi() async {
    const path = '/departament/load_departaments';
    return await dio.get(path);
  }

  /// загрузка  списка процессов,
  Future<ResponseApi> getProcessApi() async {
    const path = '/process/load_process';
    return await dio.get(path);
  }

  /// загрузка  списка организаций,
  Future<ResponseApi> getOrganitationApi() async {
    const path = '/project/load_projects';
    return await dio.get(path);
  }

  /// авторизация по логину и паролю
  Future<ResponseApi> authUser(
      {required String login, required String pass}) async {
    const path = '/user/auth/';
    return await dio.post(path, data: {
      'login': login,
      'password': pass,
    });
  }

  /// выгрузка файла excel
  Future<ResponseApi> uploadFileApi(
      {required List<int> bytes, required String fileName}) async {
    const path = '/files/upload';
    return await dio.post(path, data: {
      'file': bytes,
      'fileName': fileName,
    });
  }

  /// выгрузка данных по документу
  Future<ResponseApi> uploadDocumentApi({required Document document}) async {
    const path = '/document/add_document';
    return await dio.post(path, data: document.toJson());
  }
}
