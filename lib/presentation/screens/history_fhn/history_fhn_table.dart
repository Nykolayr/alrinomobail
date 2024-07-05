import 'dart:io';
import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/fhn/fhn_history.dart';
import 'package:alrino/presentation/screens/history_frd/history_frd_table.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/app_bar.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_table/table_sticky_headers.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class HystoryFhnTable extends StatefulWidget {
  final List<FhnHystory> hystories;
  const HystoryFhnTable({required this.hystories, Key? key}) : super(key: key);

  @override
  State<HystoryFhnTable> createState() => _HystoryFhnTableState();
}

class _HystoryFhnTableState extends State<HystoryFhnTable> {
  List<FhnHystory> hystories = [];
  List<double> listWidth = [50, 100, 200, 250];

  setListWidth() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final double width = MediaQuery.of(context).size.width - 370;
      listWidth = [50, 90, width, 200];
    });
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {});
  }

  @override
  void initState() {
    hystories = widget.hystories;
    setListWidth();
    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const AppBars(title: 'Таблица истории ФХН'),
        body: Stack(
          children: [
            const FonPicture(isTable: true),
            SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 45,
                child: StickyHeadersTable(
                  cellDimensions: CellDimensions.variableColumnWidth(
                      columnWidths: listWidth,
                      contentCellHeight: 45,
                      stickyLegendWidth: 0,
                      stickyLegendHeight: 45),
                  columnsLength: ColumnsData.values.length,
                  rowsLength: hystories.length,
                  columnsTitleBuilder: (i) =>
                      getHeader(ColumnsData.values[i].header),
                  rowsTitleBuilder: (i) => const SizedBox.shrink(),
                  contentCellBuilder: (i, j) =>
                      getRowTable(hystories[j], ColumnsData.values[i], j),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget getRowTable(
  FhnHystory fhn,
  ColumnsData data,
  int i,
) {
  return data == ColumnsData.path
      ? GestureDetector(
          onTap: () => onTapPath(
            fhn.pathName,
          ),
          child: getCell(data.getText(fhn), i.isEven, isPath: true),
        )
      : getCell(data.getText(fhn), i.isEven);
}

///  заголовок
Widget getHeader(String text) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    // width: double.infinity,
    height: 45,
    decoration: BoxDecoration(
      color: AppColor.blueTable,
      border: AppDif.borderAll,
    ),
    child: Text(text),
  );
}

/// переход на просмотр таблицы ексел
onTapPath(String onTapPath) async {
  Directory? directory = await getDownloadsDirectory();
  if (directory != null) {
    String appDocPath = '${directory.path}/$onTapPath';
    try {
      final result = await OpenFile.open(appDocPath);
      if (result.type == ResultType.fileNotFound) {
        getFileFromServer(onTapPath);
      } else {
        Logger.e(' result ${result.type} ==== ${result.message}');
      }
    } catch (e) {
      Logger.e('error OpenFile == $e ');
      getFileFromServer(onTapPath);
    }
  }
}

///  отображение ячейки
Widget getCell(String text, isGrey, {isPath = false}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    // width: double.infinity,
    height: 45,
    decoration: BoxDecoration(
      color: isGrey ? AppColor.grey : AppColor.white,
      border: AppDif.borderAll,
    ),
    child: Text(
      text,
      style: AppText.textField12.copyWith(
        color: isPath ? AppColor.green : AppColor.black,
      ),
    ),
  );
}

///  столбцы для этой таблицы
enum ColumnsData {
  id,
  date,
  name,
  path;

  getText(FhnHystory fhn) => switch (this) {
        ColumnsData.id => fhn.id.toString(),
        ColumnsData.date => Utils.getFormatDate(fhn.begin),
        ColumnsData.name => fhn.name,
        ColumnsData.path => fhn.pathName
      };
  String get header => switch (this) {
        ColumnsData.id => '№\nп/п',
        ColumnsData.date => 'Дата',
        ColumnsData.name => 'Наименование файла',
        ColumnsData.path => 'Ссылка на файл'
      };
}
