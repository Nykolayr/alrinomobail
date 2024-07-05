import 'package:alrino/data/api/api.dart';
import 'package:alrino/data/local_data.dart';
import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/models/process.dart';
import 'package:alrino/domain/models/response_api.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';

class MainRepository extends GetxController {
  List<Organisation> orgs = [];
  List<String> orgNames = [];
  List<Process> process = [];
  List<String> activityNames = [];

  Api api = Get.find<Api>();

  static final MainRepository _instance = MainRepository._internal();
  factory MainRepository() => _instance;
  MainRepository._internal();

  Future<void> init() async {
    await updateServer();
  }

  /// обновление данных с сервера
  Future updateServer() async {
    await loadOrgsApi();
    await loadProcessApi();
    Get.find<FhnRepository>().loadPatternsFromApi();
  }

  Future<void> loadOrgsApi() async {
    final ResponseApi answer = await api.getOrganitationApi();
    if (answer is ResSuccess) {
      orgs = answer.data
          .map<Organisation>((e) => Organisation.fromJson(e))
          .toList();
      orgs = orgs.where((e) => e.status != 'onPaid').toList();
      orgNames = orgs.map((e) => '${e.name}_${e.contract}').toList();
      await saveOrgsToLocal();
    } else if (answer is ResError) {
      await loadOrgsFromLocal();
    }
  }

  /// загрузка организаций из локального хранилища
  Future<void> loadOrgsFromLocal() async {
    final List<Map<String, dynamic>> data =
        await LocalData.loadListJson(key: LocalDataKey.orgs);
    Logger.e(' loadOrgsFromLocal $data');
    if (data.isNotEmpty && data.first['error'] == null) {
      orgs = data.map((org) => Organisation.fromJson(org)).toList();
      orgNames = orgs.map((e) => '${e.name}_${e.contract}').toList();
    } else {
      await saveOrgsToLocal();
    }
  }

  /// сохранение организаций в локальное хранилище
  Future<void> saveOrgsToLocal() async {
    await LocalData.saveListJson(
        json: orgs.map((org) => org.toJson()).toList(), key: LocalDataKey.orgs);
  }

  /// загрузка процессов с сервера
  Future<void> loadProcessApi() async {
    final ResponseApi answer = await api.getProcessApi();
    if (answer is ResSuccess) {
      process = answer.data.map<Process>((e) => Process.fromJson(e)).toList();
      activityNames = process.map((e) => e.activity).toSet().toList();
      await saveProcessToLocal();
    } else if (answer is ResError) {
      loadProcessFromLocal();
    }
  }

  /// загрузка процессов из локального хранилища
  Future<void> loadProcessFromLocal() async {
    final List<Map<String, dynamic>> data =
        await LocalData.loadListJson(key: LocalDataKey.process);
    if (data.isNotEmpty && data.first['error'] == null) {
      process = data.map((item) => Process.fromJson(item)).toList();
      activityNames = process.map((e) => e.activity).toSet().toList();
    } else {
      await saveProcessToLocal();
    }
  }

  /// сохранение процессов в локальное хранилище
  Future<void> saveProcessToLocal() async {
    await LocalData.saveListJson(
        json: process.map((item) => item.toJson()).toList(),
        key: LocalDataKey.process);
  }
}
