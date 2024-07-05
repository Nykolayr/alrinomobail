import 'package:alrino/domain/models/photo_day.dart';
import 'package:alrino/domain/routers/routers.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/autocomplit_field.dart';
import 'package:alrino/presentation/widgets/buttons.dart';
import 'package:alrino/presentation/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// общий класс для алертов приложения
class AlertSelf extends StatelessWidget {
  final String text;
  final String subText;
  const AlertSelf({required this.text, required this.subText, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 20),
      title: Center(
        child: Text(text, style: AppText.title18),
      ),
      content: Text(subText, style: AppText.table12),
      actions: <Widget>[
        Buttons.alert(
          text: 'Отмена',
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        Buttons.alert(
          text: 'Подтвердить',
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}

/// Для показа кастомного содержимого
Future<void> showModalContent(BuildContext context, String text, Widget child,
    Function() cansel, Function() save,
    {String butText = 'Сохранить'}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        alignment: Alignment.center,
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 20),
        title: Text(text, textAlign: TextAlign.center, style: AppText.title18),
        content: child,
        actions: <Widget>[
          Buttons.alert(
            text: 'Отмена',
            onPressed: cansel,
          ),
          Buttons.alert(
            text: butText,
            onPressed: save,
          ),
        ],
      );
    },
  );
}

/// Для показа окончания времени работы
Future<bool?> showEndTime(
  BuildContext context,
  Duration time,
) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      double width = MediaQuery.of(context).size.width - 100;
      return AlertDialog(
        alignment: Alignment.center,
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 20),
        title: SizedBox(
          width: width,
          child: Column(
            children: [
              Text(
                  'Время Вашей работы ${time.inHours} часов, ${time.inMinutes} минут',
                  textAlign: TextAlign.center,
                  style: AppText.title18),
              const Gap(15),
              ButtonSelf(
                text: 'Завершить рабочий день через 15 минут',
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                width: width / 2,
                height: 50,
                isSmall: true,
              ),
              const Gap(15),
              ButtonSelf(
                text: 'Продлить рабочий день на 1 час',
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                width: width / 2,
                height: 50,
                isSmall: true,
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Алерт для выхода из профиля
Future<bool?> showExitProfileAlert(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const AlertSelf(
          text: 'Внимание!',
          subText: 'Вы уверены, что хотите выйти из профиля?');
    },
  );
}

/// Алерт для выхода из таблицы
Future<bool?> showExitEditTableAlert(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const AlertSelf(
          text: 'Внимание!',
          subText: 'Вы хотите закончить заполнение таблицы?');
    },
  );
}

/// Алерт для выхода из таблицы если не заполенено ничего
Future<bool?> showExitTableAlert(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const AlertSelf(
          text: 'Внимание!', subText: 'Вы хотите выйти из таблицы?');
    },
  );
}

/// Алерт для продолжения заполнения таблицы, если она не была закончена
Future<bool?> showNotFiilTableAlert(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const AlertSelf(
          text: 'Внимание!',
          subText:
              'У Вас есть незаполненная таблица, хотите продолжить её заполнение?');
    },
  );
}

/// Алерт для остановки времени
Future<bool?> showEndTimerTableAlert(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const AlertSelf(
          text: 'Внимание!', subText: 'Вы хотите закончить хронометраж?');
    },
  );
}

/// Для показа широкой модалки, где кнопки в один ряд с child
Future<void> showModalWideContent(BuildContext context, String text,
    Widget child, Function()? cansel, Function() save) async {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        double width = MediaQuery.of(context).size.width;
        return AlertDialog(
          alignment: Alignment.center,
          titlePadding: EdgeInsets.all((cansel == null) ? 10 : 0),
          actionsAlignment: MainAxisAlignment.center,
          title: (text != '')
              ? Text(text, textAlign: TextAlign.center, style: AppText.title18)
              : const SizedBox.shrink(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: cansel == null ? width * 0.7 : width * 0.4,
                  height: 52,
                  child: child,
                ),
                const Gap(6),
                cansel == null
                    ? const SizedBox.shrink()
                    : Buttons.alert(
                        text: 'Отмена',
                        onPressed: cansel,
                      ),
                const Gap(6),
                Buttons.alert(
                  text: 'Сохранить',
                  onPressed: save,
                ),
              ]),
        );
      });
}

/// Для редактирования ячейки в таблице
Future<void> showModalWideContentCell(Widget child, Function() save) async {
  BuildContext context = router.configuration.navigatorKey.currentContext!;

  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        double width = MediaQuery.of(context).size.width;
        return Dialog(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: width * 0.6,
                    height: 48,
                    child: child,
                  ),
                  const Gap(6),
                  const Gap(6),
                  Buttons.alert(
                    text: 'Сохранить',
                    onPressed: save,
                  ),
                ]),
          ),
        );
      });
}

/// Алерт для редактирования ячейки
Future<String> editCellAlertOperation(
    TextEditingController controller, List<String> suggestions) async {
  await showModalWideContentCell(
      AutoComplitFormField(
        autoFocus: true,
        suggestions: suggestions,
        controller: controller,
        hint: 'Значение ячейки',
        keyboardType: TextInputType.name,
      ),
      () => router.pop());
  return controller.text;
}

/// Алерт для редактирования ячейки
Future<String> editCellAlert(TextEditingController controller) async {
  await showModalWideContentCell(
      AlrinoFormField(
        autoFocus: true,
        controller: controller,
        hint: 'Значение ячейки',
        keyboardType: TextInputType.name,
      ),
      () => router.pop());
  return controller.text;
}

/// Алерт для ошибок api
void showErrorDialog(String errorMessage) async {
  if (router.configuration.navigatorKey.currentContext != null) {
    await showDialog(
      context: router.configuration.navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка при работе с сервером',
              style: AppText.text14.copyWith(color: AppColor.redPro)),
          content: Text(errorMessage, style: AppText.textField12),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

/// Алерт для сообщения
Future showInfo(context, String title, {required Widget content}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text(title, style: AppText.text14),
        ),
        content: content,
      );
    },
  );
}

/// Алерт для информации о исполнителе
Future showInfoForExecutor(
  context,
  PhotoDay item,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
          child: Text('Данные об исполнителе', style: AppText.title18),
        ),
        content: SizedBox(
          height: 160,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Gap(10),
            const Text(
              'ФИО исполнителя:',
              style: AppText.text14,
            ),
            Text(
              item.fio,
              style: AppText.title14,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(10),
            const Text(
              'Должность исполнителя:',
              style: AppText.text14,
            ),
            Text(
              item.post,
              style: AppText.title14,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Телефон исполнителя:',
                      style: AppText.text14,
                    ),
                    Text(
                      item.phone,
                      style: AppText.title14,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy),
                  onPressed: () {
                    // Действия при нажатии на кнопку копирования
                    Clipboard.setData(ClipboardData(text: item.phone));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Телефон скопирован'),
                    ));
                  },
                ),
              ],
            )
          ]),
        ),
      );
    },
  );
}
