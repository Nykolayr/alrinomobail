// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:alrino/domain/models/fhn/fhn.dart';
import 'package:alrino/domain/models/frd/frd.dart';
import 'package:alrino/domain/models/sz/sz.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/screens/main/app_bottom.dart';
import 'package:alrino/presentation/screens/main/bloc/main_bloc.dart';
import 'package:alrino/presentation/screens/main/pages.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../theme/theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  UserRepository userRepo = Get.find<UserRepository>();
  late TabController tabController;
  MainPageType type = MainPageType.values[1];
  PageController pageController = PageController(initialPage: 1);

  Future getPermisson() async {
    if (context.mounted) {
      bool microphonePermissionGranted =
          await checkMicrophonePermission(context);
      userRepo.saveAudio(microphonePermissionGranted);
      bool storagePermissionGranted = await checkStoragePermission(context);
      userRepo.saveFile(storagePermissionGranted);
      setState(() {});
    }
    await checkTable();
  }

  @override
  void initState() {
    tabController = TabController(
      vsync: this,
      length: MainPageType.values.length,
      initialIndex: 1,
      animationDuration: const Duration(milliseconds: 800),
    );

    tabController.addListener(() {
      setState(() {});
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    getPermisson();

    super.initState();
  }

  /// проверка, на то, что, таблица была уже начата
  Future checkTable() async {
    Logger.i('>> ${Get.find<FrdRepository>().tempFrd.operations.length} ');
    if (Get.find<FrdRepository>().tempFrd.operations.isNotEmpty) {
      final answer = await showNotFiilTableAlert(context);
      if (answer == true) {
        context.goNamed('ФРДТаблица');
      } else {
        Get.find<FrdRepository>().tempFrd = Frd.initial();
        Get.find<FrdRepository>().saveTempFrdToLocal();
      }
    } else if (Get.find<FhnRepository>().tempFhn.operations.isNotEmpty) {
      final answer = await showNotFiilTableAlert(context);
      if (answer == true) {
        context.goNamed('Таблица ФХН');
      } else {
        Get.find<FhnRepository>().tempFhn = Fhn.initial();
        Get.find<FhnRepository>().savefhnToLocal();
      }
    } else if (Get.find<FrdRepository>().tempSz.operations.isNotEmpty) {
      final answer = await showNotFiilTableAlert(context);
      if (answer == true) {
        context.goNamed('СЗ');
      } else {
        Get.find<FrdRepository>().tempSz = Sz.initial();
        Get.find<FrdRepository>().saveSzToLocal();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
        bloc: Get.find<MainBloc>(),
        builder: (context, state) {
          return DefaultTabController(
            length: MainPageType.values.length,
            child: Scaffold(
              bottomSheet: AppBottom(
                  tabController: tabController, pageController: pageController),
              body: SafeArea(
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    const FonPicture(),
                    TabBarView(
                      controller: tabController,
                      children: [
                        ...MainPageType.values.map(
                          (type) => Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(50),
                                  Center(
                                    child: Text(
                                      type.pageName,
                                      style: AppText.mainTitle28,
                                    ),
                                  ),
                                  const Gap(30),
                                  type.getPage,
                                  const Gap(30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (state.isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (state.error.isNotEmpty)
                      Positioned(
                        bottom: 100,
                        child: Center(
                            child: Text(state.error,
                                style: AppText.title12
                                    .copyWith(color: AppColor.redPro))),
                      ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

Future<bool> checkMicrophonePermission(BuildContext context) async {
  UserRepository userRepo = Get.find<UserRepository>();

  // Проверка разрешения на использование микрофона
  PermissionStatus micStatus = await Permission.microphone.status;
  if (!micStatus.isGranted) {
    if (micStatus.isDenied) {
      // Запрос разрешения на использование микрофона
      PermissionStatus micPermissionStatus =
          await Permission.microphone.request();
      if (!micPermissionStatus.isGranted) {
        // await openAppSettings();
        return false;
      }
    } else {
      userRepo.saveAudioFirst(false);
      if (context.mounted) {
        await showModalContent(
            context,
            'У вас нет разрешения на использование микрофона. \nИспользование микрофона будет не возможно.',
            const Text('Хотите включить в системных разрешениях?'), () {
          context.pop();
        }, () async {
          await openAppSettings();
        }, butText: 'Включить');
      }
      // Разрешение не предоставлено, направляем пользователя в системные настройки
      return false;
    }
  }

  return true;
}

Future<bool> checkStoragePermission(BuildContext context) async {
  UserRepository userRepo = Get.find<UserRepository>();
  if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
    if ((info.version.sdkInt) >= 33) return true;
  }

  // Проверка разрешений на чтение и запись во внешнее хранилище
  PermissionStatus storageStatus = await Permission.storage.status;
  if (!storageStatus.isGranted) {
    if (storageStatus.isDenied) {
      // Запрос разрешения на чтение и запись во внешнее хранилище
      PermissionStatus storagePermissionStatus =
          await Permission.storage.request();
      if (!storagePermissionStatus.isGranted) {
        // Пользователь отказал в предоставлении разрешения, направляем его в системные настройки
        // await openAppSettings();
        return false;
      }
    } else {
      userRepo.saveFileFirst(false);
      // Разрешение не предоставлено, направляем пользователя в системные настройки
      if (context.mounted) {
        await showModalContent(
            context,
            'У вас нет разрешений на чтение и запись во внешнее хранилище. \nСохранение файлов excel будет не возможно.',
            const Text('Хотите включить в системных разрешениях?'), () {
          context.pop();
        }, () async {
          await openAppSettings();
        }, butText: 'Включить');
      }
      return false;
    }
  }
  return true;
}
