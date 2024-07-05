import 'dart:async';

import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/presentation/screens/sz/bloc/sz_bloc.dart';
import 'package:alrino/presentation/screens/sz/table/columns_sz.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class EditCellSz extends StatefulWidget {
  final int indexRow;
  final bool isAhead;
  final ColumnsDataSz columnsData;
  final String text;

  const EditCellSz(
      {required this.indexRow,
      required this.columnsData,
      required this.isAhead,
      required this.text,
      super.key});

  @override
  State<EditCellSz> createState() => _EditCellSzState();
}

class _EditCellSzState extends State<EditCellSz> {
  bool isFirstName = false;
  FocusNode focusNodeEdit = FocusNode();
  SzBloc bloc = Get.find<SzBloc>();
  List<String> orgNames = [
    'Обед',
    'Регламентированный перерыв',
    ...Get.find<MainRepository>().orgNames
  ];
  int numLines = 0;
  int length = 0;
  TextEditingController editingController = TextEditingController();
  var keyboardType = TextInputType.text;

  /// при нажатие на ячейку, начать редактирование
  void startEditing() async {
    if (bloc.state.editColumn == ColumnsDataSz.org) {
      if (focusNodeEdit.hasFocus) {
        await editCellAlert(editingController);
        await Future.delayed(const Duration(milliseconds: 300));
        focusNodeEdit.requestFocus();
      }
    } else {
      await editCellAlert(editingController);
      endEditing();
    }
  }

  /// закончили редактирование,  передаем новое значение
  void endEditing() {
    if (editingController.text.isNotEmpty) {
      String text = editingController.text;
      editingController.text = Utils.capitalizeText(text);
    }
    bloc.add(EndEditCellEvent(
      dataCell: DataEditCellSz(
        text: editingController.text,
        linesEdit: numLines,
        indexRow: widget.indexRow,
        columnsData: widget.columnsData,
      ),
      columnsData: widget.columnsData,
    ));
  }

  @override
  initState() {
    isFirstName = (ColumnsDataSz.org == widget.columnsData);
    editingController.text = widget.text;
    length = bloc.state.sz.operations.length - 1;
    keyboardType = TextInputType.none;
    bloc.add(AddFocusInStatevent(
        focus: focusNodeEdit, controller: editingController));
    Future.delayed(const Duration(milliseconds: 150), () {
      bloc.state.focus.requestFocus();
    });

    super.initState();
  }

  @override
  dispose() {
    endEditing();
    editingController.dispose();
    focusNodeEdit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SzBloc, SzState>(
        bloc: bloc,
        builder: (context, state) {
          return LayoutBuilder(builder: (context, constraints) {
            final span = TypeAheadField<String>(
              focusNode: focusNodeEdit,
              autoFlipDirection: true,
              controller: editingController,
              hideOnEmpty: !widget.isAhead,
              suggestionsCallback: (search) => widget.isAhead
                  ? orgNames
                      .where((item) =>
                          item.toLowerCase().contains(search.toLowerCase()))
                      .toList()
                  : [],
              emptyBuilder: (context) => const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Совпадений не найдено'),
              ),
              builder: (context, controller, focusNode) {
                return TextField(
                  readOnly: isFirstName,
                  autofocus: true,
                  key: Key(widget.indexRow.toString()),
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (value) => endEditing(),
                  onTap: () => startEditing(),
                  showCursor: true,
                  maxLines: 3,
                  keyboardType: keyboardType,
                  onChanged: (String value) {},
                  style: AppText.textField12.copyWith(color: AppColor.black),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    hintText: '',
                    border: InputBorder.none,
                  ),
                );
              },
              itemBuilder: (context, item) => ListTile(
                title: Text(item),
              ),
              onSelected: (item) {
                editingController.text = item;
                endEditing();
              },
            );
            final tp = TextPainter(
                text: TextSpan(text: editingController.text),
                textDirection: TextDirection.ltr);
            tp.layout(maxWidth: constraints.maxWidth);
            numLines = tp.computeLineMetrics().length;

            if (numLines > 3) numLines = 3;
            if (numLines == 0) numLines = 1;

            return span;
          });
        });
  }
}
