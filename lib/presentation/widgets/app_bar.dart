import 'package:flutter/material.dart';

import '../theme/theme.dart';

class AppBars extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppBars({Key? key, required this.title}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:
          Text(title, style: AppText.title18.copyWith(color: AppColor.black)),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: AppColor.black),
        onPressed: () => Navigator.pop(context, false),
      ),
    );
  }
}
