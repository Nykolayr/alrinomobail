import 'package:alrino/domain/injects.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/theme/text.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  String error = '';
  bool isLoad = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    error = await initMain();
    if (mounted) {
      isLoad = false;
      setState(() {});
      if (error.isEmpty) {
        if (Get.find<UserRepository>().user.token.isNotEmpty) {
          context.goNamed('Общая');
        } else {
          context.goNamed('авторизация');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            const FonPicture(),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(80),
                SvgPicture.asset('assets/svg/logo_wide.svg', width: 300),
                const Gap(180),
                Text(
                  error.isEmpty
                      ? 'Загружается...'
                      : 'Ошибка при загрузке данныx:  \n\n $error \n \n перешлите скрин экрана \n в службу поддержки',
                  textAlign: TextAlign.center,
                  style: AppText.text14.copyWith(color: AppColor.redPro),
                ),
              ],
            ),
            if (isLoad) const Center(child: CircularProgressIndicator())
          ],
        ),
      ),
    );
  }
}

Widget getMaterial(String error) {
  return Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: AppColor.white,
    body: Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        const FonPicture(),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Gap(80),
            SvgPicture.asset('assets/svg/logo_wide.svg', width: 300),
            const Gap(80),
          ],
        ),
        Center(
            child: error.contains('Загружается')
                ? const CircularProgressIndicator()
                : Text(
                    error,
                    style: AppText.text14.copyWith(color: AppColor.redPro),
                  )),
      ],
    ),
  );
}
