part of 'frd_bloc.dart';

class FrdState {
  final bool isSucsess;
  final bool isLoading;
  final Frd frd;
  final int editRow;
  final ColumnsDataFrd editColumn;
  final TextEditingController editController;
  final FocusNode focus;
  final bool isEdit;
  final bool isAudio;
  final bool isFocus; // для убирание фоксуса со всех ячеек
  final OperationFrd lastOperation;

  const FrdState({
    required this.isSucsess,
    required this.isLoading,
    required this.frd,
    required this.editRow,
    required this.editColumn,
    required this.editController,
    required this.isEdit,
    required this.isAudio,
    required this.isFocus,
    required this.focus,
    required this.lastOperation,
  });

  factory FrdState.initial() {
    final curFrd = Get.find<FrdRepository>().tempFrd;
    return FrdState(
      isSucsess: false,
      isLoading: false,
      frd: curFrd,
      editRow: -1,
      editColumn: ColumnsDataFrd.name,
      editController: TextEditingController(),
      isEdit: false,
      isAudio: false,
      isFocus: false,
      focus: FocusNode(),
      lastOperation: OperationFrd.initial(),
    );
  }

  FrdState copyWith({
    bool? isSucsess,
    bool? isLoading,
    Frd? frd,
    int? editRow,
    ColumnsDataFrd? editColumn,
    TextEditingController? editController,
    bool? isEdit,
    bool? isAudio,
    bool? isFocus,
    FocusNode? focus,
    OperationFrd? lastOperation,
  }) {
    return FrdState(
      isSucsess: isSucsess ?? this.isSucsess,
      isLoading: isLoading ?? this.isLoading,
      frd: frd ?? this.frd,
      editRow: editRow ?? this.editRow,
      editColumn: editColumn ?? this.editColumn,
      editController: editController ?? this.editController,
      isEdit: isEdit ?? this.isEdit,
      isAudio: isAudio ?? this.isAudio,
      isFocus: isFocus ?? this.isFocus,
      focus: focus ?? this.focus,
      lastOperation: lastOperation ?? this.lastOperation,
    );
  }
}
