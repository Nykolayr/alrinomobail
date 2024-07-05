import 'package:alrino/domain/models/fhn/fhn.dart';
import 'package:alrino/domain/models/fhn/operations_fhn.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class RequisiteItem extends StatelessWidget {
  final Requisite requisite;

  const RequisiteItem({
    super.key,
    required this.requisite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 3, top: 10),
          child: Text(
            requisite.name,
            style: AppText.text14,
          ),
        ),
        const Gap(4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          width: MediaQuery.of(context).size.width,
          decoration: AppDif.decotationBlueRadius,
          child: Text(requisite.value),
        ),
      ],
    );
  }
}

class AddColumnsItem extends StatelessWidget {
  final AddColumns requisite;

  const AddColumnsItem({
    super.key,
    required this.requisite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 3, top: 10),
          child: Text(
            requisite.name,
            style: AppText.text14,
          ),
        ),
        const Gap(4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          width: MediaQuery.of(context).size.width,
          decoration: AppDif.decotationBlueRadius,
          child: Text(requisite.value),
        ),
      ],
    );
  }
}

/// кнопки для редактирования и удаления
Widget getIconButton(String path,
    {Function()? onTap, bool isRed = false, bool isBlock = false}) {
  return GestureDetector(
    onTap: isBlock ? null : onTap,
    child: Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(7),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            path,
            width: 25,
            height: 25,
            colorFilter: ColorFilter.mode(
                isRed ? AppColor.redPro : AppColor.black, BlendMode.srcIn),
          ),
          if (isBlock)
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child: CustomPaint(
                painter: DiagonalLinePainter(mySize: 18),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Алерт для удаления шаблона
Future<bool?> deletePatternAlert(
    String name, String data, BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertSelf(
          text: 'Внимание!',
          subText: 'Вы уверены, что хотите удалить $data "$name"?');
    },
  );
}

/// Рисует диагональную линию
class DiagonalLinePainter extends CustomPainter {
  final double mySize;
  DiagonalLinePainter({required this.mySize});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red // Задайте нужный цвет
      ..strokeWidth = 2; // Задайте нужную толщину линии

    // Рисуем диагональную линию
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
