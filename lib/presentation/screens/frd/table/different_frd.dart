import 'package:alrino/domain/models/frd/frd_operation.dart';
import 'package:alrino/presentation/screens/frd/bloc/frd_bloc.dart';
import 'package:alrino/presentation/screens/frd/table/enum_column_frd.dart';
import 'package:alrino/presentation/widgets/edit_cell/audio_circle.dart';
import 'package:alrino/presentation/screens/frd/table/edit_cell_frd.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FrdDataSourceFrd extends DataGridSource {
  final DataGridController dataGridcontroller;
  final Function(String) onSubmit;
  // String newCellValue = '';
  FrdDataSourceFrd(this.operationsFrd,
      {required this.dataGridcontroller, required this.onSubmit});
  List<DataGridRow> employeesThis = [];
  final List<OperationFrd> operationsFrd;

  @override
  List<DataGridRow> get rows => operationsFrd.map<DataGridRow>((operation) {
        return DataGridRow(cells: [
          ...ColumnsDataFrd.values.map((e) => e.getCell(operation)).toList(),
        ]);
      }).toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    FrdBloc bloc = Get.find<FrdBloc>();
    int indexRow = int.parse(row.getCells()[0].value) - 1;

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      String value = ColumnsDataFrd.values
          .firstWhere((element) => element.name == dataGridCell.columnName)
          .getValue(indexRow);
      ColumnsDataFrd columnsData = ColumnsDataFrd.values
          .firstWhere((element) => element.name == dataGridCell.columnName);
      bool isEditCell = columnsData != ColumnsDataFrd.id &&
          columnsData != ColumnsDataFrd.beginDate &&
          columnsData != ColumnsDataFrd.durationOperation;
      bool isAudio = columnsData == ColumnsDataFrd.id &&
          bloc.state.isAudio &&
          bloc.state.editRow == indexRow;

      return Container(
        decoration: BoxDecoration(
          color: indexRow % 2 == 0 ? AppColor.white : AppColor.grey,
          border: Border.all(color: AppColor.black),
        ),
        alignment: (!columnsData.isEdit) ? Alignment.center : Alignment.topLeft,
        padding: EdgeInsets.all(isAudio ? 0 : 6),
        child: (columnsData.isEdit &&
                bloc.state.editRow == indexRow &&
                bloc.state.editColumn == columnsData)
            ? EditCellFrd(
                isAhead: dataGridCell.columnName == ColumnsDataFrd.name.name,
                columnsData: columnsData,
                indexRow: indexRow,
                text: value,
              )
            : Center(
                child: (isAudio)
                    ? const BlinkingWidget()
                    : GestureDetector(
                        onTap: () {
                          bloc.add(AddEditCell(
                              indexRow: indexRow, columnsData: columnsData));
                        },
                        child: Container(
                          color: Colors.transparent,
                          alignment: isEditCell
                              ? Alignment.centerLeft
                              : Alignment.center,
                          width: double.infinity,
                          child: Text(
                            //Utils.getFormatDateHour(dataGridCell.value)
                            value.toString(),
                            //Utils.getFormatDuration(dataGridCell.value),
                            style: AppText.textField12
                                .copyWith(color: AppColor.black),
                          ),
                        ),
                      ),
              ),
      );
    }).toList());
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    return const SizedBox.shrink();
  }
}
