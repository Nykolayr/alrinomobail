import 'package:alrino/common/constants.dart';
import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/sz/sz.dart';
import 'package:alrino/domain/models/sz/sz_operation.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/presentation/screens/sz/table/columns_sz.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'sz_event.dart';
part 'sz_state.dart';

class SzBloc extends Bloc<SzEvent, SzState> {
  SzBloc() : super(SzState.initial()) {
    on<NewSzEvent>(_onNewSzEvent);
    on<EndEditCellEvent>(_onEndEditCellEvent);
    on<AddOperationEvent>(_onAddOperationEvent);
    on<AddTimerEvent>(_onAddTimerEvent);
    on<FocusAddEditEvent>(_onFocusAddEditEvent);
    on<FocusHasEditEvent>(_onFocusHasEditEvent);
    on<AudioEditEvent>(_onAudioEditEvent);
    on<NewOperationsEvent>(_onNewOperationsEvent);
    on<SaveOperationsEvent>(_onSaveOperationsEvent);
    on<SaveHistoryEvent>(_onSaveHistoryEvent);
    on<RemoveFocusAllEvent>(_onRemoveFocusAllEvent);
    on<FocusLastEditEvent>(_onFocusLastEditEvent);
    on<AddFocusInStatevent>(_onAddFocusInStatevent);
    on<SetIsOuterEvent>(_onSetIsOuterEvent);
    on<AddEditCell>(_onAddEditCell);
    on<AddTimeToLastEvent>(_onAddTimeToLastEvent);
    on<AddDurationEvent>(_onAddDurationEvent);
  }

  ///  добавление дополнительного времени для работы
  Future<void> _onAddDurationEvent(
      AddDurationEvent event, Emitter<SzState> emit) async {
    Sz sz = state.sz;
    sz.maxWorkTimer += event.duration;
    emit(state.copyWith(sz: sz));
  }

  /// событие добавления таймера каждую секунду в ячейку
  Future<void> _onAddTimerEvent(
      AddTimerEvent event, Emitter<SzState> emit) async {
    Sz sz = state.sz;

    if (sz.operations.isNotEmpty) {
      sz.operations.last.durationOperation = event.seconds;

      sz.workTime += const Duration(milliseconds: 100);
      if (sz.workTime > maxTimerConst) {
        emit(state.copyWith(sz: sz, isEndTimer: true));
      }
      if (sz.workTime > sz.maxWorkTimer) {
        emit(state.copyWith(sz: sz, isTimer: true));
      }

      emit(state.copyWith(sz: sz, isTimer: false, isEndTimer: false));
    }
  }

  /// событие добавления правильного времени операции в последнюю операциию
  Future<void> _onAddTimeToLastEvent(
      AddTimeToLastEvent event, Emitter<SzState> emit) async {
    Sz sz = state.sz;
    final lastId = sz.operations.isEmpty ? 0 : sz.operations.last.id;
    final newOperation = OperationSz.initial();
    newOperation.id = lastId + 1;
    newOperation.beginDate = DateTime.now();
    sz.endTime = newOperation.beginDate;
    sz.operations.last.durationOperation = Utils.getDurationDifferent(
      sz.operations.last.beginDate,
      newOperation.beginDate,
    );
    emit(state.copyWith(lastOperation: newOperation, sz: sz));
    emit(state.copyWith(sz: sz, lastOperation: newOperation));
  }

  /// добавляем фокус на ячейке и ее редактировании
  Future<void> _onAddEditCell(AddEditCell event, Emitter<SzState> emit) async {
    emit(state.copyWith(
      editColumn: event.columnsData,
      editRow: event.indexRow,
      isEdit: event.indexRow == -1 ? false : true,
      isFocus: event.indexRow == -1 ? false : true,
    ));
    await Future.delayed(const Duration(milliseconds: 100));
    state.focus.requestFocus();
  }

  /// устанавливаем на выезде или дома сделан хронометраж
  Future<void> _onSetIsOuterEvent(
      SetIsOuterEvent event, Emitter<SzState> emit) async {
    Sz sz = state.sz;
    sz.isOuter = !sz.isOuter;
    emit(state.copyWith(sz: sz));
  }

  /// добавляем фокус ячейки
  Future<void> _onAddFocusInStatevent(
      AddFocusInStatevent event, Emitter<SzState> emit) async {
    emit(state.copyWith(
      focus: event.focus,
      isFocus: true,
      isEdit: true,
      editController: event.controller,
    ));
    FocusLastEditEvent();
  }

  /// фокусировка на последнюю
  Future<void> _onFocusLastEditEvent(
      FocusLastEditEvent event, Emitter<SzState> emit) async {
    emit(state.copyWith(
      editColumn: ColumnsDataSz.org,
      editRow: state.sz.operations.length - 1,
      isEdit: true,
      isFocus: true,
    ));
    await Future.delayed(const Duration(milliseconds: 100));
    state.focus.requestFocus();
  }

  /// сбрасываем фокус
  Future<void> _onRemoveFocusAllEvent(
      RemoveFocusAllEvent event, Emitter<SzState> emit) async {
    emit(state.copyWith(
      isFocus: true,
      isEdit: true,
    ));
    await Future.delayed(const Duration(milliseconds: 50));
    emit(state.copyWith(
      isFocus: false,
      isEdit: false,
    ));
  }

  /// сохранение таблицы на eccel в локалку и выход из таблицы
  Future<void> _onSaveHistoryEvent(
      SaveHistoryEvent event, Emitter<SzState> emit) async {
    emit(state.copyWith(isLoading: true));
    Sz sz = state.sz;
    sz.operations = [];
    Get.find<FrdRepository>().tempSz = sz;
    await Get.find<FrdRepository>().saveAll();
    emit(state.copyWith(isLoading: false));
    emit(state.copyWith(sz: sz));
  }

  /// сохранение таблицы в локал
  Future<void> _onSaveOperationsEvent(
      SaveOperationsEvent event, Emitter<SzState> emit) async {
    emit(state.copyWith(isLoading: true));
    Get.find<FrdRepository>().tempSz = state.sz;
    await Get.find<FrdRepository>().saveAll();
    emit(state.copyWith(isLoading: false));
  }

  /// начало редактирование таблицы
  Future<void> _onNewOperationsEvent(
      NewOperationsEvent event, Emitter<SzState> emit) async {
    emit(state.copyWith(sz: Get.find<FrdRepository>().tempSz));
  }

  ///  добавление записи речи и сброса
  Future<void> _onAudioEditEvent(
      AudioEditEvent event, Emitter<SzState> emit) async {
    emit(state.copyWith(isAudio: event.isAudio, isEdit: true));
  }

  /// событие сброса  фокуса после  редактирования ячейки
  Future<void> _onFocusHasEditEvent(
      FocusHasEditEvent event, Emitter<SzState> emit) async {
    state.focus.unfocus();
    emit(state.copyWith(editRow: -1));
  }

  /// событие фокуса на редактировании ячейки
  Future<void> _onFocusAddEditEvent(
      FocusAddEditEvent event, Emitter<SzState> emit) async {
    emit(state.copyWith(
      isEdit: true,
      isAudio: false,
      editController: event.controller,
      editRow: event.indexRow,
      editColumn: event.columnsData,
    ));
  }

  /// событие добавления новой операции
  Future<void> _onAddOperationEvent(
      AddOperationEvent event, Emitter<SzState> emit) async {
    Sz sz = state.sz;
    final lastId = sz.operations.isEmpty ? 0 : sz.operations.last.id;
    final newOperation = OperationSz.initial();
    newOperation.id = lastId + 1;
    newOperation.beginDate = DateTime.now();
    if (sz.operations.isNotEmpty) {
      sz.operations.last.durationOperation = Utils.getDurationDifferent(
        sz.operations.last.beginDate,
        newOperation.beginDate,
      );
    }
    sz.operations.add(newOperation);
    emit(state.copyWith(
      sz: sz,
      editRow: lastId + 1,
      editColumn: ColumnsDataSz.org,
    ));
  }

  /// событие окончания редактирования ячейки
  Future<void> _onEndEditCellEvent(
      EndEditCellEvent event, Emitter<SzState> emit) async {
    Sz sz = state.sz;
    event.columnsData.setEditFrd(sz, event.dataCell);
    Get.find<FrdRepository>().tempSz = state.sz;
    Get.find<FrdRepository>().saveSzToLocal();
    emit(state.copyWith(sz: sz));
  }

  /// событие сохранения sz
  Future<void> _onNewSzEvent(NewSzEvent event, Emitter<SzState> emit) async {
    Sz sz = Sz.initial();
    emit(state.copyWith(sz: sz));
  }
}
