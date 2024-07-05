part of 'frd_bloc.dart';

sealed class FrdEvent extends Equatable {
  const FrdEvent();

  @override
  List<Object> get props => [];
}

/// добавляем фокус на ячейке и ее редактировании
class AddEditCell extends FrdEvent {
  final int indexRow;
  final ColumnsDataFrd columnsData;
  const AddEditCell({required this.indexRow, required this.columnsData});
}

/// добавляем фокус ячейки
class AddFocusInStatevent extends FrdEvent {
  final FocusNode focus;
  final TextEditingController controller;
  const AddFocusInStatevent({required this.focus, required this.controller});
}

/// фокусировка на последнюю
class FocusLastEditEvent extends FrdEvent {}

/// сохранение таблицы на сервер
class UpdateTableEvent extends FrdEvent {}

/// сохранение таблицы на eccel в локалку и выход из таблицы
class SaveHistoryEvent extends FrdEvent {}

/// сохранение таблицы в локал
class SaveOperationsEvent extends FrdEvent {}

/// начало редактирование таблицы
class NewOperationsEvent extends FrdEvent {}

/// событие фокуса на редактировании ячейки
class FocusAddEditEvent extends FrdEvent {
  final TextEditingController controller;
  final int indexRow;
  final ColumnsDataFrd columnsData;
  const FocusAddEditEvent(
      {required this.controller,
      required this.indexRow,
      required this.columnsData});
}

///  добавление записи речи и сброса
class AudioEditEvent extends FrdEvent {
  final bool isAudio;
  const AudioEditEvent({required this.isAudio});
}

/// событие сброса  фокуса после  редактирования ячейки
class FocusHasEditEvent extends FrdEvent {}

/// событие добавления новой операции
class AddOperationEvent extends FrdEvent {}

/// сбрасываем фокус
class RemoveFocusAllEvent extends FrdEvent {}

/// событие сохранения фрд
class SaveFrdEvent extends FrdEvent {}

/// событие добавления правильного времени операции в последнюю операциию
class AddTimeToLastEvent extends FrdEvent {
  const AddTimeToLastEvent();
}

/// событие добавления таймера каждую секунду в ячейку
class AddTimerEvent extends FrdEvent {
  final Duration seconds;
  const AddTimerEvent({required this.seconds});
}

/// событие окончания редактирования ячейки
class EndEditCellEvent extends FrdEvent {
  final DataEditCellFrd dataCell;
  final ColumnsDataFrd columnsData;

  const EndEditCellEvent({required this.dataCell, required this.columnsData});
}
