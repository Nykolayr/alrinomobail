part of 'fhn_bloc.dart';

class FhnState {
  final bool isSucsess;
  final bool isLoading;
  final Fhn fhn;
  final int editRow;
  final ColumnsDataFhn editColumn;
  final TextEditingController editController;
  final bool isEdit;
  final bool isAudio;
  final FocusNode focus;
  final bool isFocus; // для убирание фоксуса со всех ячеек
  final OperationFhn lastOperation;

  const FhnState({
    required this.isSucsess,
    required this.isLoading,
    required this.fhn,
    required this.editRow,
    required this.editColumn,
    required this.editController,
    required this.isEdit,
    required this.isAudio,
    required this.isFocus,
    required this.focus,
    required this.lastOperation,
  });

  factory FhnState.initial() {
    final curFhn = Get.find<FhnRepository>().tempFhn;
    return FhnState(
      isSucsess: false,
      isLoading: false,
      fhn: curFhn,
      editRow: -1,
      editColumn: ColumnsDataFhn.name,
      editController: TextEditingController(),
      isEdit: false,
      isAudio: false,
      isFocus: false,
      focus: FocusNode(),
      lastOperation: OperationFhn.initial(),
    );
  }

  FhnState copyWith({
    bool? isSucsess,
    bool? isLoading,
    Fhn? fhn,
    int? editRow,
    ColumnsDataFhn? editColumn,
    TextEditingController? editController,
    bool? isEdit,
    bool? isAudio,
    bool? isFocus,
    FocusNode? focus,
    OperationFhn? lastOperation,
  }) {
    return FhnState(
      isSucsess: isSucsess ?? this.isSucsess,
      isLoading: isLoading ?? this.isLoading,
      fhn: fhn ?? this.fhn,
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
