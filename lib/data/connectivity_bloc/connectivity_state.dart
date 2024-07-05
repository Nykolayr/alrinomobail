part of 'connectivity_bloc.dart';

class ConnectivityState {
  final bool isLoading;
  final bool isError;
  final bool isConnection;

  const ConnectivityState({
    required this.isLoading,
    required this.isError,
    required this.isConnection,
  });
  factory ConnectivityState.initial(bool isConnection) => ConnectivityState(
        isLoading: false,
        isError: false,
        isConnection: isConnection,
      );

  ConnectivityState copyWith({
    List? dataArr,
    List<TypeApi>? typeApi,
    bool? isLoading,
    bool? isError,
    bool? isConnection,
  }) {
    return ConnectivityState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isConnection: isConnection ?? this.isConnection,
    );
  }
}

/// типы данных для отправки на сервер
enum TypeApi {
  document,
  file;

  /// отправка данных на сервер
  Future<ResponseApi> getApi<T>(T data) {
    switch (this) {
      case TypeApi.document:
        // обновляем данные в документе для организации
        Document document = data as Document;
        Organisation org = Get.find<MainRepository>()
            .orgs
            .firstWhere((element) => element.id == document.idOrg);
        document.project = org.name;
        document.service = org.service;
        document.contract = org.contract;
        return Get.find<Api>().uploadDocumentApi(document: document);
      case TypeApi.file:
        return Get.find<Api>().uploadFileApi(
            bytes: (data as FileDocument).bytes,
            fileName: (data as FileDocument).fileName);
    }
  }

  /// сохранение данных в локальное хранилище
  Future<void> saveToLocal<T>(T data, int index) async {
    switch (this) {
      case TypeApi.document:
        await LocalData.saveJson(
            json: (data as Document).toJson(), name: 'document$index');
        break;
      case TypeApi.file:
        await LocalData.saveJson(
            json: (data as FileDocument).toJson(), name: 'file$index');
        break;
    }
  }

  /// загрузка данных из локального хранилища
  Future<T> getFromLocal<T>(int index) async {
    switch (this) {
      case TypeApi.document:
        Map<String, dynamic> json =
            await LocalData.loadJson(name: 'document$index');
        return Document.fromJson(json) as T;
      case TypeApi.file:
        final json = await LocalData.loadJson(name: 'file$index');
        return FileDocument.fromJson(json) as T;
    }
  }
}
