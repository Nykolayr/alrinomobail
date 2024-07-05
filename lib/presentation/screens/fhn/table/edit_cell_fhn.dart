import 'dart:async';

import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/presentation/screens/fhn/bloc/fhn_bloc.dart';
import 'package:alrino/presentation/screens/fhn/table/columns_fhn.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class EditCellFhn extends StatefulWidget {
  final int indexRow;
  final bool isAhead;
  final ColumnsDataFhn columnsData;
  final String text;

  const EditCellFhn(
      {required this.columnsData,
      this.isAhead = false,
      required this.indexRow,
      required this.text,
      super.key});

  @override
  State<EditCellFhn> createState() => _EditCellFhnState();
}

class _EditCellFhnState extends State<EditCellFhn> {
  FocusNode focusNodeEdit = FocusNode();
  FhnBloc bloc = Get.find<FhnBloc>();
  int numLines = 0;
  int length = 0;
  TextEditingController editingController = TextEditingController();
  TextInputType keyboardType = TextInputType.text;

  /// при нажатие на ячейку, начать редактирование
  void startEditing() async {
    if (widget.columnsData == ColumnsDataFhn.name) {
      if (editingController.text.isNotEmpty) {
        if (!Get.find<FhnRepository>()
            .operationsFhn
            .contains(editingController.text)) {
          Get.find<FhnRepository>()
              .valuesFhn
              .removeWhere((element) => element == editingController.text);
        }
      }
      await editCellAlertOperation(
          editingController, Get.find<FhnRepository>().valuesFhn);
    } else {
      await editCellAlert(editingController);
    }

    endEditing();
  }

  /// закончили редактирование,  передаем новое значение
  void endEditing() {
    if (editingController.text.isNotEmpty) {
      String text = editingController.text;
      if (!(Get.find<FhnRepository>()
          .operationsFhn
          .contains(editingController.text))) {
        editingController.text = Utils.capitalizeText(text);
      }
      if (!(Get.find<FhnRepository>()
              .operationsFhn
              .contains(editingController.text)) &&
          widget.columnsData == ColumnsDataFhn.name) {
        Get.find<FhnRepository>().valuesFhn.add(editingController.text);
      }
      Get.find<FhnRepository>().valuesFhn =
          Get.find<FhnRepository>().valuesFhn.toSet().toList();
    }

    bloc.add(EndEditCellEvent(
      dataCell: DataEditCellFhn(
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
    editingController.text = widget.text;
    length = bloc.state.fhn.operations.length - 1;
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
    return BlocBuilder<FhnBloc, FhnState>(
        bloc: bloc,
        builder: (context, state) {
          return LayoutBuilder(builder: (context, constraints) {
            final span = TypeAheadField<String>(
              focusNode: focusNodeEdit,
              autoFlipDirection: true,
              controller: editingController,
              hideOnEmpty: !widget.isAhead,
              suggestionsCallback: (search) => widget.isAhead
                  ? Get.find<FhnRepository>()
                      .valuesFhn
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
                  key: Key(widget.indexRow.toString()),
                  autofocus: true,
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
