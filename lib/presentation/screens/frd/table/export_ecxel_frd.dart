import 'dart:io';
import 'dart:math';

import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/frd/frd.dart';
import 'package:alrino/domain/models/frd/frd_operation.dart';
import 'package:alrino/domain/models/frd/ftd_history_table.dart';
import 'package:alrino/domain/models/photo_day.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/screens/frd/bloc/frd_bloc.dart';
import 'package:alrino/presentation/screens/frd/table/enum_column_frd.dart';
import 'package:alrino/presentation/screens/frd/frd_table.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

Future<void> exportDataGridToExcelFrd() async {
  FrdBloc bloc = Get.find<FrdBloc>();
  Get.find<FrdRepository>().tempFrd = bloc.state.frd;
  int beginRow = 11;
  Frd frdTemp = Get.find<FrdRepository>().tempFrd;

  final workbook = frdTableKey.currentState!
      .exportToExcelWorkbook(exportStackedHeaders: false);
  final sheet = workbook.worksheets[0];
  sheet.deleteRow(1);

  /// устанавливаем титульные строки с данными фрд
  sheet.insertRow(1, 12);
  sheet.getRangeByName('A1:F10').cellStyle.bold = true;
  setMergeAndTextCells('A1:F1', 'Фотография рабочего дня (ФРД)', sheet);
  sheet.getRangeByName('A1').cellStyle.fontSize = 13;

  for (int i = 2; i <= FrdStatus.values.length + 1; i++) {
    FrdStatus status = FrdStatus.values[i - 2];
    setMergeAndTextCells(
        'A$i:F$i', '${status.title}  ${status.value(frdTemp)}', sheet);
  }

  /// добавляем нумерную строку
  sheet.insertRow(beginRow + 1, 2);
  for (int i = 1; i <= ColumnsDataFrd.values.length; i++) {
    ColumnsDataFrd status = ColumnsDataFrd.values[i - 1];
    setTextCellsInt(beginRow, i, status.label, sheet);
    setTextCellsInt(beginRow + 1, i, i.toString(), sheet);
  }

  Duration totalDuration = Get.find<FrdRepository>()
      .tempFrd
      .operations
      .map((operation) => operation.durationOperation)
      .reduce((value, element) => value + element);

  /// ставим время в миллисекундах, заполняем столбцы временем и продолжительностью
  for (int i = 0; i <= frdTemp.operations.length - 1; i++) {
    OperationFrd oper = frdTemp.operations[i];
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
  int id = Get.find<FrdRepository>().hystoryFrd.isEmpty
      ? 1
      : Get.find<FrdRepository>().hystoryFrd.last.id + 1;
  FrdHystory hystoryFrd = FrdHystory.initial();

  hystoryFrd.begin =
      Get.find<FrdRepository>().tempFrd.operations.first.beginDate;
  Duration durationOperation =
      Get.find<FrdRepository>().tempFrd.operations.last.durationOperation;
  hystoryFrd.end = Get.find<FrdRepository>()
      .tempFrd
      .operations
      .last
      .beginDate
      .add(durationOperation);
  hystoryFrd.id = id;
  hystoryFrd.post = bloc.state.frd.post;
  hystoryFrd.phone = bloc.state.frd.phone;

  List<int> bytes = workbook.saveAsStream();
  var excel = Excel.decodeBytes(bytes);
  Sheet sheetObject = excel['Sheet1'];

  /// устанавливаем ширину столбцов, а также посередке
  for (int i = 0; i <= ColumnsDataFrd.values.length - 1; i++) {
    ColumnsDataFrd status = ColumnsDataFrd.values[i];
    sheetObject.setColumnWidth(i, status.widthExcel);
    setCenterCell(beginRow - 1, i, sheetObject);
    setCenterCell(beginRow, i, sheetObject);
  }

  /// устанавливаем выравнивание посередине для столбцов № и время
  for (int i = 0;
      i <= Get.find<FrdRepository>().tempFrd.operations.length;
      i++) {
    int indexRow = beginRow + 3;

    setCenterCell(indexRow + i, 0, sheetObject);
    setCenterCell(indexRow + i, 1, sheetObject);
    setCenterCell(indexRow + i, 2, sheetObject);
    setCenterCell(indexRow + i, 3, sheetObject);
  }

  /// устанавливаем посередке выравнивание для первой надписи и второй под ней
  setCenterCell(0, 0, sheetObject);
  setBoldCell(0, 0, sheetObject);
  setCenterCell(beginRow + 1, 0, sheetObject);
  setBoldCell(beginRow + 1, 0, sheetObject);
  bytes = excel.encode()!;
  Random random = Random();
  String randomNumber = random.nextInt(10000).toString();
  hystoryFrd.name =
      '${frdTemp.division}_ФРД_${frdTemp.post}_${Utils.getFormatDate(frdTemp.date)}_${hystoryFrd.id}_$randomNumber';
  List<String> nameParts =
      frdTemp.fio.split(' '); // Разделение полного имени на отдельные части
  String fioShort = ''; // Добавление фамилии с пробелом
  for (String part in nameParts) {
    if (part.isNotEmpty) {
      fioShort += part[0].toUpperCase(); // Добавление первой буквы каждой части
    } else {
      fioShort += '_';
    }
  }
  String userId = Get.find<UserRepository>().user.id;
  hystoryFrd.pathName =
      'ФРД_${fioShort}_${Utils.getFormatDate(frdTemp.date)}_${hystoryFrd.id}_$userId.xlsx';
  if (Get.find<UserRepository>().user.isPermissonFile) {
    Directory? directory = await getDownloadsDirectory();
    String appDocPath = '${directory!.path}/${hystoryFrd.pathName}';
    final File file = File(appDocPath);
    await file.writeAsBytes(bytes);
  }
  hystoryFrd.year = Utils.getDateYear(frdTemp.date);
  hystoryFrd.month = Utils.getDateMonth(frdTemp.date);
  hystoryFrd.org = frdTemp.org;
  hystoryFrd.div = frdTemp.division;
  Get.find<FrdRepository>().hystoryFrd.add(hystoryFrd);
  Get.find<FrdRepository>().saveFrdHystory();

  bloc.add(SaveHistoryEvent());
  try {
    await Get.find<FrdRepository>().uploadDocument();
    await Get.find<FrdRepository>()
        .uploadFileExcel(bytes: bytes, fileName: hystoryFrd.pathName);
  } catch (e) {
    showErrorDialog('ошибка при выгрузке файла на сервер $e');
  }
  Get.find<FrdRepository>().tempFrd = Frd.initial();
  Get.find<FrdRepository>().saveTempFrdToLocal();
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
  // range.autoFit();
}

setMergeAndFormulaCells(String rangeRow, String text, Worksheet sheet) {
  Range range = sheet.getRangeByName(rangeRow);
  range.setFormula(text);
}

setTextCellsInt(int row, int col, String text, Worksheet sheet) {
  Range range = sheet.getRangeByIndex(row, col);
  // range.merge();
  range.setText(text);
  range.cellStyle.hAlign = HAlignType.center;
  // range.autoFit();
}
