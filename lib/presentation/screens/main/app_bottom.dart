import 'package:alrino/presentation/screens/main/pages.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/theme/different.dart';
import 'package:alrino/presentation/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// табы в виде виджета для переходов между страницами на главной

class AppBottom extends StatelessWidget {
  final TabController tabController;
  final PageController pageController;
  const AppBottom(
      {required this.tabController, required this.pageController, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 75,
      color: AppColor.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            indicatorColor: Colors.transparent,
            controller: tabController,
            tabs: [
              for (int i = 0; i < MainPageType.values.length; i++)
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: 120,
                    height: 63,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: AppDif.borderRadius10,
                      color: i == tabController.index
                          ? AppColor.lightblue
                          : AppColor.white,
                    ),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/svg/${MainPageType.values[i].name}.svg',
                          height: 19,
                        ),
                        Text(MainPageType.values[i].pageName,
                            style: AppText.textField12
                                .copyWith(color: AppColor.blue)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
