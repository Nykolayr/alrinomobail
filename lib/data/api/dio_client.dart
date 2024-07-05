import 'package:alrino/common/constants.dart';
import 'package:alrino/data/api/dio_exception.dart';
import 'package:alrino/data/connectivity_bloc/connectivity_bloc.dart';
import 'package:alrino/domain/models/response_api.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';

class DioClient {
  final Dio dio;
  final options = Options(
    headers: {
      'Content-type': 'application/json',
      if (Get.isRegistered<UserRepository>() &&
          Get.find<UserRepository>().token.isNotEmpty) 
        'Authorization': 'Bearer ${Get.find<UserRepository>().token}',
    },
  );
  DioClient(this.dio) {
    dio
      ..options.baseUrl = serverPath
      ..options.connectTimeout = const Duration(seconds: 35)
      ..options.receiveTimeout = const Duration(seconds: 35);
  }

  Future<ResponseApi> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (checkInternet() is ResError) return checkInternet();
    try {
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }

  Future<ResponseApi> post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (checkInternet() is ResError) return checkInternet();
    try {
      final response = await dio.post(
        url,
        data: data,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }

  Future<ResponseApi> put(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (checkInternet() is ResError) return checkInternet();
    try {
      final response = await dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }

  Future<ResponseApi> delete(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (checkInternet() is ResError) return checkInternet();
    try {
      final response = await dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }
}

ResponseApi checkInternet() {
  try {
    if (!Get.find<ConnectivityBloc>().state.isConnection) {
      return ResError(errorMessage: 'Нет подключения к сети');
    } else {
      return Get.find<UserRepository>().user.token.isNotEmpty
          ? ResSuccess('')
          : ResError(errorMessage: 'Пользователь не авторизован');
    }
  } catch (e) {
    return ResError(errorMessage: 'Нет подключения к сети');
  }
}

ResponseApi errorHandling(Object e) {
  if (e is DioException) {
    DioExceptions dioException = DioExceptions.fromDioError(e);
    return ResError(errorMessage: dioException.errorText);
  } else {
    return ResError(errorMessage: 'Unexpected error occurred: ${e.toString()}');
  }
}

ResponseApi processResponse(Map<String, dynamic> res, String path) {
  Logger.w('processResponse $path --->>> $res');
  if (res['success'] == true) {
    ResSuccess resSuccess = ResSuccess(res['base']);
    resSuccess.consoleRes(path);
    return resSuccess;
  } else {
    if (res['message'] == 'Ошибка проверки токена' &&
        Get.find<UserRepository>().token.isNotEmpty) {
      showErrorDialog(
          '${res['message']} \n Вам надо заново завести учетную запись на сайте или попросить об этом администратора');
    }
    ResError resError = ResError(errorMessage: res['message']);
    resError.consoleRes(path);
    return resError;
  }
}
