import 'package:flutter/material.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BadgeBodyProfile extends StatelessWidget {
  const BadgeBodyProfile({
    super.key,
    required this.iconUrl,
    required this.title,
    this.chirdren,
  });

  final String iconUrl;
  final String title;
  final List<Widget>? chirdren;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            SvgPicture.asset(
              iconUrl,
              colorFilter: ColorFilter.mode(
                MyColors.iconProfile,
                BlendMode.srcIn,
              ),
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: ShadTheme.of(
                context,
              ).textTheme.custom['titleBagdgeProfile'],
            ),
          ],
        ),
        if (chirdren != null) const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: MyColors.bgItemProfile,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (chirdren != null)
                for (int i = 0; i < chirdren!.length; i++) ...[
                  chirdren![i],
                  if (i != chirdren!.length - 1) const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
