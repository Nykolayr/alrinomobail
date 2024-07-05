import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/frd/frd.dart';
import 'package:alrino/domain/models/frd/frd_operation.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/presentation/screens/frd/table/enum_column_frd.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'frd_event.dart';
part 'frd_state.dart';

class FrdBloc extends Bloc<FrdEvent, FrdState> {
  FrdBloc() : super(FrdState.initial()) {
    on<SaveFrdEvent>(_onSaveFrdEvent);
    on<EndEditCellEvent>(_onEndEditCellEvent);
    on<AddOperationEvent>(_onAddOperationEvent);
    on<AddTimerEvent>(_onAddTimerEvent);
    on<FocusAddEditEvent>(_onFocusAddEditEvent);
    on<FocusHasEditEvent>(_onFocusHasEditEvent);
    on<AudioEditEvent>(_onAudioEditEvent);
    on<NewOperationsEvent>(_onNewOperationsEvent);
    on<SaveOperationsEvent>(_onSaveOperationsEvent);
    on<SaveHistoryEvent>(_onSaveHistoryEvent);
    on<UpdateTableEvent>(_onUpdateTableEvent);
    on<RemoveFocusAllEvent>(_onRemoveFocusAllEvent);
    on<FocusLastEditEvent>(_onFocusLastEditEvent);
    on<AddFocusInStatevent>(_onAddFocusInStatevent);
    on<AddEditCell>(_onAddEditCell);
    on<AddTimeToLastEvent>(_onAddTimeToLastEvent);
  }

  Future<void> _onAddTimeToLastEvent(
      AddTimeToLastEvent event, Emitter<FrdState> emit) async {
    Frd frd = state.frd;
    final lastId = frd.operations.isEmpty ? 0 : frd.operations.last.id;
    final newOperation = OperationFrd.initial();
    newOperation.id = lastId + 1;
    newOperation.beginDate = DateTime.now();
    frd.endTime = newOperation.beginDate;
    frd.operations.last.durationOperation = Utils.getDurationDifferent(
        frd.operations.last.beginDate, newOperation.beginDate);
    emit(state.copyWith(lastOperation: newOperation, frd: frd));
  }

  Future<void> _onAddEditCell(AddEditCell event, Emitter<FrdState> emit) async {
    emit(state.copyWith(
      editColumn: event.columnsData,
      editRow: event.indexRow,
      isEdit: event.indexRow == -1 ? false : true,
      isFocus: event.indexRow == -1 ? false : true,
    ));
    await Future.delayed(const Duration(milliseconds: 100));
    state.focus.requestFocus();
  }

  Future<void> _onAddFocusInStatevent(
      AddFocusInStatevent event, Emitter<FrdState> emit) async {
    emit(state.copyWith(
      focus: event.focus,
      isFocus: true,
      isEdit: true,
      editController: event.controller,
    ));
  }

  Future<void> _onFocusLastEditEvent(
      FocusLastEditEvent event, Emitter<FrdState> emit) async {
    emit(state.copyWith(
      editColumn: ColumnsDataFrd.name,
      editRow: state.frd.operations.length - 1,
      isEdit: true,
      isFocus: true,
    ));
    await Future.delayed(const Duration(milliseconds: 100));
    state.focus.requestFocus();
  }

  Future<void> _onRemoveFocusAllEvent(
      RemoveFocusAllEvent event, Emitter<FrdState> emit) async {
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

  Future<void> _onUpdateTableEvent(
      UpdateTableEvent event, Emitter<FrdState> emit) async {
    emit(state.copyWith(frd: Get.find<FrdRepository>().tempFrd));
  }

  Future<void> _onSaveHistoryEvent(
      SaveHistoryEvent event, Emitter<FrdState> emit) async {
    emit(state.copyWith(isLoading: true));
    Frd frd = state.frd;
    frd.operations = [];
    Get.find<FrdRepository>().tempFrd = frd;
    await Get.find<FrdRepository>().saveAll();
    emit(state.copyWith(isLoading: false));
    emit(state.copyWith(frd: frd));
  }

  Future<void> _onSaveOperationsEvent(
      SaveOperationsEvent event, Emitter<FrdState> emit) async {
    Get.find<FrdRepository>().tempFrd = state.frd;
    await Get.find<FrdRepository>().saveAll();
  }

  Future<void> _onNewOperationsEvent(
      NewOperationsEvent event, Emitter<FrdState> emit) async {
    emit(state.copyWith(frd: Get.find<FrdRepository>().tempFrd));
  }

  Future<void> _onAudioEditEvent(
      AudioEditEvent event, Emitter<FrdState> emit) async {
    emit(state.copyWith(isAudio: event.isAudio, isEdit: true));
  }

  Future<void> _onFocusHasEditEvent(
      FocusHasEditEvent event, Emitter<FrdState> emit) async {
    state.focus.unfocus();
    emit(state.copyWith(editRow: -1));
  }

  Future<void> _onFocusAddEditEvent(
      FocusAddEditEvent event, Emitter<FrdState> emit) async {
    emit(state.copyWith(
      isEdit: true,
      isAudio: false,
      editController: event.controller,
      editRow: event.indexRow,
      editColumn: event.columnsData,
    ));
  }

  Future<void> _onAddTimerEvent(
      AddTimerEvent event, Emitter<FrdState> emit) async {
    Frd frd = state.frd;
    if (frd.operations.isNotEmpty) {
      frd.operations.last.durationOperation = event.seconds;
      emit(state.copyWith(frd: frd));
    }
  }

  Future<void> _onAddOperationEvent(
      AddOperationEvent event, Emitter<FrdState> emit) async {
    Frd frd = state.frd;
    final lastId = frd.operations.isEmpty ? 0 : frd.operations.last.id;
    final newOperation = OperationFrd.initial();
    newOperation.id = lastId + 1;
    newOperation.beginDate = DateTime.now();
    if (frd.operations.isNotEmpty) {
      frd.operations.last.durationOperation = Utils.getDurationDifferent(
        frd.operations.last.beginDate,
        newOperation.beginDate,
      );
    }
    frd.operations.add(newOperation);
    emit(state.copyWith(
      frd: frd,
      editRow: lastId + 1,
      editColumn: ColumnsDataFrd.name,
    ));
  }

  Future<void> _onEndEditCellEvent(
      EndEditCellEvent event, Emitter<FrdState> emit) async {
    Frd frd = state.frd;
    event.columnsData.setEditFrd(frd, event.dataCell);
    Get.find<FrdRepository>().tempFrd = state.frd;
    Get.find<FrdRepository>().saveTempFrdToLocal();
    emit(state.copyWith(frd: frd));
  }

  Future<void> _onSaveFrdEvent(
      SaveFrdEvent event, Emitter<FrdState> emit) async {
    emit(state.copyWith());
  }
}
