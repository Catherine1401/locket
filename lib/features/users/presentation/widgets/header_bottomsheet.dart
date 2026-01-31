import 'package:flutter/material.dart';
import 'package:locket/core/theme/colors.dart';

class HeaderBottomsheet extends StatelessWidget {
  const HeaderBottomsheet({super.key, this.color = MyColors.bgEditName});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: MyColors.stickHeader,
          child: SizedBox(width: 38, height: 5.5),
        ),
      ),
    );
  }
}
