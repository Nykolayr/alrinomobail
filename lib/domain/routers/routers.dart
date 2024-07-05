import 'package:alrino/common/function.dart';
import 'package:alrino/domain/models/fhn/fhn_history.dart';
import 'package:alrino/domain/models/frd/ftd_history_table.dart';
import 'package:alrino/presentation/screens/auth/auth.dart';
import 'package:alrino/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:alrino/presentation/screens/fhn/choose_pattern_page.dart';
import 'package:alrino/presentation/screens/fhn/fhn_page.dart';
import 'package:alrino/presentation/screens/fhn/fhn_table.dart';
import 'package:alrino/presentation/screens/fhn/filling_form.dart';
import 'package:alrino/presentation/screens/fhn/new_pattern_page.dart';
import 'package:alrino/presentation/screens/frd/frd_page.dart';
import 'package:alrino/presentation/screens/frd/frd_table.dart';
import 'package:alrino/presentation/screens/history_fhn/history_fhn_page.dart';
import 'package:alrino/presentation/screens/history_fhn/history_fhn_table.dart';
import 'package:alrino/presentation/screens/history_frd/history_frd_page.dart';
import 'package:alrino/presentation/screens/main/main_page.dart';
import 'package:alrino/presentation/screens/splash/splash.dart';
import 'package:alrino/presentation/screens/sz/sz_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

import '../../presentation/screens/history_frd/history_frd_table.dart';

/// роутер приложения
final GoRouter router = GoRouter(
  // observers: [GoNavigatorObserver()],
  debugLogDiagnostics: true,
  initialLocation: '/splash',

  routes: <GoRoute>[
    GoRoute(
      name: 'Заставка',
      path: '/splash',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const SplashPage(),
      ),
    ),
    GoRoute(
      name: 'авторизация',
      path: '/auth',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: BlocProvider(
          create: (BuildContext context) => AuthBloc(),
          child: const AuthPage(),
        ),
      ),
    ),
    GoRoute(
      name: 'Общая',
      path: '/main',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const MainPage(),
      ),
      routes: [
        GoRoute(
          name: 'ФРД',
          path: 'frd',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.fade,
            context: context,
            state: state,
            child: const FrdPage(),
          ),
          routes: [
            GoRoute(
              name: 'ФРДТаблица',
              path: 'frdtable',
              pageBuilder: (context, state) => buildPageWithDefaultTransition(
                type: PageTransitionType.fade,
                context: context,
                state: state,
                child: const FrdTablePage(),
              ),
            ),
          ],
        ),
        GoRoute(
          name: 'ФХН',
          path: 'fhn',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.fade,
            context: context,
            state: state,
            child: const FhnPage(),
          ),
          routes: [
            GoRoute(
              name: 'Выбор шаблона',
              path: 'choosepattern',
              pageBuilder: (context, state) => buildPageWithDefaultTransition(
                type: PageTransitionType.fade,
                context: context,
                state: state,
                child: const FhnChoosePatternPage(),
              ),
              routes: [
                GoRoute(
                  name: 'Редактирование шаблона',
                  path: 'newpattern',
                  pageBuilder: (context, state) =>
                      buildPageWithDefaultTransition(
                    type: PageTransitionType.fade,
                    context: context,
                    state: state,
                    child: const NewPatternFhnPage(isEdit: true),
                  ),
                ),
                GoRoute(
                  name: 'Заполнение формы',
                  path: 'fillingform',
                  pageBuilder: (context, state) =>
                      buildPageWithDefaultTransition(
                    type: PageTransitionType.fade,
                    context: context,
                    state: state,
                    child: const FillingFormFhnPage(),
                  ),
                ),
                GoRoute(
                  name: 'Таблица ФХН',
                  path: 'fhntable',
                  pageBuilder: (context, state) =>
                      buildPageWithDefaultTransition(
                    type: PageTransitionType.fade,
                    context: context,
                    state: state,
                    child: const FhnTablePage(),
                  ),
                ),
              ],
            ),
            GoRoute(
              name: 'Новый шаблон',
              path: 'newpattern',
              pageBuilder: (context, state) => buildPageWithDefaultTransition(
                type: PageTransitionType.fade,
                context: context,
                state: state,
                child: const NewPatternFhnPage(isEdit: false),
              ),
            ),
          ],
        ),
        GoRoute(
          name: 'СЗ',
          path: 'sz',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.fade,
            context: context,
            state: state,
            child: BlocProvider(
              create: (BuildContext context) => AuthBloc(),
              child: const SzPage(),
            ),
          ),
        ),
        GoRoute(
            name: 'История ФРД',
            path: 'historyfrd',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  type: PageTransitionType.fade,
                  context: context,
                  state: state,
                  child: const HistoryFrdPage(),
                ),
            routes: [
              GoRoute(
                name: 'История ФРД таблица',
                path: 'historyfrdtable',
                pageBuilder: (
                  context,
                  state,
                ) {
                  List<FrdHystory> hystoriesFilter =
                      state.extra as List<FrdHystory>;
                  return buildPageWithDefaultTransition(
                    type: PageTransitionType.fade,
                    context: context,
                    state: state,
                    child: HystoryFrdTable(hystories: hystoriesFilter),
                  );
                },
              ),
            ]),
        GoRoute(
            name: 'История ФХН',
            path: 'historyfhn',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  type: PageTransitionType.fade,
                  context: context,
                  state: state,
                  child: const HistoryFhnPage(),
                ),
            routes: [
              GoRoute(
                name: 'История ФХН таблица',
                path: 'historyfrdtable',
                pageBuilder: (
                  context,
                  state,
                ) {
                  List<FhnHystory> hystoriesFilter =
                      state.extra as List<FhnHystory>;
                  return buildPageWithDefaultTransition(
                    type: PageTransitionType.fade,
                    context: context,
                    state: state,
                    child: HystoryFhnTable(hystories: hystoriesFilter),
                  );
                },
              ),
            ]),
      ],
    ),
  ],
);

/// функция возращает путь для первоначальной страницы
/// в зависимости от  пользователь авторизирован или нет

