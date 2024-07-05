import 'package:alrino/presentation/screens/main/choose_page.dart';
import 'package:alrino/presentation/screens/main/profile_page.dart';
import 'package:flutter/material.dart';

/// Виджеты главной страницы
/// [ChoosePage] - страница выбора дальнейших действий
/// [ProfilePage] - страница профиля пользователя
/// [MainPageType] - тип страницы
/// [MainPageType.choose] - страница выбора дальнейших действий
/// [MainPageType.profile] - страница профиля пользователя
/// также применяется для DefaultTabController

enum MainPageType {
  choose,
  profile;

  String get pageName {
    switch (this) {
      case MainPageType.choose:
        return 'Главная';
      case MainPageType.profile:
        return 'Профиль';
    }
  }

  String get pageIcon {
    switch (this) {
      case MainPageType.choose:
        return 'assets/svg/.svg';
      case MainPageType.profile:
        return 'Профиль';
    }
  }

  Widget get getPage {
    switch (this) {
      case MainPageType.choose:
        return const ChoosePage();
      case MainPageType.profile:
        return const ProfilePage();
    }
  }
}
