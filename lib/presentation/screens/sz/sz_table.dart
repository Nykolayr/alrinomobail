import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/presentation/screens/sz/bloc/sz_bloc.dart';
import 'package:alrino/presentation/screens/sz/table/column_right_sz.dart';
import 'package:alrino/presentation/screens/sz/table/columns_sz.dart';
import 'package:alrino/presentation/screens/sz/table/different_sz.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final GlobalKey<SfDataGridState> szTableKey = GlobalKey<SfDataGridState>();

/// Страница СЗ
class SzPage extends StatefulWidget {
  const SzPage({Key? key}) : super(key: key);

  @override
  SzPageState createState() => SzPageState();
}

class SzPageState extends State<SzPage> {
  final DataGridController dataGridcontroller = DataGridController();
  final ScrollController scrollController = ScrollController();

  SzBloc bloc = Get.find<SzBloc>();
  FocusScopeNode focusScopeNode = FocusScopeNode();
  @override
  void initState() {
    Get.find<FrdRepository>().emptyValuesFrd();
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
        body: BlocBuilder<SzBloc, SzState>(
            bloc: bloc,
            buildWhen: (previous, current) {
              if (previous.isFocus != current.isFocus) {
                if (current.isFocus) removeFocusFromTextFields();
              }
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
                                  verticalScrollController: scrollController,
                                  key: szTableKey,
                                  controller: dataGridcontroller,
                                  onCellTap: (details) {},
                                  onQueryRowHeight: (details) {
                                    int rowIndex = details.rowIndex;
                                    if (rowIndex == 0) return 56;
                                    for (var i = 0;
                                        i < state.sz.operations.length;
                                        i++) {
                                      if (rowIndex - 1 == i) {
                                        List<int> linesEdit =
                                            state.sz.operations[i].linesEdit;
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
                                  source: FrdDataSourceSz(
                                      dataGridcontroller: dataGridcontroller,
                                      state.sz.operations,
                                      onSubmit: (value) async {
                                    {
                                      await Future.delayed(
                                          const Duration(milliseconds: 1000));
                                      dataGridcontroller.scrollToRow(
                                          bloc.state.sz.operations.length - 1);
                                    }
                                  }),
                                  columns:
                                      getGridColumnsSz(state.sz.operations)),
                            ),
                          ),
                          ColumnRightSz(dataGridcontroller: dataGridcontroller),
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
