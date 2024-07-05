part of 'main_bloc.dart';

sealed class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
}

/// обновляем данные с сервера
class UpdateServerEvent extends MainEvent {}

/// переключаем режим фрд, фхн на данные с process
class SetIsProcessEvent extends MainEvent {}
