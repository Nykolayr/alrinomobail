import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/fhn/fhn.dart';
import 'package:alrino/domain/models/fhn/operations_fhn.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/presentation/screens/fhn/table/columns_fhn.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
part 'fhn_event.dart';
part 'fhn_state.dart';

class FhnBloc extends Bloc<FhnEvent, FhnState> {
  FhnBloc() : super(FhnState.initial()) {
    on<EndEditCellEvent>(_onEndEditCellEvent);
    on<AddOperationEvent>(_onAddOperationEvent);
    on<AddTimerEvent>(_onAddTimerEvent);
    on<FocusAddEditEvent>(_onFocusAddEditEvent);
    on<FocusHasEditEvent>(_onFocusHasEditEvent);
    on<AudioEditEvent>(_onAudioEditEvent);
    on<NewOperationsEvent>(_onNewOperationsEvent);
    on<SaveOperationsEvent>(_onSaveOperationsEvent);
    on<SaveServerOperationsEvent>(_onSaveServerOperationsEvent);
    on<SaveHistoryEvent>(_onSaveHistoryEvent);
    on<RemoveFocusAllEvent>(_onRemoveFocusAllEvent);
    on<AddColumnTableEvent>(_onAddColumnTableEvent);
    on<RemoveColumnTableEvent>(_onRemoveColumnTableEvent);
    on<FocusLastEditEvent>(_onFocusLastEditEvent);
    on<AddFocusInStatevent>(_onAddFocusInStatevent);
    on<SavePatternEvent>(_onSavePatternEvent);
    on<InitFhnEvent>(_onInitFhnEvent);
    on<AddEditCell>(_onAddEditCell);
    on<AddTimeToLastEvent>(_onAddTimeToLastEvent);
  }

  Future<void> _onAddTimeToLastEvent(
      AddTimeToLastEvent event, Emitter<FhnState> emit) async {
    Fhn fhn = state.fhn;
    final lastId = fhn.operations.isEmpty ? 0 : fhn.operations.last.id;
    final newOperation = OperationFhn.initial();
    newOperation.id = lastId + 1;
    newOperation.beginDate = DateTime.now();
    fhn.endTime = newOperation.beginDate;
    fhn.operations.last.durationOperation = Utils.getDurationDifferent(
        fhn.operations.last.beginDate, newOperation.beginDate);
    emit(state.copyWith(lastOperation: newOperation, fhn: fhn));
  }

  Future<void> _onAddEditCell(AddEditCell event, Emitter<FhnState> emit) async {
    emit(state.copyWith(
      editColumn: event.columnsData,
      editRow: event.indexRow,
      isEdit: event.indexRow == -1 ? false : true,
      isFocus: event.indexRow == -1 ? false : true,
    ));
    await Future.delayed(const Duration(milliseconds: 100));
    state.focus.requestFocus();
  }

  Future<void> _onInitFhnEvent(
      InitFhnEvent event, Emitter<FhnState> emit) async {
    emit(state.copyWith(fhn: Fhn.initial()));
  }

  Future<void> _onSavePatternEvent(
      SavePatternEvent event, Emitter<FhnState> emit) async {
    emit(state.copyWith(isLoading: true));
    FhnRepository fhnRepo = Get.find<FhnRepository>();
    fhnRepo.patternsFhn[fhnRepo.curIndexPatternFhn - 1].addColumns = [
      ...state.fhn.addColumns
    ];
    fhnRepo.savePatternToLocal();
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onAddFocusInStatevent(
      AddFocusInStatevent event, Emitter<FhnState> emit) async {
    emit(state.copyWith(
      focus: event.focus,
      isFocus: true,
      isEdit: true,
      editController: event.controller,
    ));
    FocusLastEditEvent();
  }

  Future<void> _onFocusLastEditEvent(
      FocusLastEditEvent event, Emitter<FhnState> emit) async {
    emit(state.copyWith(
      editColumn: ColumnsDataFhn.name,
      editRow: state.fhn.operations.length - 1,
      isEdit: true,
      isFocus: true,
    ));
    await Future.delayed(const Duration(milliseconds: 100));
    state.focus.requestFocus();
  }

  Future<void> _onRemoveColumnTableEvent(
      RemoveColumnTableEvent event, Emitter<FhnState> emit) async {
    RemoveFocusAllEvent();
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 1));
    FhnRepository fhnRepo = Get.find<FhnRepository>();
    Fhn fhn = state.fhn;

    fhn.addColumns.removeAt(event.index);

    for (OperationFhn item in fhn.operations) {
      item.addColumns.removeAt(event.index);
    }
    fhnRepo.patternsFhn[fhnRepo.curIndexPatternFhn - 1].addColumns = [
      ...state.fhn.addColumns
    ];
    fhnRepo.savePatternToLocal();
    emit(state.copyWith(fhn: fhn, isLoading: false));
  }

  Future<void> _onAddColumnTableEvent(
      AddColumnTableEvent event, Emitter<FhnState> emit) async {
    Fhn fhn = state.fhn;
    List<OperationFhn> operations = fhn.operations;
    fhn.addColumns.add(
        AddColumns(id: fhn.addColumns.length + 1, name: event.name, value: ''));
    for (OperationFhn item in operations) {
      item.addColumns.add(AddColumns(
          id: fhn.addColumns.length + 1, name: event.name, value: ''));
    }
    emit(state.copyWith(fhn: fhn));
  }

  Future<void> _onRemoveFocusAllEvent(
      RemoveFocusAllEvent event, Emitter<FhnState> emit) async {
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

  Future<void> _onSaveHistoryEvent(
      SaveHistoryEvent event, Emitter<FhnState> emit) async {
    emit(state.copyWith(isLoading: true));
    Fhn fhn = state.fhn;
    fhn.operations = [];
    Get.find<FhnRepository>().tempFhn = fhn;
    await Get.find<FhnRepository>().saveAll();
    emit(state.copyWith(isLoading: false));
    emit(state.copyWith(fhn: fhn));
  }

  Future<void> _onSaveServerOperationsEvent(
      SaveServerOperationsEvent event, Emitter<FhnState> emit) async {
    Get.find<FhnRepository>().tempFhn = state.fhn;
    await Get.find<FhnRepository>().saveAll();
  }

  Future<void> _onSaveOperationsEvent(
      SaveOperationsEvent event, Emitter<FhnState> emit) async {
    emit(state.copyWith(isLoading: true));
    Get.find<FhnRepository>().tempFhn = state.fhn;
    await Get.find<FhnRepository>().saveAll();
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onNewOperationsEvent(
      NewOperationsEvent event, Emitter<FhnState> emit) async {
    emit(state.copyWith(fhn: Get.find<FhnRepository>().tempFhn));
  }

  Future<void> _onAudioEditEvent(
      AudioEditEvent event, Emitter<FhnState> emit) async {
    emit(state.copyWith(isAudio: event.isAudio, isEdit: true));
  }

  Future<void> _onFocusHasEditEvent(
      FocusHasEditEvent event, Emitter<FhnState> emit) async {
    state.focus.unfocus();
    emit(state.copyWith(editRow: -1));
  }

  Future<void> _onFocusAddEditEvent(
      FocusAddEditEvent event, Emitter<FhnState> emit) async {
    emit(state.copyWith(
      isEdit: true,
      isAudio: false,
      editController: event.controller,
      editRow: event.indexRow,
      editColumn: event.columnsData,
    ));
  }

  Future<void> _onAddTimerEvent(
      AddTimerEvent event, Emitter<FhnState> emit) async {
    Fhn fhn = state.fhn;
    if (fhn.operations.isNotEmpty) {
      fhn.operations.last.durationOperation = event.seconds;
      emit(state.copyWith(fhn: fhn));
    }
  }

  Future<void> _onAddOperationEvent(
      AddOperationEvent event, Emitter<FhnState> emit) async {
    Fhn fhn = state.fhn;
    final lastId = fhn.operations.isEmpty ? 0 : fhn.operations.last.id;
    final newOperation = OperationFhn.initial();
    newOperation.id = lastId + 1;
    newOperation.beginDate = DateTime.now();
    if (fhn.operations.isNotEmpty) {
      fhn.operations.last.durationOperation = Utils.getDurationDifferent(
        fhn.operations.last.beginDate,
        newOperation.beginDate,
      );
    }
    for (var item in fhn.addColumns) {
      newOperation.addColumns
          .add(AddColumns(id: item.id, name: item.name, value: ''));
    }
    fhn.operations.add(newOperation);
    emit(state.copyWith(
      fhn: fhn,
      editRow: lastId + 1,
      editColumn: ColumnsDataFhn.name,
    ));
  }

  Future<void> _onEndEditCellEvent(
      EndEditCellEvent event, Emitter<FhnState> emit) async {
    Fhn fhn = state.fhn;
    event.columnsData.setEditFrd(fhn, event.dataCell);
    Get.find<FhnRepository>().tempFhn = state.fhn;
    Get.find<FhnRepository>().savefhnToLocal();
    emit(state.copyWith(fhn: fhn));
  }
}
