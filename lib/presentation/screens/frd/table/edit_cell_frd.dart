import 'dart:async';

import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/presentation/screens/frd/bloc/frd_bloc.dart';
import 'package:alrino/presentation/screens/frd/table/enum_column_frd.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class EditCellFrd extends StatefulWidget {
  final int indexRow;
  final bool isAhead;
  final ColumnsDataFrd columnsData;
  final String text;

  const EditCellFrd(
      {required this.indexRow,
      required this.columnsData,
      required this.isAhead,
      required this.text,
      super.key});

  @override
  State<EditCellFrd> createState() => _EditCellFrdState();
}

class _EditCellFrdState extends State<EditCellFrd> {
  FocusNode focusNodeEdit = FocusNode();
  FrdBloc bloc = Get.find<FrdBloc>();
  int numLines = 0;
  int length = 0;
  TextEditingController editingController = TextEditingController();
  var keyboardType = TextInputType.text;

  /// при нажатие на ячейку, начать редактирование
  void startEditing() async {
    if (widget.columnsData == ColumnsDataFrd.name) {
      if (editingController.text.isNotEmpty) {
        editingController.text = editingController.text.trim();
        if (!Get.find<FrdRepository>()
            .operationsFrd
            .contains(editingController.text)) {
          Get.find<FrdRepository>()
              .valuesFrd
              .removeWhere((element) => element == editingController.text);
        }
      }
      await editCellAlertOperation(
          editingController, Get.find<FrdRepository>().valuesFrd);
    } else {
      await editCellAlert(editingController);
    }
    endEditing();
  }

  /// закончили редактирование,  передаем новое значение
  void endEditing() {
    if (editingController.text.isNotEmpty) {
      String text = editingController.text;
      if (!(Get.find<FrdRepository>()
          .operationsFrd
          .contains(editingController.text))) {
        editingController.text = Utils.capitalizeText(text);
      }
      if (!(Get.find<FrdRepository>()
              .operationsFrd
              .contains(editingController.text)) &&
          widget.columnsData == ColumnsDataFrd.name) {
        Get.find<FrdRepository>().valuesFrd.add(editingController.text);
      }
      Get.find<FrdRepository>().valuesFrd =
          Get.find<FrdRepository>().valuesFrd.toSet().toList();
    }

    bloc.add(EndEditCellEvent(
      dataCell: DataEditCellFrd(
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
    editingController.text = widget.text.trim();
    length = bloc.state.frd.operations.length - 1;
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
    return BlocBuilder<FrdBloc, FrdState>(
        bloc: bloc,
        builder: (context, state) {
          return LayoutBuilder(builder: (context, constraints) {
            final span = TypeAheadField<String>(
              focusNode: focusNodeEdit,
              autoFlipDirection: true,
              controller: editingController,
              hideOnEmpty: !widget.isAhead,
              suggestionsCallback: (search) => widget.isAhead
                  ? Get.find<FrdRepository>()
                      .valuesFrd
                      .where((item) =>
                          item.toLowerCase().contains(search.toLowerCase()))
                      .toSet()
                      .toList()
                  : [],
              emptyBuilder: (context) => const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Совпадений не найдено'),
              ),
              builder: (context, controller, focusNode) {
                return TextField(
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
                editingController.text = item.trim();
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
