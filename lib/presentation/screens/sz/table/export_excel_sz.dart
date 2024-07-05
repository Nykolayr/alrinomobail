import 'dart:math';

import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/sz/sz.dart';
import 'package:alrino/domain/models/sz/sz_operation.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/presentation/screens/sz/sz_table.dart';
import 'package:alrino/presentation/screens/sz/table/columns_sz.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:excel/excel.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

Future<void> exportDataGridToExcelSz() async {
  int beginRow = 11;

  final workbook = szTableKey.currentState!
      .exportToExcelWorkbook(exportStackedHeaders: false);

  final sheet = workbook.worksheets[0];
  sheet.deleteRow(1);

  /// устанавливаем титульные строки с данными СЗ
  sheet.insertRow(1, 12);
  sheet.getRangeByName('A1:F10').cellStyle.bold = true;
  setMergeAndTextCells('A1:F1', 'Сменное задание', sheet);
  sheet.getRangeByName('A1').cellStyle.fontSize = 13;

  /// добавляем нумерную строку
  sheet.insertRow(beginRow + 1, 2);
  for (int i = 1; i <= ColumnsDataSz.values.length; i++) {
    ColumnsDataSz status = ColumnsDataSz.values[i - 1];
    setTextCellsInt(beginRow, i, status.label, sheet);
    setTextCellsInt(beginRow + 1, i, i.toString(), sheet);
  }
  Sz tmpSz = Get.find<FrdRepository>().tempSz;
  Logger.i('tmpSz == ${tmpSz.toJson()}');
  Duration totalDuration = Get.find<FrdRepository>()
      .tempSz
      .operations
      .map((operation) => operation.durationOperation)
      .reduce((value, element) => value + element);

  /// ставим время в миллисекундах
  for (int i = 0; i <= tmpSz.operations.length - 1; i++) {
    OperationSz oper = tmpSz.operations[i];
    int indexRow = beginRow + 4 + i;
    setMergeAndTextCells('P$indexRow',
        Utils.getFormatDateHourWithMilliseconds(oper.beginDate), sheet);
    setMergeAndTextCells('Q$indexRow',
        Utils.getFormatDurationWithMilliseconds(oper.durationOperation), sheet);
    setMergeAndTextCells(
        'C$indexRow', Utils.getFormatDateHour(oper.beginDate), sheet);
    setMergeAndTextCells('D$indexRow',
        Utils.getFormatDurationWithOneCifra(oper.durationOperation), sheet);
  }

  /// добавляем строку с итогами по времени
  setMergeAndTextCells('A${beginRow + 2}:F${beginRow + 2}',
      'Итого: ${Utils.getFormatDuration(totalDuration)}', sheet);

  List<int> bytes = workbook.saveAsStream();
  var excel = Excel.decodeBytes(bytes);
  Sheet sheetObject = excel['Sheet1'];

  /// устанавливаем ширину столбцов, а также посередке
  for (int i = 0; i <= ColumnsDataSz.values.length - 1; i++) {
    ColumnsDataSz status = ColumnsDataSz.values[i];
    sheetObject.setColumnWidth(i, status.widthExcel);
    setCenterCell(beginRow - 1, i, sheetObject);
    setCenterCell(beginRow, i, sheetObject);
  }

  /// устанавливаем выравнивание посередине для столбцов № и время
  for (int i = 0;
      i <= Get.find<FrdRepository>().tempFrd.operations.length - 1;
      i++) {
    int indexRow = beginRow + 3;
    setCenterCell(indexRow + i, 0, sheetObject);
    // Logger.w('cell -== $cell');
    setCenterCell(indexRow + i, 2, sheetObject);
    setCenterCell(indexRow + i, 3, sheetObject);
  }

  /// устанавливаем посередке выравнивание для первой надписи и второй под ней
  setCenterCell(0, 0, sheetObject);
  setBoldCell(0, 0, sheetObject);
  setCenterCell(beginRow + 1, 0, sheetObject);
  setBoldCell(beginRow + 1, 0, sheetObject);
  Random random = Random();
  int randomNumber = random.nextInt(100000);
  Sz sz = Get.find<FrdRepository>().tempSz;
  sz.pathName = 'СЗ_${Utils.getFormatDate(sz.begin)}_$randomNumber.xlsx';
  try {
    await Get.find<FrdRepository>().uploadSz();
  } catch (e) {
    Logger.e('ошибка при выгрузке файла на сервер $e');
    showErrorDialog('ошибка при выгрузке файла на сервер $e');
  }
  Get.find<FrdRepository>().tempSz = Sz.initial();
  Get.find<FrdRepository>().saveSzToLocal();
  workbook.dispose();
}

setCenterCell(int row, int col, Sheet sheet) {
  Data cell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
  if (cell.cellStyle != null) {
    cell.cellStyle = cell.cellStyle!.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center);
  }
}

setBoldCell(int row, int col, Sheet sheet) {
  Data cell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
  cell.cellStyle =
      cell.cellStyle!.copyWith(boldVal: true, fontFamilyVal: 'arial');
}

setMergeAndTextCells(String rangeRow, String text, Worksheet sheet) {
  Range range = sheet.getRangeByName(rangeRow);
  range.merge();
  range.setText(text);
}

setTextCellsInt(int row, int col, String text, Worksheet sheet) {
  Range range = sheet.getRangeByIndex(row, col);
  range.setText(text);
  range.cellStyle.hAlign = HAlignType.center;
}
