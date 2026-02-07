import 'package:locket/core/theme/text_style.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final class MyTheme {
  static final shadThemeData = ShadThemeData(
    textTheme: MyTextStyle.myTextStyle,
    primaryButtonTheme: ShadButtonTheme(),
  );
}

