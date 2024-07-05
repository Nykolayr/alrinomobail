import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/frd/frd.dart';
import 'package:alrino/domain/models/frd/frd_operation.dart';
import 'package:alrino/presentation/screens/frd/bloc/frd_bloc.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// перечисление колонок таблицы ФРД и методы для работы с ними
enum ColumnsDataFrd {
  id,
  name,
  beginDate,
  durationOperation,
  comment,
  problem;

  bool get isEdit {
    switch (this) {
      case ColumnsDataFrd.name:
      case ColumnsDataFrd.comment:
      case ColumnsDataFrd.problem:
        return true;
      case ColumnsDataFrd.beginDate:
      case ColumnsDataFrd.durationOperation:
      case ColumnsDataFrd.id:
        return false;
    }
  }

  void setEditFrd(Frd frd, DataEditCellFrd dataCell) {
    switch (dataCell.columnsData) {
      case ColumnsDataFrd.name:
        if (frd.operations.isNotEmpty) {
          frd.operations[dataCell.indexRow].linesEdit[0] = dataCell.linesEdit;
          frd.operations[dataCell.indexRow].name = dataCell.text;
        }
        break;
      case ColumnsDataFrd.comment:
        if (frd.operations.isNotEmpty) {
          frd.operations[dataCell.indexRow].linesEdit[1] = dataCell.linesEdit;
          frd.operations[dataCell.indexRow].comment = dataCell.text;
        }
        break;
      case ColumnsDataFrd.problem:
        if (frd.operations.isNotEmpty) {
          frd.operations[dataCell.indexRow].linesEdit[2] = dataCell.linesEdit;
          frd.operations[dataCell.indexRow].problem = dataCell.text;
        }
        break;
      case ColumnsDataFrd.beginDate:
      case ColumnsDataFrd.durationOperation:
      case ColumnsDataFrd.id:
        break;
    }
  }

  String getValue(int indexRow) {
    OperationFrd operationsFrd =
        Get.find<FrdBloc>().state.frd.operations[indexRow];
    switch (this) {
      case ColumnsDataFrd.id:
        return operationsFrd.id.toString();
      case ColumnsDataFrd.name:
        return operationsFrd.name;
      case ColumnsDataFrd.beginDate:
        return Utils.getFormatDateHourWithSeconds(operationsFrd.beginDate);
      case ColumnsDataFrd.durationOperation:
        return Utils.getFormatDuration(operationsFrd.durationOperation);
      case ColumnsDataFrd.comment:
        return operationsFrd.comment;
      case ColumnsDataFrd.problem:
        return operationsFrd.problem;
    }
  }

  DataGridCell<String> getCell(OperationFrd operation) {
    switch (this) {
      case ColumnsDataFrd.id:
        return DataGridCell(
            columnName: this.name, value: operation.id.toString());
      case ColumnsDataFrd.name:
        return DataGridCell(columnName: this.name, value: operation.name);
      case ColumnsDataFrd.beginDate:
        return DataGridCell(
            columnName: this.name,
            value: Utils.getFormatDateHourWithSeconds(operation.beginDate));
      case ColumnsDataFrd.durationOperation:
        return DataGridCell(
            columnName: this.name,
            value: Utils.getFormatDuration(operation.durationOperation));
      case ColumnsDataFrd.comment:
        return DataGridCell(columnName: this.name, value: operation.comment);
      case ColumnsDataFrd.problem:
        return DataGridCell(columnName: this.name, value: operation.problem);
    }
  }

  double get width {
    switch (this) {
      case ColumnsDataFrd.id:
        return 35;
      case ColumnsDataFrd.name:
        return 0;
      case ColumnsDataFrd.beginDate:
      case ColumnsDataFrd.durationOperation:
        return 85;
      case ColumnsDataFrd.comment:
      case ColumnsDataFrd.problem:
        return 130;
      default:
        return 100; // or some default width
    }
  }

  double get widthExcel {
    switch (this) {
      case ColumnsDataFrd.id:
        return 10;
      case ColumnsDataFrd.name:
        return 150;
      case ColumnsDataFrd.beginDate:
      case ColumnsDataFrd.durationOperation:
        return 20;
      case ColumnsDataFrd.comment:
        return 60;
      case ColumnsDataFrd.problem:
        return 50;
    }
  }

  String get label {
    switch (this) {
      case ColumnsDataFrd.id:
        return '№\nп/п';
      case ColumnsDataFrd.name:
        return 'Наименование элементов операции\n(трудового процесса)';
      case ColumnsDataFrd.beginDate:
        return 'Текущее время\n(чч:мм:сс)';
      case ColumnsDataFrd.durationOperation:
        return 'Время операции\n(чч:мм:сс)';
      case ColumnsDataFrd.comment:
        return 'Комментарии';
      case ColumnsDataFrd.problem:
        return 'Проблематика';
    }
  }
}

GridColumn getGridFrd(ColumnsDataFrd data) {
  return GridColumn(
    allowEditing: false,
    width: data.width == 0 ? double.nan : data.width,
    allowSorting: false,
    columnName: data.name,
    label: getLabelHeader(data.label),
  );
}

List<GridColumn> getGridColumnsFrd(List<OperationFrd> operationsFrd) {
  return [...ColumnsDataFrd.values.map((item) => getGridFrd(item)).toList()];
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
class DataEditCellFrd {
  String text;
  int linesEdit;
  int indexRow;
  ColumnsDataFrd columnsData;

  DataEditCellFrd({
    required this.text,
    required this.linesEdit,
    required this.indexRow,
    required this.columnsData,
  });
}
