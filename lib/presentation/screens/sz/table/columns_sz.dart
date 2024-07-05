import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/sz/sz.dart';
import 'package:alrino/domain/models/sz/sz_operation.dart';
import 'package:alrino/presentation/screens/sz/bloc/sz_bloc.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// перечисление колонок таблицы СЗ и методы для работы с ними
enum ColumnsDataSz {
  id,
  org,
  beginDate,
  durationOperation,
  tasks;

  bool get isEdit {
    switch (this) {
      case ColumnsDataSz.org:
      case ColumnsDataSz.tasks:
        return true;
      case ColumnsDataSz.beginDate:
      case ColumnsDataSz.durationOperation:
      case ColumnsDataSz.id:
        return false;
    }
  }

  void setEditFrd(Sz sz, DataEditCellSz dataCell) {
    switch (dataCell.columnsData) {
      case ColumnsDataSz.org:
        sz.operations[dataCell.indexRow].linesEdit[0] = dataCell.linesEdit;
        sz.operations[dataCell.indexRow].org = dataCell.text;
        break;
      case ColumnsDataSz.tasks:
        sz.operations[dataCell.indexRow].linesEdit[1] = dataCell.linesEdit;
        sz.operations[dataCell.indexRow].tasks = dataCell.text;
        break;
      case ColumnsDataSz.beginDate:
      case ColumnsDataSz.durationOperation:
      case ColumnsDataSz.id:
        break;
    }
  }

  String getValue(int indexRow) {
    OperationSz operationsSz = Get.find<SzBloc>().state.sz.operations[indexRow];
    switch (this) {
      case ColumnsDataSz.id:
        return operationsSz.id.toString();
      case ColumnsDataSz.org:
        return operationsSz.org;
      case ColumnsDataSz.beginDate:
        return Utils.getFormatDateHourWithSeconds(operationsSz.beginDate);
      case ColumnsDataSz.durationOperation:
        return Utils.getFormatDuration(operationsSz.durationOperation);
      case ColumnsDataSz.tasks:
        return operationsSz.tasks;
    }
  }

  DataGridCell<String> getCell(OperationSz operation) {
    switch (this) {
      case ColumnsDataSz.id:
        return DataGridCell(columnName: name, value: operation.id.toString());
      case ColumnsDataSz.org:
        return DataGridCell(columnName: name, value: operation.org);
      case ColumnsDataSz.beginDate:
        return DataGridCell(
            columnName: name,
            value: Utils.getFormatDateHourWithSeconds(operation.beginDate));
      case ColumnsDataSz.durationOperation:
        return DataGridCell(
            columnName: name,
            value: Utils.getFormatDuration(operation.durationOperation));

      case ColumnsDataSz.tasks:
        return DataGridCell(columnName: name, value: operation.tasks);
    }
  }

  double get width {
    switch (this) {
      case ColumnsDataSz.id:
        return 30;
      case ColumnsDataSz.org:
        return 240;
      case ColumnsDataSz.beginDate:
      case ColumnsDataSz.durationOperation:
        return 85;
      case ColumnsDataSz.tasks:
        return 0;
      default:
        return 100; // or some default width
    }
  }

  double get widthExcel {
    switch (this) {
      case ColumnsDataSz.id:
        return 10;
      case ColumnsDataSz.org:
        return 80;
      case ColumnsDataSz.beginDate:
      case ColumnsDataSz.durationOperation:
        return 20;
      case ColumnsDataSz.tasks:
        return 120;
    }
  }

  String get label {
    switch (this) {
      case ColumnsDataSz.id:
        return '№\nп/п';
      case ColumnsDataSz.org:
        return 'Проект';
      case ColumnsDataSz.beginDate:
        return 'Текущее время\n(чч:мм:сс)';
      case ColumnsDataSz.durationOperation:
        return 'Время окончания\n(чч:мм:сс)';
      case ColumnsDataSz.tasks:
        return 'Краткое описание выполненных задач';
    }
  }
}

GridColumn getGridFrd(ColumnsDataSz data) {
  return GridColumn(
    allowEditing: false,
    width: data.width == 0 ? double.nan : data.width,
    allowSorting: false,
    columnName: data.name,
    label: getLabelHeader(data.label),
  );
}

List<GridColumn> getGridColumnsSz(List<OperationSz> operationsSz) {
  return [...ColumnsDataSz.values.map((item) => getGridFrd(item)).toList()];
}

/// возвращает title для таблицы
Widget getLabelHeader(String text) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      color: AppColor.blueTable,
    ),
    child: Text(
      text,
      style: AppText.title12.copyWith(color: AppColor.black),
      textAlign: TextAlign.center,
      softWrap: true,
    ),
  );
}

/// вспомагательный класс для передачи данных о редактируемой ячейки
class DataEditCellSz {
  String text;
  int linesEdit;
  int indexRow;
  ColumnsDataSz columnsData;

  DataEditCellSz({
    required this.text,
    required this.linesEdit,
    required this.indexRow,
    required this.columnsData,
  });
}
