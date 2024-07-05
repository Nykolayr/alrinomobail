import 'package:alrino/common/utils.dart';
import 'package:alrino/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/theme/text.dart';
import 'package:alrino/presentation/widgets/buttons.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:alrino/presentation/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late AuthBloc bloc;
  @override
  void initState() {
    bloc = context.read<AuthBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        bloc: bloc,
        buildWhen: (previous, current) {
          if (current.isSucsess && !current.isLoading) {
            context.go('/main');
          }
          return true;
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColor.white,
            body: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                const FonPicture(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Gap(80),
                        SvgPicture.asset('assets/svg/logo_wide.svg',
                            width: 300),
                        const Gap(80),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Авторизация',
                            style: AppText.mainTitle28,
                          ),
                        ),
                        const Gap(34),
                        AlrinoFormField(
                          isError: true,
                          controller: loginController,
                          hint: 'Логин',
                          onChanged: (value) => () {},
                          validator: (value) => Utils.validateEmail(
                              value, 'Введите правильный логин'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const Gap(15),
                        AlrinoFormField(
                          isError: true,
                          controller: passwordController,
                          keyboardType: TextInputType.text,
                          hint: 'Пароль',
                          validator: (value) =>
                              Utils.validateNotEmpty(value, 'Укажите пароль'),
                        ),
                        const Gap(25),
                        if (state.error.isNotEmpty)
                          SizedBox(
                            height: 20,
                            child: Text(
                              state.error,
                              style: AppText.textField12
                                  .copyWith(color: AppColor.redPro),
                            ),
                          )
                        else
                          const Gap(20),
                        const Gap(25),
                        Buttons.button180(
                          text: 'Войти',
                          onPressed: () async {
                            await Get.find<FlutterNetworkConnectivity>()
                                .isInternetConnectionAvailable();
                            if (formKey.currentState!.validate()) {
                              bloc.add(AuthUserEvent(
                                login: loginController.text,
                                pass: passwordController.text,
                              ));
                            }
                          },
                        ),
                        const Gap(25),
                      ],
                    ),
                  ),
                ),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator.adaptive())
              ],
            ),
          );
        });
  }
}

class RectCustomClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) =>
      oldClipper != this;
}
