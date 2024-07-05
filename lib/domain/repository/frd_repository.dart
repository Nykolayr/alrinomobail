import 'package:alrino/data/api/api.dart';
import 'package:alrino/data/connectivity_bloc/connectivity_bloc.dart';
import 'package:alrino/data/local_data.dart';
import 'package:alrino/domain/models/document.dart';
import 'package:alrino/domain/models/frd/frd.dart';
import 'package:alrino/domain/models/frd/ftd_history_table.dart';
import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/models/response_api.dart';
import 'package:alrino/domain/models/sz/file.dart';
import 'package:alrino/domain/models/sz/sz.dart';
import 'package:alrino/domain/models/sz/sz_operation.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/screens/sz/bloc/sz_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:get/get.dart';

/// репо для ФРД
/// curFrd - текущий
/// tempFrd - временный, для сохранения предыдущих значений,
/// чтобы не вводить лишний раз значения
/// hystoryFrd - история frd
/// orgs - список организаций
/// divs - список подразделений
/// orgNames - список названий организаций для TypeAheadField
/// values - список значений для TypeAheadField
class FrdRepository extends GetxController {
  Frd tempFrd = Frd.initial();
  List<FrdHystory> hystoryFrd = [];
  List<String> valuesFrd = [];
  List<String> operationsFrd = [];
  List<String> valuesSz = [];
  Sz tempSz = Sz.initial();
  Api api = Get.find<Api>();

  static final FrdRepository _instance = FrdRepository._internal();
  factory FrdRepository() => _instance;
  FrdRepository._internal();

  Future<void> init() async {
    // LocalData().clear();

    try {
      await loadHistoryFrdFromLocal();
    } catch (e) {
      throw Exception('ошибка в loadHistoryFrdFromLocal == $e');
    }
    valuesFrd = await loadListFromLocal(LocalDataKey.valuesFrd);
    valuesSz = await loadListFromLocal(LocalDataKey.valuesSz);
    try {
      await loadSzFromLocal();
    } catch (e) {
      throw Exception('ошибка в loadSzFromLocal == $e');
    }
    try {
      await loadFrdFromLocal();
    } catch (e) {
      throw Exception('ошибка в loadFrdFromLocal == $e');
    }
  }

  /// запись tempFrd в локальное хранилище
  saveTempSz() async {
    await LocalData.saveJson(
      key: LocalDataKey.tempSz,
      json: tempFrd.toJson(),
    );
  }

// перед переходом в таблицу СЗ, присваеваем текущего пользователя
  setUserSz() async {
    await loadSzFromLocal();
    tempSz.user = Get.find<UserRepository>().user;
  }

  /// создание новой СЗ
  newSz() {
    tempSz = Sz.initial();
    Get.find<SzBloc>().add(NewSzEvent());
  }

  /// получаем документ из операции СЗ
  Document getDocument(OperationSz operSz) {
    List<Organisation> orgs = Get.find<MainRepository>().orgs;
    Organisation? org =
        orgs.firstWhereOrNull((e) => e.name == operSz.org.split('_')[0]);
    if (org == null) {
      org = Organisation.initial();
      org = org.copyWith(name: operSz.org);
    }
    Document document = Document.fromSzOperation(
        operSz: operSz, org: org, isOuter: tempSz.isOuter);
    return document;
  }

  /// выгрузка документов из СЗ
  Future<void> uploadSz() async {
    tempSz.operations.removeLast();
    for (OperationSz item in tempSz.operations) {
      Document document = getDocument(item);
      bool isInternet = await Get.find<FlutterNetworkConnectivity>()
          .isInternetConnectionAvailable();
      if (isInternet) {
        await Get.find<MainRepository>().updateServer();
        Document document = getDocument(item);
        final ResponseApi answer =
            await api.uploadDocumentApi(document: document);
        if (answer is ResSuccess) {
          Logger.w('uploadFileApi ${answer.data}');
        } else if (answer is ResError) {
          Logger.e('loadOrgsApi2 api: ${answer.errorMessage}');
          Get.find<UserRepository>().saveData(TypeApi.document, document);
        }
      } else {
        Get.find<UserRepository>().saveData(TypeApi.document, document);
      }
    }
    tempSz = Sz.initial();
    await saveSzToLocal();
  }

  /// загрузка документа
  Future<void> uploadDocument() async {
    List<Organisation> orgs = Get.find<MainRepository>().orgs;

    Document document = Document.fromFrd(
        frd: hystoryFrd.last,
        org: orgs
            .firstWhere((e) => e.name == hystoryFrd.last.org.split('_')[0]));
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
        Logger.w('uploadFileApi ${answer.data}');
      } else if (answer is ResError) {
        Logger.e('loadOrgsApi2 api: ${answer.errorMessage}');
        Get.find<UserRepository>().saveData(TypeApi.document, document);
      }
    } else {
      Get.find<UserRepository>().saveData(TypeApi.document, document);
    }
  }

  /// загрузка файла excel
  Future<void> uploadFileExcel(
      {required List<int> bytes, required String fileName}) async {
    bool isInternet = await Get.find<FlutterNetworkConnectivity>()
        .isInternetConnectionAvailable();
    if (isInternet) {
      final ResponseApi answer =
          await api.uploadFileApi(bytes: bytes, fileName: fileName);
      if (answer is ResSuccess) {
      } else if (answer is ResError) {
        Logger.e('uploadFileExcel api: ${answer.errorMessage}');
        Get.find<UserRepository>().saveData(
            TypeApi.file, FileDocument(bytes: bytes, fileName: fileName));
        // String error = answer.errorMessage;
      }
    } else {
      Get.find<UserRepository>().saveData(
          TypeApi.file, FileDocument(bytes: bytes, fileName: fileName));
    }
  }

  /// очистка списка значений ФРД
  Future<void> emptyValuesFrd() async {
    valuesFrd = [];
    await saveListToLocal(valuesFrd, LocalDataKey.valuesFrd);
  }

  /// сохранение истории ФРД
  Future<void> saveFrdHystory() async {
    await Future.delayed(const Duration(seconds: 1));
    await saveFrdHystoryToLocal(LocalDataKey.historyfrd);
  }

  /// сохранение всех данных
  Future<void> saveAll() async {
    await saveSzToLocal();
    await Future.delayed(const Duration(seconds: 1));
  }

  /// сохранение значений ФРД
  void saveValuesFrd(String text) {
    if (!valuesFrd.contains(text)) {
      // valuesFrd.add(text);
      valuesFrd = valuesFrd.toSet().toList();
      saveListToLocal(valuesFrd, LocalDataKey.valuesFrd);
    }
  }

  /// загрузка списка из локального хранилища
  Future<List<String>> loadListFromLocal(LocalDataKey key) async {
    final List<String> data = await LocalData.loadList(key: key);
    if (data.isEmpty) await saveListToLocal([], key);
    return data;
  }

  /// сохранение списка в локальное хранилище
  Future<void> saveListToLocal(List<String> list, LocalDataKey key) async {
    await LocalData.saveList(list: list, key: key);
  }

  /// загрузка истории ФРД из локального хранилища
  Future<void> loadHistoryFrdFromLocal() async {
    final data = await LocalData.loadListJson(key: LocalDataKey.historyfrd);
    if (data.isNotEmpty && data.first['error'] == null) {
      hystoryFrd = data.map((frd) => FrdHystory.fromJson(frd)).toList();
    } else {
      await saveFrdHystoryToLocal(LocalDataKey.historyfrd);
    }
  }

  /// сохранение истории ФРД в локальное хранилище
  Future<void> saveFrdHystoryToLocal(LocalDataKey key) async {
    await LocalData.saveListJson(
        json: hystoryFrd.map((frd) => frd.toJson()).toList(),
        key: LocalDataKey.historyfrd);
  }

  /// загрузка Sz из локальное хранилище
  Future<void> loadSzFromLocal() async {
    final data = await LocalData.loadJson(key: LocalDataKey.tempSz);
    Logger.e('loadSzFromLocal = $data');
    if (data['error'] == null) {
      tempSz = Sz.fromJson(data);
    } else {
      await saveSzToLocal();
    }
  }

  /// загрузка tempFrd из локальное хранилище
  loadFrdFromLocal() async {
    final data = await LocalData.loadJson(key: LocalDataKey.tempfrd);
    if (data['error'] == null) {
      tempFrd = Frd.fromJson(data);
    } else {
      await saveTempFrdToLocal();
    }
  }

  /// запись Sz в локальное хранилище
  Future<void> saveSzToLocal() async {
    await LocalData.saveJson(json: tempSz.toJson(), key: LocalDataKey.tempSz);
  }

  /// запись tempFrd в локальное хранилище
  saveTempFrdToLocal() async {
    await LocalData.saveJson(key: LocalDataKey.tempfrd, json: tempFrd.toJson());
  }
}
