import 'dart:io';
import 'dart:math';

import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/fhn/fhn.dart';
import 'package:alrino/domain/models/fhn/fhn_history.dart';
import 'package:alrino/domain/models/fhn/operations_fhn.dart';
import 'package:alrino/domain/models/photo_day.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/screens/fhn/bloc/fhn_bloc.dart';
import 'package:alrino/presentation/screens/fhn/fhn_table.dart';
import 'package:alrino/presentation/screens/fhn/table/columns_fhn.dart';
import 'package:alrino/presentation/widgets/alerts.dart';

import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

Future<void> exportDataGridToExcelFhn() async {
  FhnBloc bloc = Get.find<FhnBloc>();
  Get.find<FhnRepository>().tempFhn = bloc.state.fhn;
  int beginRow = 11;

  Fhn fhnTemp = Get.find<FhnRepository>().tempFhn;

  final workbook = fhnTableKey.currentState!
      .exportToExcelWorkbook(exportStackedHeaders: false);

  final sheet = workbook.worksheets[0];
  sheet.deleteRow(1);

  /// устанавливаем титульные строки с данными ФХН
  sheet.insertRow(1, 12);
  sheet.getRangeByName('A1:F10').cellStyle.bold = true;
  setMergeAndTextCells('A1:F1', 'Фотохронометражные наблюдения (ФХН)', sheet);
  sheet.getRangeByName('A1').cellStyle.fontSize = 13;
  for (int i = 2; i <= FrdStatus.values.length + 1; i++) {
    FrdStatus status = FrdStatus.values[i - 2];
    setMergeAndTextCells(
        'A$i:F$i', '${status.title}  ${status.value(fhnTemp)}', sheet);
  }

  /// добавляем нумерную строку
  sheet.insertRow(beginRow + 1, 2);
  for (int i = 1; i <= ColumnsDataFhn.values.length; i++) {
    ColumnsDataFhn status = ColumnsDataFhn.values[i - 1];
    setTextCellsInt(beginRow, i, status.label, sheet);
    setTextCellsInt(beginRow + 1, i, i.toString(), sheet);
  }

  Duration totalDuration = Get.find<FhnRepository>()
      .tempFhn
      .operations
      .map((operation) => operation.durationOperation)
      .reduce((value, element) => value + element);

  /// ставим время в миллисекундах, заполняем столбцы временем и продолжительностью
  for (int i = 0; i <= fhnTemp.operations.length - 1; i++) {
    OperationFhn oper = fhnTemp.operations[i];
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
  int id = Get.find<FhnRepository>().hystoryFhn.isEmpty
      ? 1
      : Get.find<FhnRepository>().hystoryFhn.last.id + 1;
  FhnHystory hystoryFhn = FhnHystory.initial();
  hystoryFhn.begin =
      Get.find<FhnRepository>().tempFhn.operations.first.beginDate;
  Duration durationOperation =
      Get.find<FhnRepository>().tempFhn.operations.last.durationOperation;
  hystoryFhn.end = Get.find<FhnRepository>()
      .tempFhn
      .operations
      .last
      .beginDate
      .add(durationOperation);
  hystoryFhn.id = id;
  hystoryFhn.post = bloc.state.fhn.post;
  hystoryFhn.phone = bloc.state.fhn.phone;
  List<String> nameParts =
      fhnTemp.fio.split(' '); // Разделение полного имени на отдельные части
  String fioShort = ''; // Добавление фамилии с пробелом
  for (String part in nameParts) {
    fioShort += part[0].toUpperCase(); // Добавление первой буквы каждой части
  }

  String userId = Get.find<UserRepository>().user.id;
  Random random = Random();
  String randomNumber = random.nextInt(10000).toString();
  hystoryFhn.name =
      '${fhnTemp.division}_ФХН_${fhnTemp.post}_${Utils.getFormatDate(fhnTemp.date)}_${hystoryFhn.id}_$randomNumber';

  hystoryFhn.pathName =
      'ФХН_${fioShort}_${Utils.getFormatDate(fhnTemp.date)}_${hystoryFhn.id}_$userId.xlsx';
  Directory? directory = await getDownloadsDirectory();
  String appDocPath = '${directory!.path}/${hystoryFhn.pathName}';
  final File file = File(appDocPath);
  List<int> bytes = workbook.saveAsStream();
  var excel = Excel.decodeBytes(bytes);
  Sheet sheetObject = excel['Sheet1'];

  /// устанавливаем ширину столбцов, а также посередке
  for (int i = 0; i <= ColumnsDataFhn.values.length - 1; i++) {
    ColumnsDataFhn status = ColumnsDataFhn.values[i];
    sheetObject.setColumnWidth(i, status.widthExcel);
    setCenterCell(beginRow - 1, i, sheetObject);
    setCenterCell(beginRow, i, sheetObject);
  }

  /// устанавливаем выравнивание посередине для столбцов № и время
  for (int i = 0;
      i <= Get.find<FhnRepository>().tempFhn.operations.length - 1;
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
  if (Get.find<UserRepository>().user.isPermissonFile) {
    await file.writeAsBytes(bytes);
  }
  hystoryFhn.year = Utils.getDateYear(fhnTemp.date);
  hystoryFhn.month = Utils.getDateMonth(fhnTemp.date);
  hystoryFhn.org = fhnTemp.org;
  hystoryFhn.div = fhnTemp.division;
  Get.find<FhnRepository>().hystoryFhn.add(hystoryFhn);
  Get.find<FhnRepository>().savefhnHystory();
  bloc.add(SaveHistoryEvent());
  try {
    await Get.find<FhnRepository>().uploadDocument();
    await Get.find<FhnRepository>()
        .uploadFileExcel(bytes: bytes, fileName: hystoryFhn.pathName);
  } catch (e) {
    showErrorDialog('ошибка при выгрузке файла на сервер $e');
  }
  Get.find<FhnRepository>().tempFhn = Fhn.initial();
  Get.find<FhnRepository>().savefhnToLocal();
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

setTextCellsInt(int row, int col, String text, Worksheet sheet) {
  Range range = sheet.getRangeByIndex(row, col);
  // range.merge();
  range.setText(text);
  range.cellStyle.hAlign = HAlignType.center;
  // range.autoFit();
}

setMergeAndFormulaCells(String rangeRow, String text, Worksheet sheet) {
  Range range = sheet.getRangeByName(rangeRow);
  range.merge();
  range.setFormula(text);
}
