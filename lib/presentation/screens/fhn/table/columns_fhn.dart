import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/fhn/fhn.dart';
import 'package:alrino/domain/models/fhn/operations_fhn.dart';
import 'package:alrino/domain/routers/routers.dart';
import 'package:alrino/presentation/screens/fhn/bloc/fhn_bloc.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// перечисление колонок таблицы ФХН и методы для работы с ними
enum ColumnsDataFhn {
  id,
  name,
  beginDate,
  durationOperation,
  col1,
  col2,
  col3,
  col4,
  col5,
  comment,
  problem;

  bool get isEdit {
    switch (this) {
      case ColumnsDataFhn.name:
      case ColumnsDataFhn.comment:
      case ColumnsDataFhn.problem:
      case ColumnsDataFhn.col1:
      case ColumnsDataFhn.col2:
      case ColumnsDataFhn.col3:
      case ColumnsDataFhn.col4:
      case ColumnsDataFhn.col5:
        return true;
      case ColumnsDataFhn.beginDate:
      case ColumnsDataFhn.durationOperation:
      case ColumnsDataFhn.id:
        return false;
    }
  }

  void setEditFrd(Fhn fhn, DataEditCellFhn dataCell) {
    switch (dataCell.columnsData) {
      case ColumnsDataFhn.name:
        if (fhn.operations.isNotEmpty) {
          fhn.operations[dataCell.indexRow].linesEdit[0] = dataCell.linesEdit;
          fhn.operations[dataCell.indexRow].name = dataCell.text;
        }

        break;
      case ColumnsDataFhn.comment:
        if (fhn.operations.isNotEmpty) {
          fhn.operations[dataCell.indexRow].linesEdit[1] = dataCell.linesEdit;
          fhn.operations[dataCell.indexRow].comment = dataCell.text;
        }
        break;
      case ColumnsDataFhn.problem:
        if (fhn.operations.isNotEmpty) {
          fhn.operations[dataCell.indexRow].linesEdit[2] = dataCell.linesEdit;
          fhn.operations[dataCell.indexRow].problem = dataCell.text;
        }
        break;
      case ColumnsDataFhn.col1:
        if (fhn.operations[dataCell.indexRow].addColumns.isNotEmpty) {
          fhn.operations[dataCell.indexRow].linesEdit[6] = dataCell.linesEdit;
          fhn.operations[dataCell.indexRow].addColumns[0].value = dataCell.text;
        }
        break;
      case ColumnsDataFhn.col2:
        if (fhn.operations[dataCell.indexRow].addColumns.length > 1) {
          fhn.operations[dataCell.indexRow].linesEdit[7] = dataCell.linesEdit;
          fhn.operations[dataCell.indexRow].addColumns[1].value = dataCell.text;
        }
        break;
      case ColumnsDataFhn.col3:
        if (fhn.operations[dataCell.indexRow].addColumns.length > 2) {
          fhn.operations[dataCell.indexRow].linesEdit[8] = dataCell.linesEdit;
          fhn.operations[dataCell.indexRow].addColumns[2].value = dataCell.text;
        }
        break;

      case ColumnsDataFhn.col4:
        if (fhn.operations[dataCell.indexRow].addColumns.length > 3) {
          fhn.operations[dataCell.indexRow].linesEdit[9] = dataCell.linesEdit;
          fhn.operations[dataCell.indexRow].addColumns[3].value = dataCell.text;
        }
        break;
      case ColumnsDataFhn.col5:
        if (fhn.operations[dataCell.indexRow].addColumns.length > 4) {
          fhn.operations[dataCell.indexRow].linesEdit[10] = dataCell.linesEdit;
          fhn.operations[dataCell.indexRow].addColumns[4].value = dataCell.text;
        }

      case ColumnsDataFhn.beginDate:
      case ColumnsDataFhn.durationOperation:
      case ColumnsDataFhn.id:
        break;
    }
  }

  String getValue(int indexRow) {
    OperationFhn operationsFhn =
        Get.find<FhnBloc>().state.fhn.operations[indexRow];
    switch (this) {
      case ColumnsDataFhn.id:
        return operationsFhn.id.toString();
      case ColumnsDataFhn.name:
        return operationsFhn.name;
      case ColumnsDataFhn.beginDate:
        return Utils.getFormatDateHourWithSeconds(operationsFhn.beginDate);
      case ColumnsDataFhn.durationOperation:
        return Utils.getFormatDuration(operationsFhn.durationOperation);
      case ColumnsDataFhn.comment:
        return operationsFhn.comment;
      case ColumnsDataFhn.problem:
        return operationsFhn.problem;
      case ColumnsDataFhn.col1:
        if (operationsFhn.addColumns.isNotEmpty) {
          return operationsFhn.addColumns[0].value;
        } else {
          return '';
        }
      case ColumnsDataFhn.col2:
        if (operationsFhn.addColumns.length > 1) {
          return operationsFhn.addColumns[1].value;
        } else {
          return '';
        }
      case ColumnsDataFhn.col3:
        if (operationsFhn.addColumns.length > 2) {
          return operationsFhn.addColumns[2].value;
        } else {
          return '';
        }
      case ColumnsDataFhn.col4:
        if (operationsFhn.addColumns.length > 3) {
          return operationsFhn.addColumns[3].value;
        } else {
          return '';
        }
      case ColumnsDataFhn.col5:
        if (operationsFhn.addColumns.length > 4) {
          return operationsFhn.addColumns[4].value;
        } else {
          return '';
        }
    }
  }

  DataGridCell<String> getCell(OperationFhn operation) {
    switch (this) {
      case ColumnsDataFhn.id:
        return DataGridCell(
            columnName: this.name, value: operation.id.toString());
      case ColumnsDataFhn.name:
        return DataGridCell(columnName: this.name, value: operation.name);
      case ColumnsDataFhn.beginDate:
        return DataGridCell(
            columnName: this.name,
            value: Utils.getFormatDateHourWithSeconds(operation.beginDate));
      case ColumnsDataFhn.durationOperation:
        return DataGridCell(
            columnName: this.name,
            value: Utils.getFormatDuration(operation.durationOperation));
      case ColumnsDataFhn.comment:
        return DataGridCell(columnName: this.name, value: operation.comment);
      case ColumnsDataFhn.problem:
        return DataGridCell(columnName: this.name, value: operation.problem);
      case ColumnsDataFhn.col1:
        if (operation.addColumns.isNotEmpty) {
          return DataGridCell(
              columnName: this.name, value: operation.addColumns[0].value);
        } else {
          return DataGridCell(columnName: this.name, value: '');
        }

      case ColumnsDataFhn.col2:
        if (operation.addColumns.length > 1) {
          return DataGridCell(
              columnName: this.name, value: operation.addColumns[1].value);
        } else {
          return DataGridCell(columnName: this.name, value: '');
        }
      case ColumnsDataFhn.col3:
        if (operation.addColumns.length > 2) {
          return DataGridCell(
              columnName: this.name, value: operation.addColumns[2].value);
        } else {
          return DataGridCell(columnName: this.name, value: '');
        }
      case ColumnsDataFhn.col4:
        if (operation.addColumns.length > 3) {
          return DataGridCell(
              columnName: this.name, value: operation.addColumns[3].value);
        } else {
          return DataGridCell(columnName: this.name, value: '');
        }
      case ColumnsDataFhn.col5:
        if (operation.addColumns.length > 4) {
          return DataGridCell(
              columnName: this.name, value: operation.addColumns[4].value);
        } else {
          return DataGridCell(columnName: this.name, value: '');
        }
    }
  }

  double get width {
    Fhn fhn = Get.find<FhnBloc>().state.fhn;
    double widthColumn = 85;
    BuildContext? context = router.configuration.navigatorKey.currentContext;
    if (context != null) {
      double width = MediaQuery.of(context).size.width;
      widthColumn = (width - 490) / (fhn.addColumns.length + 2);
      if (widthColumn < 60) {
        widthColumn = 80;
      }
    }

    switch (this) {
      case ColumnsDataFhn.id:
        return 30;
      case ColumnsDataFhn.name:
        return 200;
      case ColumnsDataFhn.beginDate:
      case ColumnsDataFhn.durationOperation:
        return widthColumn;
      case ColumnsDataFhn.comment:
      case ColumnsDataFhn.problem:
        return 90;
      case ColumnsDataFhn.col1:
        return (fhn.addColumns.isNotEmpty) ? widthColumn : 0;
      case ColumnsDataFhn.col2:
        return fhn.addColumns.length > 1 ? widthColumn : 0;
      case ColumnsDataFhn.col3:
        return fhn.addColumns.length > 2 ? widthColumn : 0;
      case ColumnsDataFhn.col4:
        return fhn.addColumns.length > 3 ? widthColumn : 0;
      case ColumnsDataFhn.col5:
        return fhn.addColumns.length > 4 ? widthColumn : 0;
      default:
        return widthColumn;
    }
  }

  double get widthExcel {
    Fhn fhn = Get.find<FhnBloc>().state.fhn;
    switch (this) {
      case ColumnsDataFhn.id:
        return 10;
      case ColumnsDataFhn.name:
        return 150;
      case ColumnsDataFhn.beginDate:
      case ColumnsDataFhn.durationOperation:
        return 20;
      case ColumnsDataFhn.comment:
        return 60;
      case ColumnsDataFhn.problem:
        return 50;
      case ColumnsDataFhn.col1:
        return fhn.addColumns.isNotEmpty ? 50 : 0;
      case ColumnsDataFhn.col2:
        return fhn.addColumns.length > 1 ? 50 : 0;
      case ColumnsDataFhn.col3:
        return fhn.addColumns.length > 2 ? 50 : 0;
      case ColumnsDataFhn.col4:
        return fhn.addColumns.length > 3 ? 50 : 0;
      case ColumnsDataFhn.col5:
        return fhn.addColumns.length > 4 ? 50 : 0;
      default:
        return 20;
    }
  }

  String get label {
    Fhn fhn = Get.find<FhnBloc>().state.fhn;
    switch (this) {
      case ColumnsDataFhn.id:
        return '№\nп/п';
      case ColumnsDataFhn.name:
        return 'Наименование элементов операции\n(трудового процесса)';
      case ColumnsDataFhn.beginDate:
        return 'Текущее время\n(чч:мм:сс)';
      case ColumnsDataFhn.durationOperation:
        return 'Время операции\n(чч:мм:сс)';
      case ColumnsDataFhn.col1:
        return fhn.addColumns.isNotEmpty ? fhn.addColumns[0].name : '';
      case ColumnsDataFhn.col2:
        return fhn.addColumns.length > 1 ? fhn.addColumns[1].name : '';
      case ColumnsDataFhn.col3:
        return fhn.addColumns.length > 2 ? fhn.addColumns[2].name : '';
      case ColumnsDataFhn.col4:
        return fhn.addColumns.length > 3 ? fhn.addColumns[3].name : '';
      case ColumnsDataFhn.col5:
        return fhn.addColumns.length > 4 ? fhn.addColumns[4].name : '';
      case ColumnsDataFhn.comment:
        return 'Комментарии';
      case ColumnsDataFhn.problem:
        return 'Проблематика';
    }
  }
}

GridColumn getGridFhn(ColumnsDataFhn data) {
  return GridColumn(
    allowEditing: false,
    width: data.width == 0 ? double.nan : data.width,
    allowSorting: false,
    columnName: data.name,
    label: getLabelHeaderFhn(data.label),
  );
}

List<GridColumn> getGridColumnsFhn() {
  List<GridColumn> list = [];
  for (ColumnsDataFhn item in ColumnsDataFhn.values) {
    if (item.width != 0) list.add(getGridFhn(item));
  }
  return list;
}

/// возвращает title для таблицы
Widget getLabelHeaderFhn(String text) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 2),
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
class DataEditCellFhn {
  String text;
  int linesEdit;
  int indexRow;
  ColumnsDataFhn columnsData;

  DataEditCellFhn({
    required this.text,
    required this.linesEdit,
    required this.indexRow,
    required this.columnsData,
  });
}
