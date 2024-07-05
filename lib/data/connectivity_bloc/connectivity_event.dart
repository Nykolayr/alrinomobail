part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

/// слушаем подключение интернета и изменяем
class ConnectionEvent extends ConnectivityEvent {
  final bool isConnection;
  const ConnectionEvent({required this.isConnection});
  @override
  List<Object> get props => [isConnection];
}
