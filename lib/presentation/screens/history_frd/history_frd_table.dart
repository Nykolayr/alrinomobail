import 'dart:io';
import 'package:alrino/common/constants.dart';
import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/frd/ftd_history_table.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/app_bar.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table/table_sticky_headers.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:url_launcher/url_launcher.dart';

class HystoryFrdTable extends StatefulWidget {
  final List<FrdHystory> hystories;
  const HystoryFrdTable({required this.hystories, Key? key}) : super(key: key);

  @override
  State<HystoryFrdTable> createState() => _HystoryFrdTableState();
}

class _HystoryFrdTableState extends State<HystoryFrdTable> {
  List<FrdHystory> hystories = [];
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
        appBar: const AppBars(title: 'Таблица истории ФРД'),
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
  FrdHystory frd,
  ColumnsData data,
  int i,
) {
  return data == ColumnsData.path
      ? GestureDetector(
          onTap: () => onTapPath(
            frd.pathName,
          ),
          child: getCell(data.getText(frd), i.isEven, isPath: true),
        )
      : getCell(data.getText(frd), i.isEven);
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

/// просмотр файла екселя на сервере
Future getFileFromServer(String onTapPath) async {
  final Uri url = Uri.parse('$serverPath/files/open/$onTapPath');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
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

  getText(FrdHystory frd) => switch (this) {
        ColumnsData.id => frd.id.toString(),
        ColumnsData.date => Utils.getFormatDate(frd.begin),
        ColumnsData.name => frd.name,
        ColumnsData.path => frd.pathName
      };
  String get header => switch (this) {
        ColumnsData.id => '№\nп/п',
        ColumnsData.date => 'Дата',
        ColumnsData.name => 'Наименование файла',
        ColumnsData.path => 'Ссылка на файл'
      };
}
