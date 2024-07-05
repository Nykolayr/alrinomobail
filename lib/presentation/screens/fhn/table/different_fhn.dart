import 'package:alrino/domain/models/fhn/operations_fhn.dart';
import 'package:alrino/presentation/screens/fhn/bloc/fhn_bloc.dart';
import 'package:alrino/presentation/screens/fhn/table/columns_fhn.dart';
import 'package:alrino/presentation/screens/fhn/table/edit_cell_fhn.dart';
import 'package:alrino/presentation/widgets/edit_cell/audio_circle.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FhnDataSource extends DataGridSource {
  final DataGridController dataGridcontroller;
  final Function(String) onSubmit;
  // String newCellValue = '';
  FhnDataSource(this.operationsFhn,
      {required this.dataGridcontroller, required this.onSubmit});
  List<DataGridRow> employeesThis = [];
  final List<OperationFhn> operationsFhn;

  @override
  List<DataGridRow> get rows => operationsFhn.map<DataGridRow>((operation) {
        List<DataGridCell<dynamic>> cells = [];
        for (ColumnsDataFhn item in ColumnsDataFhn.values) {
          if (item.width != 0) {
            cells.add(item.getCell(operation));
          }
        }

        return DataGridRow(cells: cells);
      }).toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    FhnBloc bloc = Get.find<FhnBloc>();
    int indexRow = int.parse(row.getCells()[0].value) - 1;

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      String value = ColumnsDataFhn.values
          .firstWhere((element) => element.name == dataGridCell.columnName)
          .getValue(indexRow);
      ColumnsDataFhn columnsData = ColumnsDataFhn.values
          .firstWhere((element) => element.name == dataGridCell.columnName);
      bool isEditCell = columnsData != ColumnsDataFhn.id &&
          columnsData != ColumnsDataFhn.beginDate &&
          columnsData != ColumnsDataFhn.durationOperation;
      bool isAudio = columnsData == ColumnsDataFhn.id &&
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
            ? EditCellFhn(
                isAhead: dataGridCell.columnName == ColumnsDataFhn.name.name,
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
