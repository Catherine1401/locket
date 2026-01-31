import 'package:flutter/material.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

base class MyTextStyle {
  static final myTextStyle = ShadTextTheme(
    family: "Inter", 
    custom: {
      'logo': TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800, 
        color: MyColors.logoText
      ),
      'slogan': TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800, 
        color: MyColors.slogan
      ),
      'messageLogin': TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800, 
        color: MyColors.messageLogin
      ),
      'name': TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        color: MyColors.name,
      ),
      'nameAppbar': TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: MyColors.nameAppbar,
      ),
      'titleBagdgeProfile': TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: MyColors.iconProfile,
      ),
      'textItemProfile': TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: MyColors.textItemProfile,
      ),
      'titleEditName': TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: MyColors.titleEditName,
      ),
      'contentEditName': TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: MyColors.titleEditName,
      ),
      'textButtonSubmit': TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: MyColors.textButtonSubmit,
      ),
   },
  );
}
