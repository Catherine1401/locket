import 'package:flutter/material.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/core/theme/text_style.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final class MyTheme {
  static final shadThemeData = ShadThemeData(
    textTheme: MyTextStyle.myTextStyle,
    primaryButtonTheme: ShadButtonTheme(
      expands: true,
      height: 48,
      backgroundColor: MyColors.bgButtonLogin,
      decoration: ShadDecoration(
        border: ShadBorder.all(radius: BorderRadius.circular(24)),
        secondaryBorder: ShadBorder.none,
      ),
    ),
  );
}

