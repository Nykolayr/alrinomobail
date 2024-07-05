part of 'sz_bloc.dart';

class SzState {
  final bool isSucsess;
  final bool isLoading;
  final Sz sz;
  final int editRow;
  final ColumnsDataSz editColumn;
  final TextEditingController editController;
  final FocusNode focus;
  final bool isEdit;
  final bool isAudio;
  final bool isFocus; // для убирание фоксуса со всех ячеек
  final OperationSz lastOperation;
  final bool
      isTimer; // для показа сообщения, о том что, рабочее время закончилось
  final bool isEndTimer; // для принудительного окончания заполнения таблицы

  const SzState({
    required this.isSucsess,
    required this.isLoading,
    required this.sz,
    required this.editRow,
    required this.editColumn,
    required this.editController,
    required this.isEdit,
    required this.isAudio,
    required this.isFocus,
    required this.focus,
    required this.lastOperation,
    required this.isTimer,
    required this.isEndTimer,
  });

  factory SzState.initial() {
    final sz = Get.find<FrdRepository>().tempSz;
    return SzState(
      isSucsess: false,
      isLoading: false,
      sz: sz,
      editRow: -1,
      editColumn: ColumnsDataSz.org,
      editController: TextEditingController(),
      isEdit: false,
      isAudio: false,
      isFocus: false,
      focus: FocusNode(),
      lastOperation: OperationSz.initial(),
      isTimer: false,
      isEndTimer: false,
    );
  }

  SzState copyWith({
    bool? isSucsess,
    bool? isLoading,
    Sz? sz,
    int? editRow,
    ColumnsDataSz? editColumn,
    TextEditingController? editController,
    bool? isEdit,
    bool? isAudio,
    bool? isFocus,
    FocusNode? focus,
    OperationSz? lastOperation,
    bool? isTimer,
    bool? isEndTimer,
  }) {
    return SzState(
      isSucsess: isSucsess ?? this.isSucsess,
      isLoading: isLoading ?? this.isLoading,
      sz: sz ?? this.sz,
      editRow: editRow ?? this.editRow,
      editColumn: editColumn ?? this.editColumn,
      editController: editController ?? this.editController,
      isEdit: isEdit ?? this.isEdit,
      isAudio: isAudio ?? this.isAudio,
      isFocus: isFocus ?? this.isFocus,
      focus: focus ?? this.focus,
      lastOperation: lastOperation ?? this.lastOperation,
      isTimer: isTimer ?? this.isTimer,
      isEndTimer: isEndTimer ?? this.isEndTimer,
    );
  }
}
