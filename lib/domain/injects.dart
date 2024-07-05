import 'package:alrino/data/api/api.dart';
import 'package:alrino/data/api/dio_client.dart';
import 'package:alrino/data/connectivity_bloc/connectivity_bloc.dart';
import 'package:alrino/data/timer_bloc/timer_bloc.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:alrino/presentation/screens/fhn/bloc/fhn_bloc.dart';
import 'package:alrino/presentation/screens/frd/bloc/frd_bloc.dart';
import 'package:alrino/presentation/screens/main/bloc/main_bloc.dart';
import 'package:alrino/presentation/screens/sz/bloc/sz_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:get/get.dart';

/// внедряем зависимости
Future<String> initMain() async {
  try {
    Get.put<DioClient>(DioClient(Dio()));
    Get.put<Api>(Api());
  } catch (e) {
    return 'модуль dio = $e';
  }
  try {
    await Get.putAsync(() async {
      final userRepository = UserRepository();
      await userRepository.init();
      Get.find<DioClient>().options.headers!['Authorization'] =
          'Bearer ${userRepository.user.token}';
      return userRepository;
    });
  } catch (e) {
    return 'модуль UserRepository = $e';
  }

  try {
    await Get.putAsync(() async {
      FlutterNetworkConnectivity connectivity = FlutterNetworkConnectivity(
        isContinousLookUp: true,
        lookUpDuration: const Duration(seconds: 30),
      );
      bool isInternet = await connectivity.isInternetConnectionAvailable();
      Get.put<ConnectivityBloc>(ConnectivityBloc(isInternet));
      connectivity.getInternetAvailabilityStream().listen((event) {
        Get.find<ConnectivityBloc>().add(ConnectionEvent(isConnection: event));
      });
      return connectivity;
    });
  } catch (e) {
    return 'модуль connectivity = $e';
  }
  try {
    await Get.find<UserRepository>().initUser();
  } catch (e) {
    return 'модуль initUser() UserRepository = $e';
  }

  try {
    await Get.putAsync(() async {
      final FhnRepository fhnRepository = FhnRepository();
      await fhnRepository.init();
      return fhnRepository;
    });
  } catch (e) {
    return 'модуль fhnRepository = $e';
  }

  try {
    await Get.putAsync(() async {
      final MainRepository mainRepository = MainRepository();
      await mainRepository.init();
      return mainRepository;
    });
  } catch (e) {
    return 'модуль mainRepository = $e';
  }

  try {
    await Get.putAsync(() async {
      final FrdRepository frdRepository = FrdRepository();
      await frdRepository.init();
      return frdRepository;
    });
  } catch (e) {
    return 'модуль frdRepository = $e';
  }

  try {
    Get.put<AuthBloc>(AuthBloc());
  } catch (e) {
    return 'модуль AuthBloc = $e';
  }
  try {
    Get.put<FhnBloc>(FhnBloc());
  } catch (e) {
    return 'модуль FhnBloc = $e';
  }
  try {
    Get.put<FrdBloc>(FrdBloc());
  } catch (e) {
    return 'модуль FrdBloc = $e';
  }
  try {
    Get.put<SzBloc>(SzBloc());
  } catch (e) {
    return 'модуль SzBloc = $e';
  }
  Get.put<TimerBloc>(TimerBloc());
  Get.put<MainBloc>(MainBloc());

  return '';
}
