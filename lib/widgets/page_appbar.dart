import 'package:flutter/material.dart';
import 'package:food_website/theme/app_colors.dart';

PreferredSizeWidget buildPageAppBar({
  required BuildContext context,
  String? title,
  Widget? titleWidget, 
  required VoidCallback onBack,
  bool showBack = true,
  List<Widget>? actions,
}) {
  return AppBar(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    automaticallyImplyLeading: false,
    titleSpacing: 0,

    leading: showBack
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: onBack,
          )
        : const SizedBox(width: 48),

    // ✅ if titleWidget provided use it, else normal text title
    title: titleWidget ??
        Text(
          title ?? "",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),

    actions: actions,
  );
}