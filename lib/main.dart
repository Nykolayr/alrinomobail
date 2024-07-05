import 'dart:io';

import 'package:alrino/domain/routers/routers.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workmanager/workmanager.dart';

bool isMock = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // инициализируем для задач в фоновом режиме
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification:
              (int id, String? title, String? body, String? payload) =>
                  onDidReceiveLocalNotification());
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) =>
          onDidReceiveNotificationResponse());
  HttpOverrides.global = MyHttpOverrides();

  // переходим в полноэкранный режим
  FullScreenWindow.setFullScreen(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Алрино.DATA',
      debugShowCheckedModeBanner: false,
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      theme: ThemeData(
          scaffoldBackgroundColor: AppColor.white,
          useMaterial3: false,
          textTheme: GoogleFonts.manropeTextTheme(),
          fontFamily: GoogleFonts.manrope().fontFamily,
          appBarTheme: const AppBarTheme(color: AppColor.white),
          canvasColor: AppColor.white,
          dialogBackgroundColor: Colors.white),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
      ],
      locale: const Locale('ru', ''),
      builder: (context, child) {
        WidgetsBinding.instance.addObserver(MyWidgetsBindingObserver());
        final mq = MediaQuery.of(context);
        final fontScale =
            mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.1);
        mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.1);
        return Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: mq.copyWith(textScaler: fontScale),
            child: child!,
          ),
          // ),
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

// Реализация WidgetsBindingObserver
class MyWidgetsBindingObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Приложение вернулось на передний план
    }
    if (state == AppLifecycleState.hidden) {}
    if (state == AppLifecycleState.inactive) {}
    if (state == AppLifecycleState.paused) {}
    if (state == AppLifecycleState.detached) {}
  }
}

/// Обработчик задач в фоновом режиме
@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return Future.value(true);
  });
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void onDidReceiveLocalNotification() {}
void onDidReceiveNotificationResponse() {}
