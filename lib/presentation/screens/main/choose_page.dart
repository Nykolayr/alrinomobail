import 'package:alrino/domain/models/fhn/fhn.dart';
import 'package:alrino/domain/models/frd/frd.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/presentation/screens/main/bloc/main_bloc.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/buttons.dart';
import 'package:alrino/presentation/widgets/switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Страница выбора дальнейших действий
class ChoosePage extends StatelessWidget {
  const ChoosePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    MainBloc bloc = Get.find<MainBloc>();
    Widget getButton(String text, {bool isBlue = true}) {
      return Buttons.selfChooseBlue(
        text: text,
        onPressed: () {
          if (text == 'СЗ') {
            Get.find<FrdRepository>().newSz();
          } 
          Get.find<FrdRepository>().tempFrd = Frd.initial();
          Get.find<FrdRepository>().saveTempFrdToLocal();
          Get.find<FhnRepository>().tempFhn = Fhn.initial();
          Get.find<FhnRepository>().savefhnToLocal();

          context.goNamed(text);
        },
        isBlue: isBlue,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Gap(50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getButton('ФРД'),
            const Spacer(),
            getButton('ФХН'),
          ],
        ),
        const Gap(30),
        getButton('СЗ'),
        const Gap(60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getButton('История ФРД', isBlue: false),
            const Spacer(),
            getButton('История ФХН', isBlue: false),
          ],
        ),
        const Gap(70),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Справочник процессов',
                style: AppText.title18, overflow: TextOverflow.ellipsis),
            const Gap(10),
            BlocBuilder<MainBloc, MainState>(
              bloc: bloc,
              builder: (context, state) {
                return SwitchAlrino(
                  value: state.isProcess,
                  onChanged: (value) => bloc.add(SetIsProcessEvent()),
                  width: 55,
                );
              },
            ),
          ],
        ),
        const Gap(30),
      ],
    );
  }
}
