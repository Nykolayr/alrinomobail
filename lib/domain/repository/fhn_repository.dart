import 'package:alrino/data/api/api.dart';
import 'package:alrino/data/connectivity_bloc/connectivity_bloc.dart';
import 'package:alrino/data/local_data.dart';
import 'package:alrino/domain/models/document.dart';
import 'package:alrino/domain/models/fhn/fhn.dart';
import 'package:alrino/domain/models/fhn/fhn_history.dart';
import 'package:alrino/domain/models/fhn/pattern_fhn.dart';
import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/models/response_api.dart';
import 'package:alrino/domain/models/sz/file.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:get/get.dart';

/// репо для ФХН
/// curfhn - текущий
/// tempfhn - временный, для сохранения предыдущих значений,
/// чтобы не вводить лишний раз значения
/// hystoryfhn - история fhn
/// orgs - список организаций
/// divs - список подразделений
/// orgNames - список названий организаций для TypeAheadField
/// values - список значений для TypeAheadField
class FhnRepository extends GetxController {
  Fhn tempFhn = Fhn.initial();
  List<FhnHystory> hystoryFhn = [];
  List<String> valuesFhn = [];
  List<String> operationsFhn = [];
  List<PatternFhn> patternsFhn = [];

  int curIndexPatternFhn = 0;
  PatternFhn tempPattern = PatternFhn.initial();
  Api api = Get.find<Api>();

  static final FhnRepository _instance = FhnRepository._internal();
  factory FhnRepository() => _instance;
  FhnRepository._internal();

  Future<void> init() async {
    // LocalData().clear();
    await loadHistoryFhnFromLocal();
    await loadFhnFromLocal(LocalDataKey.tempfhn);
    valuesFhn = await loadListFromLocal(LocalDataKey.valuesFhn);
    await loadPatternsFromApi();
  }

  /// Загружаем шаблоны из API, при ошибке загружаем из локального хранилища
  Future<void> loadPatternsFromApi() async {
    await loadPatternFromLocal();
    final ResponseApi response = await api.loadPatternFhnApi();
    if (response is ResSuccess) {
      List<PatternFhn> serverPatternsFhn = (response.data as List)
          .map((pattern) => PatternFhn.fromJson(pattern))
          .toList();
      if (!Get.find<UserRepository>().user.isExecutor) {
        patternsFhn = serverPatternsFhn;
      } else {
        List<PatternFhn> myPatternsFhn =
            patternsFhn.where((pattern) => pattern.isMy).toList();
        patternsFhn = myPatternsFhn + serverPatternsFhn;
      }
      await savePatternToLocal();
    } else if (response is ResError) {
      await loadPatternFromLocal();
    }
  }

  /// выгрузка документа
  Future<void> uploadDocument() async {
    List<Organisation> orgs = Get.find<MainRepository>().orgs;
    Organisation? org =
        orgs.firstWhereOrNull((e) => e.name == tempFhn.org.split('_')[0]);

    if (org == null) return;

    Document document = Document.fromFhn(fhn: hystoryFhn.last, org: org);

    bool isInternet = await Get.find<FlutterNetworkConnectivity>()
        .isInternetConnectionAvailable();
    if (isInternet) {
      await Get.find<MainRepository>().updateServer();
      Organisation org = Get.find<MainRepository>()
          .orgs
          .firstWhere((element) => element.id == document.idOrg);
      document.project = org.name;
      document.service = org.service;
      document.contract = org.contract;
      final ResponseApi answer =
          await api.uploadDocumentApi(document: document);
      if (answer is ResSuccess) {
        Logger.e('uploadFileApi ${answer.data}');
      } else if (answer is ResError) {
        Logger.e('loadOrgsApi2 api: ${answer.errorMessage}');

        Get.find<UserRepository>().saveData(TypeApi.document, document);
      }
    } else {
      Get.find<UserRepository>().saveData(TypeApi.document, document);
    }
  }

  /// выгрузка файла excel
  Future<void> uploadFileExcel(
      {required List<int> bytes, required String fileName}) async {
    bool isInternet = await Get.find<FlutterNetworkConnectivity>()
        .isInternetConnectionAvailable();
    if (isInternet) {
      final ResponseApi answer =
          await api.uploadFileApi(bytes: bytes, fileName: fileName);
      if (answer is ResSuccess) {
        Logger.e('uploadFileApi ${answer.data}');
      } else if (answer is ResError) {
        Logger.e('loadOrgsApi2 api: ${answer.errorMessage}');
        Get.find<UserRepository>().saveData(
            TypeApi.file, FileDocument(bytes: bytes, fileName: fileName));
      }
    } else {
      Get.find<UserRepository>().saveData(
          TypeApi.file, FileDocument(bytes: bytes, fileName: fileName));
    }
  }

  /// создаем новый шаблон
  createPatternFhn() {
    tempPattern = PatternFhn.initial();
    tempPattern.id = patternsFhn.length + 1;
    tempPattern.name = 'Новый шаблон №${tempPattern.id}';
    tempFhn = Fhn.initial();
  }

  /// добавляем в список и сохраняем новый шаблон
  saveTempPattern() {
    tempPattern.id = -1;
    patternsFhn.add(tempPattern);
    savePatternToApi();
  }

  /// удаляем шаблон из списка и сохраняем
  Future<void> deletePattern(int id) async {
    int patternIndex = patternsFhn.indexWhere((pattern) => pattern.id == id);
    if (patternIndex == -1) {
      Logger.e('Pattern with id $id not found');
      return;
    }

    patternsFhn.removeAt(patternIndex);
    final ResponseApi response = await api.deletePatternFhnApi(id);
    if (response is ResSuccess) {
      Logger.w('Pattern with id $id deleted successfully');
    } else if (response is ResError) {
      Logger.e('Error deleting pattern with id $id: ${response.errorMessage}');
    }
    savePatternToLocal();
  }

  Future<void> emptyValuesFhn() async {
    valuesFhn = [];
    await saveListToLocal(valuesFhn, LocalDataKey.valuesFhn);
  }

  /// передаем данные из шаблона в текущий фхн
  patternToFhn(PatternFhn pattern) async {
    tempPattern = pattern;
    tempFhn.org = pattern.org;
    tempFhn.division = pattern.division;
    tempFhn.date = pattern.date;
    tempFhn.operating = pattern.operating;
    tempFhn.fio = pattern.fio;
    tempFhn.post = pattern.post;
    tempFhn.experience = pattern.experience;
    tempFhn.phone = pattern.phone;
    tempFhn.addColumns = pattern.addColumns;
    curIndexPatternFhn = pattern.id;
    tempFhn.operations.clear();
    await saveAll();
  }

  Future<void> saveAll() async {
    await savefhnToLocal();
  }

  Future<void> savefhnHystory() async {
    await Future.delayed(const Duration(seconds: 1));
    await savefhnHystoryToLocal(LocalDataKey.historyfhn);
  }

  void saveValuesfhn(String text) {
    if (text.isEmpty ||
        (valuesFhn.indexWhere((element) => element == text)) != -1) return;
    // valuesFhn.add(text);
    saveListToLocal(valuesFhn, LocalDataKey.valuesFhn);
  }

  Future<List<String>> loadListFromLocal(LocalDataKey key) async {
    final List<String> data = await LocalData.loadList(key: key);
    if (data.isEmpty) await saveListToLocal([], key);
    return data;
  }

  Future<void> saveListToLocal(List<String> list, LocalDataKey key) async {
    await LocalData.saveList(list: list, key: key);
  }

  /// загружаем шаблоны из локального хранилища
  Future<void> loadPatternFromLocal() async {
    final List<Map<String, dynamic>> data =
        await LocalData.loadListJson(key: LocalDataKey.patternsFhn);
    if (data.isNotEmpty && data.first['error'] == null) {
      patternsFhn =
          data.map((pattern) => PatternFhn.fromJson(pattern)).toList();
    } else {
      await savePatternToLocal();
    }
  }

  /// Сохраняем шаблоны в API
  Future<void> savePatternToApi() async {
    // Если пользователь не является исполнителем, то отправляем на сервер, если нет, то в локаль
    if (!Get.find<UserRepository>().user.isExecutor) {
      final ResponseApi response = await Api().addPatternsFhnApi(
          patternsFhn.map((pattern) => pattern.toJson()).toList());
      if (response is ResError) {
        Logger.e('Ошибка при сохранении шаблонов ФХН через API: ');
      }

      await loadPatternsFromApi();
    } else {
      savePatternToLocal();
      Logger.e(' savePatternToApi ${patternsFhn.length}');
    }
  }

  Future<void> savePatternToLocal() async {
    await LocalData.saveListJson(
        json: patternsFhn.map((pattern) => pattern.toJson()).toList(),
        key: LocalDataKey.patternsFhn);
  }

  Future<void> loadHistoryFhnFromLocal() async {
    final data = await LocalData.loadListJson(key: LocalDataKey.historyfhn);
    if (data.isNotEmpty && data.first['error'] == null) {
      hystoryFhn = data.map((fhn) => FhnHystory.fromJson(fhn)).toList();
    } else {
      await savefhnHystoryToLocal(LocalDataKey.historyfhn);
    }
  }

  Future<void> savefhnHystoryToLocal(LocalDataKey key) async {
    await LocalData.saveListJson(
        json: hystoryFhn.map((fhn) => fhn.toJson()).toList(),
        key: LocalDataKey.historyfhn);
  }

  Future<void> loadFhnFromLocal(LocalDataKey key) async {
    final data = await LocalData.loadJson(key: LocalDataKey.tempfhn);
    if (data['error'] == null) {
      tempFhn = Fhn.fromJson(data);
    } else {
      await savefhnToLocal();
    }
  }

  Future<void> savefhnToLocal() async {
    await LocalData.saveJson(json: tempFhn.toJson(), key: LocalDataKey.tempfhn);
  }
}
