import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/presentation/screens/fhn/bloc/fhn_bloc.dart';
import 'package:alrino/presentation/screens/fhn/table/column_right_fhn.dart';
import 'package:alrino/presentation/screens/fhn/table/columns_fhn.dart';
import 'package:alrino/presentation/screens/fhn/table/different_fhn.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../main/bloc/main_bloc.dart';

final GlobalKey<SfDataGridState> fhnTableKey = GlobalKey<SfDataGridState>();

/// Страница таблицы ФХН
class FhnTablePage extends StatefulWidget {
  const FhnTablePage({Key? key}) : super(key: key);

  @override
  State<FhnTablePage> createState() => _FhnTablePageState();
}

class _FhnTablePageState extends State<FhnTablePage>
    with WidgetsBindingObserver {
  final DataGridController dataGridcontroller = DataGridController();
  final ScrollController scrollController = ScrollController();

  FhnBloc bloc = Get.find<FhnBloc>();
  FocusScopeNode focusScopeNode = FocusScopeNode();

  @override
  void initState() {
    if (!Get.find<MainBloc>().state.isProcess) {
      Get.find<FhnRepository>().emptyValuesFhn();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    var mediaQuery = MediaQuery.of(context);
    if (mediaQuery.orientation == Orientation.landscape) {
      setState(() {});
    } else if (mediaQuery.orientation == Orientation.portrait) {
      setState(() {});
    }
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
    WidgetsBinding.instance.removeObserver(this);
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
        body: BlocBuilder<FhnBloc, FhnState>(
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
                                  key: fhnTableKey,
                                  controller: dataGridcontroller,
                                  onCellTap: (details) {},
                                  onQueryRowHeight: (details) {
                                    int rowIndex = details.rowIndex;
                                    if (rowIndex == 0) return 60;
                                    for (var i = 0;
                                        i < state.fhn.operations.length;
                                        i++) {
                                      if (rowIndex - 1 == i) {
                                        List<int> linesEdit =
                                            state.fhn.operations[i].linesEdit;
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
                                  source: FhnDataSource(
                                      dataGridcontroller: dataGridcontroller,
                                      state.fhn.operations,
                                      onSubmit: (value) async {
                                    {
                                      await Future.delayed(
                                          const Duration(milliseconds: 1000));
                                      dataGridcontroller.scrollToRow(
                                          bloc.state.fhn.operations.length - 1);
                                    }
                                  }),
                                  columns: getGridColumnsFhn()),
                            ),
                          ),
                          ColumnRightFhn(
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
