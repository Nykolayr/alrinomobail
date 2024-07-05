part of 'sz_bloc.dart';

sealed class SzEvent extends Equatable {
  const SzEvent();

  @override
  List<Object> get props => [];
}

///  добавление дополнительного времени для работы
class AddDurationEvent extends SzEvent {
  final Duration duration;
  const AddDurationEvent({required this.duration});
}

/// добавляем фокус на ячейке и ее редактировании
class AddEditCell extends SzEvent {
  final int indexRow;
  final ColumnsDataSz columnsData;
  const AddEditCell({required this.indexRow, required this.columnsData});
}

/// устанавливаем на выезде или дома сделан хронометраж
class SetIsOuterEvent extends SzEvent {}

/// добавляем фокус ячейки
class AddFocusInStatevent extends SzEvent {
  final FocusNode focus;
  final TextEditingController controller;
  const AddFocusInStatevent({required this.focus, required this.controller});
}

/// событие добавления правильного времени операции в последнюю операциию
class AddTimeToLastEvent extends SzEvent {
  const AddTimeToLastEvent();
}

/// фокусировка на последнюю
class FocusLastEditEvent extends SzEvent {}

/// сохранение таблицы на eccel в локалку и выход из таблицы
class SaveHistoryEvent extends SzEvent {}

/// сохранение таблицы в локал
class SaveOperationsEvent extends SzEvent {}

/// начало редактирование таблицы
class NewOperationsEvent extends SzEvent {}

/// событие фокуса на редактировании ячейки
class FocusAddEditEvent extends SzEvent {
  final TextEditingController controller;
  final int indexRow;
  final ColumnsDataSz columnsData;
  const FocusAddEditEvent(
      {required this.controller,
      required this.indexRow,
      required this.columnsData});
}

///  добавление записи речи и сброса
class AudioEditEvent extends SzEvent {
  final bool isAudio;
  const AudioEditEvent({required this.isAudio});
}

/// событие сброса  фокуса после  редактирования ячейки
class FocusHasEditEvent extends SzEvent {}

/// событие добавления новой операции
class AddOperationEvent extends SzEvent {}

/// сбрасываем фокус
class RemoveFocusAllEvent extends SzEvent {}

/// событие сохранения sz
class NewSzEvent extends SzEvent {}

/// событие добавления таймера каждую секунду в ячейку
class AddTimerEvent extends SzEvent {
  final Duration seconds;
  const AddTimerEvent({
    required this.seconds,
  });
}

/// событие окончания редактирования ячейки
class EndEditCellEvent extends SzEvent {
  final DataEditCellSz dataCell;
  final ColumnsDataSz columnsData;

  const EndEditCellEvent({required this.dataCell, required this.columnsData});
}
