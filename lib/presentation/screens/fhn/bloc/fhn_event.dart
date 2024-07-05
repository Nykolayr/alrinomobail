part of 'fhn_bloc.dart';

sealed class FhnEvent extends Equatable {
  const FhnEvent();

  @override
  List<Object> get props => [];
}

/// добавляем фокус на ячейке и ее редактировании
class AddEditCell extends FhnEvent {
  final int indexRow;
  final ColumnsDataFhn columnsData;
  const AddEditCell({required this.indexRow, required this.columnsData});
}

/// инициализация fhn
class InitFhnEvent extends FhnEvent {}

/// сохранение шаблона
class SavePatternEvent extends FhnEvent {}

/// добавляем фокус ячейки
class AddFocusInStatevent extends FhnEvent {
  final FocusNode focus;
  final TextEditingController controller;
  const AddFocusInStatevent({required this.focus, required this.controller});
}

/// фокусировка на последнюю
class FocusLastEditEvent extends FhnEvent {}

/// добавление столбца в таблицу
class AddColumnTableEvent extends FhnEvent {
  final String name;
  const AddColumnTableEvent({required this.name});
}

/// удаление столбца в таблицу
class RemoveColumnTableEvent extends FhnEvent {
  final int index;
  const RemoveColumnTableEvent({required this.index});
}

/// сохранение таблицы на eccel в локалку и выход из таблицы
class SaveHistoryEvent extends FhnEvent {}

/// сохранение таблицы на сервер
class SaveServerOperationsEvent extends FhnEvent {}

/// сохранение таблицы в локал
class SaveOperationsEvent extends FhnEvent {
  const SaveOperationsEvent();
}

/// начало редактирование таблицы
class NewOperationsEvent extends FhnEvent {}

/// событие фокуса на редактировании ячейки
class FocusAddEditEvent extends FhnEvent {
  final TextEditingController controller;
  final int indexRow;
  final ColumnsDataFhn columnsData;
  const FocusAddEditEvent(
      {required this.controller,
      required this.indexRow,
      required this.columnsData});
}

/// событие добавления правильного времени операции в последнюю операциию
class AddTimeToLastEvent extends FhnEvent {
  const AddTimeToLastEvent();
}

///  добавление записи речи и сброса
class AudioEditEvent extends FhnEvent {
  final bool isAudio;
  const AudioEditEvent({required this.isAudio});
}

/// событие сброса  фокуса после  редактирования ячейки
class FocusHasEditEvent extends FhnEvent {}

/// событие добавления новой операции
class AddOperationEvent extends FhnEvent {}

/// сбрасываем фокус
class RemoveFocusAllEvent extends FhnEvent {}

/// событие добавления таймера каждую секунду в ячейку
class AddTimerEvent extends FhnEvent {
  final Duration seconds;
  const AddTimerEvent({required this.seconds});
}

/// событие окончания редактирования ячейки
class EndEditCellEvent extends FhnEvent {
  final DataEditCellFhn dataCell;
  final ColumnsDataFhn columnsData;

  const EndEditCellEvent({required this.dataCell, required this.columnsData});
}
