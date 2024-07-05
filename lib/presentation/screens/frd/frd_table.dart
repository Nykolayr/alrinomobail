import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/presentation/screens/frd/bloc/frd_bloc.dart';
import 'package:alrino/presentation/screens/frd/table/different_frd.dart';
import 'package:alrino/presentation/screens/frd/table/enum_column_frd.dart';
import 'package:alrino/presentation/screens/main/bloc/main_bloc.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/screens/frd/table/column_right_frd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final GlobalKey<SfDataGridState> frdTableKey = GlobalKey<SfDataGridState>();

/// Страница таблицы ФРД
class FrdTablePage extends StatefulWidget {
  const FrdTablePage({Key? key}) : super(key: key);

  @override
  FrdTablePageState createState() => FrdTablePageState();
}

class FrdTablePageState extends State<FrdTablePage> {
  final DataGridController dataGridcontroller = DataGridController();
  final ScrollController scrollController = ScrollController();

  FrdBloc bloc = Get.find<FrdBloc>();
  FocusScopeNode focusScopeNode = FocusScopeNode();

  @override
  void initState() {
    bloc.add(UpdateTableEvent());
    if (!Get.find<MainBloc>().state.isProcess) {
      Get.find<FrdRepository>().emptyValuesFrd();
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    dataGridcontroller.dispose();
    scrollController.dispose();
    focusScopeNode.dispose();
    super.dispose();
  }

  void removeFocusFromTextFields() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<FrdBloc, FrdState>(
            bloc: bloc,
            buildWhen: (previous, current) {
              // if (previous.isFocus != current.isFocus) {
              //   if (current.isFocus) removeFocusFromTextFields();
              // }
              return true;
            },
            builder: (context, state) {
              return FocusScope(
                node: focusScopeNode,
                child: SafeArea(
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              color: AppColor.white,
                              child: SfDataGrid(
                                  verticalScrollPhysics:
                                      const ClampingScrollPhysics(),
                                  horizontalScrollPhysics:
                                      const ClampingScrollPhysics(),
                                  verticalScrollController: scrollController,
                                  key: frdTableKey,
                                  controller: dataGridcontroller,
                                  onCellTap: (details) {},
                                  onQueryRowHeight: (details) {
                                    int rowIndex = details.rowIndex;
                                    if (rowIndex == 0) return 56;
                                    for (var i = 0;
                                        i < state.frd.operations.length;
                                        i++) {
                                      if (rowIndex - 1 == i) {
                                        List<int> linesEdit =
                                            state.frd.operations[i].linesEdit;
                                        int maxLine = linesEdit.fold(
                                            linesEdit.first,
                                            (max, current) =>
                                                max > current ? max : current);
                                        // Logger.w('maxLine $maxLine');
                                        return maxLine == 1
                                            ? 35
                                            : maxLine * 22.0;
                                      }
                                    }
                                    return details.getIntrinsicRowHeight(
                                        details.rowIndex);
                                  },
                                  gridLinesVisibility: GridLinesVisibility.none,
                                  headerGridLinesVisibility:
                                      GridLinesVisibility.none,
                                  allowEditing: true,
                                  columnWidthMode: ColumnWidthMode.fill,
                                  selectionMode: SelectionMode.single,
                                  navigationMode: GridNavigationMode.cell,
                                  editingGestureType: EditingGestureType.tap,
                                  source: FrdDataSourceFrd(
                                      dataGridcontroller: dataGridcontroller,
                                      state.frd.operations,
                                      onSubmit: (value) async {
                                    {
                                      await Future.delayed(
                                          const Duration(milliseconds: 1000));
                                      dataGridcontroller.scrollToRow(
                                          bloc.state.frd.operations.length - 1);
                                    }
                                  }),
                                  columns:
                                      getGridColumnsFrd(state.frd.operations)),
                            ),
                          ),
                          ColumnRightFrd(
                              dataGridcontroller: dataGridcontroller),
                        ],
                      ),
                      if (state.isLoading)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
